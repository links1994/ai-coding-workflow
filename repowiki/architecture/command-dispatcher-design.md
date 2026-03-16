# 命令调度层设计文档

> **版本**: 1.0.0  
> **状态**: 设计草案  
> **目标**: 统一命令调度接口，解耦 Workflow、Agent、Skill 之间的调用关系

---

## 1. 设计背景

### 1.1 当前问题

当前 Workflow 直接通过 `action` 字段指定操作，存在以下问题：

1. **命令分散**: 各 Workflow 自行定义 action，缺乏统一规范
2. **调用混乱**: Workflow 直接调用 Agent 或 Skill，调用关系不清晰
3. **难以扩展**: 新增命令类型需要修改多个 Workflow 文件
4. **无法复用**: 相同功能在不同 Workflow 中命令名称不一致

### 1.2 设计目标

1. **统一接口**: 所有操作通过统一的命令调度层执行
2. **职责分离**: Workflow 只负责编排，不直接执行操作
3. **易于扩展**: 新增命令只需注册到调度器
4. **调用透明**: 调用方无需关心底层是 Agent 还是 Skill

---

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                      Workflow 编排层                         │
│              (定义阶段、步骤、流转条件)                        │
│              只声明 "做什么"，不声明 "怎么做"                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    命令调度层 (Command Dispatcher)            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  统一命令接口                                         │   │
│  │  - 命令路由：根据 action 路由到对应处理器              │   │
│  │  - 参数校验：验证输入参数合法性                       │   │
│  │  - 前置检查：执行前检查（Rule 加载等）                │   │
│  │  - 后置处理：结果包装、错误处理                       │   │
│  │  - 日志记录：命令执行日志                             │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
           ┌──────────────────┼──────────────────┐
           ▼                  ▼                  ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  原子命令      │    │   Agent       │    │   Skill       │
│  处理器        │    │   运行时       │    │   注册表       │
│               │    │               │    │               │
│ • load_*      │    │ • 任务编排     │    │ • 能力注册     │
│ • analyze_*   │    │ • 决策逻辑     │    │ • 版本管理     │
│ • clarify_*   │    │ • 异常处理     │    │ • 参数校验     │
│ • generate_*  │    │ • 用户交互     │    │               │
│ • confirm     │    │               │    │               │
│ • validate_*  │    │               │    │               │
│ • archive     │    │               │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
```

### 2.2 核心组件

| 组件 | 职责 | 示例 |
|------|------|------|
| **Command Router** | 命令路由，根据 action 分发到对应处理器 | `load_rules` → LoadCommandHandler |
| **Command Handler** | 命令处理器，执行具体逻辑 | LoadCommandHandler 加载规则文件 |
| **Agent Runtime** | Agent 运行时环境，管理 Agent 生命周期 | 启动 spec-generator Agent |
| **Skill Registry** | Skill 注册表，管理 Skill 版本和依赖 | 注册 java-code-generation Skill |
| **Rule Engine** | 规则引擎，加载和校验 Rule | 加载 01-facade-service.md |

---

## 3. 命令接口规范

### 3.1 统一命令接口

```yaml
# 命令请求
command_request:
  command_id: string          # 命令唯一标识（UUID）
  action: string              # 命令名称
  params: object              # 命令参数
  context:                    # 执行上下文
    program_id: string        # Program ID
    workflow_name: string     # Workflow 名称
    phase: string             # 当前阶段
    step_id: string           # 步骤 ID
    execution_depth: number   # 执行深度（防止循环）
  metadata:                   # 元数据
    timestamp: datetime       # 请求时间
    source: string            # 调用来源

# 命令响应
command_response:
  command_id: string          # 对应请求 ID
  status: enum                # success / failed / pending / retry
  result: any                 # 执行结果
  artifacts: array            # 生成的产物列表
    - name: string
      type: string
      path: string
      metadata: object
  error:                      # 错误信息（status=failed 时）
    code: string
    message: string
    details: object
  next_actions: array         # 建议的下一步操作
  execution_time: number      # 执行耗时（ms）
```

### 3.2 命令分类

```yaml
# 1. 原子命令（直接执行）
atomic_commands:
  category: load
    - load_feature
    - load_rules
    - load_knowledge
    - load_context
    
  category: analyze
    - analyze_services
    - analyze_deps
    - analyze_clarification_needs
    - analyze_context
    
  category: clarify
    - clarify_interfaces
    - clarify_data_model
    - clarify_business_rules
    
  category: generate
    - generate_spec
    - generate_code
    - generate_report
    - generate_docs
    - generate_decisions
    - generate_clarification_summary
    - generate_implementation_report
    - generate_decomposition_report
    
  category: confirm
    - confirm                    # 通用确认
    
  category: validate
    - validate_spec
    - validate_code
    - validate_deps
    - validate_completeness
    - validate_plan
    
  category: review
    - review_code
    - review_spec
    - review_completeness
    
  category: fix
    - fix_issues
    
  category: archive
    - archive

# 2. 委托命令（调用 Agent）
delegation_commands:
  - name: delegate_to_agent
    description: 委托 Agent 执行复杂任务
    parameters:
      - agent: string           # Agent 名称
      - skill: string           # 可选 Skill 名称
      - rules: array            # 可选 Rule 列表
      - timeout: number         # 超时时间（秒）

# 3. 决策命令（需要人工干预）
decision_commands:
  - name: determine_strategy
  - name: determine_layer_order
  - name: determine_code_strategy
  - name: define_dimensions
  - name: create_generation_plan
  - name: create_decomposition_plan
  - name: create_batch_plan
```

---

## 4. 命令处理器设计

### 4.1 处理器接口

```yaml
command_handler:
  interface:
    can_handle(action: string): boolean
    validate(request: CommandRequest): ValidationResult
    execute(request: CommandRequest): CommandResponse
    rollback(request: CommandRequest): CommandResponse
    
  lifecycle:
    - initialize: 初始化处理器
    - validate: 验证请求参数
    - pre_execute: 执行前准备（加载 Rule 等）
    - execute: 执行命令
    - post_execute: 执行后处理（保存产物等）
    - cleanup: 清理资源
```

### 4.2 处理器注册表

```yaml
# 处理器注册配置
handler_registry:
  # 原子命令处理器
  atomic:
    - action: load_rules
      handler: LoadRulesHandler
      priority: 100
      
    - action: analyze_services
      handler: AnalyzeServicesHandler
      priority: 100
      
    - action: generate_spec
      handler: GenerateSpecHandler
      priority: 100
      
    - action: confirm
      handler: ConfirmHandler
      priority: 200    # 高优先级，需要用户交互
      
  # 委托命令处理器
  delegation:
    - action: delegate_to_agent
      handler: AgentDelegationHandler
      priority: 100
      
  # 决策命令处理器
  decision:
    - action: determine_strategy
      handler: StrategyDecisionHandler
      priority: 150
```

---

## 5. Agent 运行时设计

### 5.1 Agent 调用流程

```
Workflow ──► Command Dispatcher ──► AgentDelegationHandler
                                          │
                                          ▼
                              ┌───────────────────────┐
                              │    Agent Runtime      │
                              │  ┌─────────────────┐  │
                              │  │ 1. 加载 Agent   │  │
                              │  │    配置         │  │
                              │  └─────────────────┘  │
                              │  ┌─────────────────┐  │
                              │  │ 2. 准备执行     │  │
                              │  │    环境         │  │
                              │  └─────────────────┘  │
                              │  ┌─────────────────┐  │
                              │  │ 3. 调用 Skill   │  │
                              │  │    执行         │  │
                              │  └─────────────────┘  │
                              │  ┌─────────────────┐  │
                              │  │ 4. 收集结果     │  │
                              │  │    返回         │  │
                              │  └─────────────────┘  │
                              └───────────────────────┘
```

### 5.2 Agent 配置

```yaml
# Agent 配置
agent_config:
  spec-generator:
    type: decision
    skills:
      - tech-spec-generation
      - tech-spec-analyzer
    rules:
      - code-generation/12-spec-generation-constraints.md
    timeout: 300
    retry: 2
    
  code-generator:
    type: generation
    skills:
      - java-code-generation
      - swagger-doc-generation
      - http-test-generator
    rules:
      - code-generation/01-facade-service.md
      - code-generation/02-inner-service.md
      - code-generation/03-feign-interface.md
      - code-generation/10-dod-cards.md
    timeout: 600
    retry: 1
```

---

## 6. Skill 注册表设计

### 6.1 Skill 注册

```yaml
# Skill 注册配置
skill_registry:
  java-code-generation:
    version: 1.2.0
    path: .qoder/skills/java-code-generation/
    entry: SKILL.md
    inputs:
      - tech_spec: file
      - generation_plan: object
    outputs:
      - generated_code: directory
      - generation_manifest: file
    dependencies: []
    
  tech-spec-generation:
    version: 1.0.0
    path: .qoder/skills/tech-spec-generation/
    entry: SKILL.md
    inputs:
      - clarified_interfaces: object
      - clarified_data_model: object
      - clarified_business_rules: object
    outputs:
      - tech_spec: file
    dependencies: []
    
  swagger-doc-generation:
    version: 1.0.0
    path: .qoder/skills/swagger-doc-generation/
    entry: SKILL.md
    inputs:
      - tech_spec: file
      - facade_layer_code: directory
    outputs:
      - swagger_docs: directory
    dependencies:
      - java-code-generation
```

### 6.2 Skill 版本管理

```yaml
# Skill 版本策略
versioning:
  strategy: semantic
  compatibility:
    - major: 不兼容变更，需要手动升级
    - minor: 向后兼容的功能新增
    - patch: 向后兼容的问题修复
    
  resolution:
    - exact: 精确匹配指定版本
    - compatible: 使用兼容的最新版本
    - latest: 使用最新版本
```

---

## 7. 错误处理机制

### 7.1 错误分类

```yaml
error_types:
  validation_error:
    code: VALIDATION_ERROR
    description: 参数验证失败
    retryable: false
    
  execution_error:
    code: EXECUTION_ERROR
    description: 执行过程中出错
    retryable: true
    
  timeout_error:
    code: TIMEOUT_ERROR
    description: 执行超时
    retryable: true
    
  agent_error:
    code: AGENT_ERROR
    description: Agent 执行出错
    retryable: true
    
  skill_error:
    code: SKILL_ERROR
    description: Skill 执行出错
    retryable: false
    
  user_cancel:
    code: USER_CANCEL
    description: 用户取消操作
    retryable: false
```

### 7.2 重试策略

```yaml
retry_policy:
  default:
    max_attempts: 3
    backoff: exponential
    initial_delay: 1000ms
    max_delay: 30000ms
    
  agent_delegation:
    max_attempts: 2
    backoff: linear
    initial_delay: 5000ms
    
  user_interaction:
    max_attempts: 1    # 不重试
```

---

## 8. 实现建议

### 8.1 第一阶段：命令规范化（当前）

1. 统一所有 Workflow 的 action 命名
2. 建立命令命名规范文档
3. 在 workflow-designer Agent 中加入命令选择指南

**状态**: ✅ 已完成

### 8.2 第二阶段：命令调度层（建议）

1. 实现 Command Dispatcher 核心
2. 实现基础命令处理器（load, analyze, confirm）
3. 实现 AgentDelegationHandler
4. 迁移现有 Workflow 使用新接口

### 8.3 第三阶段：Skill 注册表（建议）

1. 建立 Skill Registry
2. 实现 Skill 版本管理
3. 实现 Skill 依赖解析
4. 优化 Agent 运行时

---

## 9. 迁移路径

### 9.1 向后兼容

```yaml
# 旧格式（仍支持）
step:
  action: generate
  
# 新格式（推荐）
step:
  action: generate_spec
  
# 委托格式（execute 阶段）
step:
  action: delegate_to_agent
  agent: spec-generator
  skill: tech-spec-generation
```

### 9.2 渐进式迁移

1. **Phase 1**: 文档规范，新 Workflow 使用新格式
2. **Phase 2**: 工具支持，提供命令验证工具
3. **Phase 3**: 自动化迁移，批量更新现有 Workflow
4. **Phase 4**: 废弃旧格式，强制使用新格式

---

## 10. 相关文档

- [Workflow/Command/Agent/Skill 架构设计](./workflow-command-agent-skill.md)
- [workflow-designer Agent 文档](../../.qoder/agents/workflow_designer.md)
- [feature-implementation Workflow](../../orchestrator/WORKFLOWS/feature-implementation/workflow.yml)
- [req-decomposition Workflow](../../orchestrator/WORKFLOWS/req-decomposition/workflow.yml)
