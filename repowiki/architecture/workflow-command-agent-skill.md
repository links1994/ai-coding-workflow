# Workflow / Command / Agent / Skill 架构设计指南

> **版本**: 1.0.0  
> **适用范围**: AI Coding Workflow 系统架构设计  
> **目标读者**: 流程设计师、Agent 开发者、系统架构师

---

## 1. 架构概览

### 1.1 核心组件关系

```
┌─────────────────────────────────────────────────────────────┐
│                      用户指令层                              │
│              "生成岗位类型管理功能代码"                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Workflow 编排层                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  阶段(Phase) → 步骤(Step) → 原子命令(Command)        │   │
│  │  execute:                                           │   │
│  │    - step1: delegate_to_agent (原子命令)            │   │
│  │    - step2: confirm (原子命令)                      │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Agent 执行层                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  code-generator Agent                               │   │
│  │  ├── 1. 读取 tech-spec.md                           │   │
│  │  ├── 2. 分析依赖关系 → 决策                         │   │
│  │  ├── 3. 调用 Skill: java-code-generation           │   │
│  │  ├── 4. DoD 检查 → 异常处理                         │   │
│  │  └── 5. 返回结果                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Skill 能力层                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  java-code-generation Skill                         │   │
│  │  ├── 生成 Feign 接口                                │   │
│  │  ├── 生成 DO/Mapper                                 │   │
│  │  ├── 生成 Service                                   │   │
│  │  └── 生成 Controller                                │   │
│  │                                                     │   │
│  │  约束来源: Rule (01-facade-service.md 等)           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 职责边界

| 层级 | 核心职责 | 关键问题 |
|------|----------|----------|
| **Workflow** | 编排阶段、定义步骤、控制流转 | "什么时候做什么" |
| **Command** | 原子操作、无状态执行 | "做什么" |
| **Agent** | 任务执行、决策、异常处理 | "怎么做+决策" |
| **Skill** | 纯技术能力、可复用 | "具体怎么做" |
| **Rule** | 规范约束、合规检查 | "按什么标准做" |

---

## 2. 原子命令设计

### 2.1 命令分类体系

```yaml
# 阶段级命令（Phase Commands）
phase_commands:
  research:
    - load_and_analyze      # 加载输入并分析上下文
  decision:
    - clarify_and_confirm   # 澄清需求并确认决策
  plan:
    - generate_spec         # 生成技术规格计划
  execute:
    - delegate_to_agent     # 委托 Agent 执行生成
  feedback:
    - review_and_fix        # 审查并修复问题
  review:
    - validate_and_archive  # 验证完整性并归档

# 动作级命令（Action Commands）
action_commands:
  # 加载类
  load:
    - load_feature
    - load_rules
    - load_knowledge
    - load_context
  
  # 分析类
  analyze:
    - analyze_services
    - analyze_deps
    - analyze_clarification_needs
  
  # 澄清类
  clarify:
    - clarify_interfaces
    - clarify_data_model
    - clarify_business_rules
  
  # 生成类
  generate:
    - generate_spec
    - generate_code
    - generate_report
    - generate_docs
  
  # 确认类
  confirm:
    description: 等待用户确认
  
  # 委托类
  delegate:
    description: 委托 Agent/Skill 执行
  
  # 审查类
  review:
    - review_code
    - review_spec
    - review_completeness
  
  # 验证类
  validate:
    - validate_spec
    - validate_code
    - validate_deps
  
  # 归档类
  archive:
    description: 归档产物到知识库
```

### 2.2 命令接口规范

```yaml
# 统一命令接口
command_interface:
  input:
    command: string        # 命令名称
    params: object         # 命令参数
    context: object        # 执行上下文
    
  output:
    result: any            # 执行结果
    status: enum           # success / failed / pending
    artifacts: array       # 生成的产物列表
    next_command: string   # 建议的下一步命令（可选）
```

### 2.3 复合命令

```yaml
# 支持原子命令组合成复杂操作
composite_commands:
  - name: full_generation
    description: 完整代码生成流程
    chain:
      - load_rules
      - analyze_context
      - clarify_requirements
      - generate_tech_spec
      - validate_spec
      - generate_code
      - review_code
      - archive_artifacts
```

---

## 3. Agent 设计规范

### 3.1 Agent 类型定义

| 类型 | 职责 | 示例 |
|------|------|------|
| **决策型 Agent** | 分析需求、澄清确认、生成规格 | spec-generator |
| **生成型 Agent** | 代码生成、DoD 检查、异常处理 | code-generator |
| **审查型 Agent** | 代码审查、文档生成、问题定位 | tech-doc-expert |
| **执行型 Agent** | 测试执行、环境检查、结果收集 | test-executor |

### 3.2 Agent 执行模式

```yaml
# 委托执行模式（Delegation Pattern）
delegation_pattern:
  workflow_step:
    action: delegate_to_agent
    agent: code-generator
    skill: java-code-generation
    rules:
      - code-generation/05-database-standards.md
      - code-generation/10-dod-cards.md
    
  execution_flow:
    - Workflow 定义输入输出、前置后置条件
    - Agent 负责任务编排、决策、异常处理
    - Skill 提供具体生成能力
    - Rule 提供约束规范
```

### 3.3 Agent 与 Skill 的关系

```
Agent 职责：
├── 任务分解与编排
├── 异常处理与决策
├── 用户交互与确认
└── 调用 Skill 执行具体工作

Skill 职责：
├── 纯生成逻辑
├── 无状态、可复用
└── 可被多个 Agent 调用
```

---

## 4. Skill 设计规范

### 4.1 Skill 分类

| 分类 | 说明 | 示例 |
|------|------|------|
| **生成类** | 代码/文档生成能力 | java-code-generation, tech-spec-generation |
| **分析类** | 静态分析、合规检查 | tech-spec-analyzer |
| **测试类** | 测试执行、结果收集 | http-test-executor, http-test-generator |
| **文档类** | API 文档生成 | swagger-doc-generation |

### 4.2 Skill 接口规范

```yaml
skill_interface:
  input:
    tech_spec: file        # 技术规格书
    generation_plan: object # 生成计划
    output_base_path: string # 输出基础路径
    
  output:
    generated_code: directory  # 生成的代码目录
    generation_manifest: file  # 生成清单
    
  constraints:
    rules: array           # 必须遵循的 Rule 列表
    pre_check: array       # 执行前检查项
```

### 4.3 Skill 组合模式

```yaml
# Skill 可以组合调用
skill_composition:
  primary: java-code-generation
  secondary:
    - swagger-doc-generation
    - http-test-generator
  
  execution_order:
    - java-code-generation 先生成代码
    - swagger-doc-generation 生成 API 文档
    - http-test-generator 生成测试文件
```

---

## 5. Rule 约束体系

### 5.1 Rule 分层加载

```yaml
rule_layers:
  always_on:          # 始终加载
    - 10-dod-cards.md
    - 11-architecture-design.md
    
  phase_specific:     # 阶段特定
    research:
      - 02-service-layering.md
    plan:
      - 12-spec-generation-constraints.md
    execute:
      - 01-facade-service.md
      - 02-inner-service.md
      - 03-feign-interface.md
```

### 5.2 Rule 应用模式

```yaml
# 规则驱动模式（Rule-Driven Pattern）
rule_driven:
  agent: code-generator
  pre_load:
    rules:
      - 01-facade-service.md      # Controller 规范
      - 02-inner-service.md       # Service 规范
      - 04-naming-standards.md    # 命名规范
      - 10-dod-cards.md           # DoD 检查卡
    constraint_mode: strict        # strict / warning
```

---

## 6. 协作流程示例

### 6.1 完整执行流程

```
用户: "生成 F-001 的代码"
  │
  ▼
Workflow: feature-implementation
  │
  ├── research 阶段 ──► load_rules (原子命令)
  ├── decision 阶段 ──► clarify (原子命令)
  ├── plan 阶段 ──►►► delegate_to_agent (原子命令)
  │                      │
  │                      ▼
  │              Agent: spec-generator
  │                      │
  │                      ├── 分析 tech-spec-draft
  │                      ├── 【决策】是否需要用户确认？
  │                      └── 调用 Skill: tech-spec-generation
  │                              │
  │                              └── 生成 tech-spec.md
  │
  ├── execute 阶段 ──►► delegate_to_agent (原子命令)
  │                      │
  │                      ▼
  │              Agent: code-generator
  │                      │
  │                      ├── 读取 tech-spec.md
  │                      ├── 【决策】生成顺序
  │                      ├── 调用 Skill: java-code-generation
  │                      │       ├── 生成 Feign 接口
  │                      │       ├── 生成 DO/Mapper
  │                      │       └── 生成 Service/Controller
  │                      ├── DoD 检查（基于 Rule）
  │                      └── 返回结果
  │
  └── review 阶段 ──► validate (原子命令)
```

### 6.2 数据流转

```yaml
data_flow:
  input:
    source: decomposition_report
    format: markdown
    
  transformation:
    - stage: decision
      output: answers.md
      
    - stage: plan
      output: tech-spec.md
      source_of_truth: true
      
    - stage: execute
      output: generated_code
      
    - stage: review
      output: implementation_report
```

---

## 7. 设计原则

### 7.1 单一职责原则

- **Workflow**: 只负责编排，不执行具体逻辑
- **Command**: 只定义操作，不做决策
- **Agent**: 只负责执行和决策，不实现底层能力
- **Skill**: 只提供纯技术能力，不处理业务逻辑
- **Rule**: 只提供约束，不执行操作

### 7.2 可复用性原则

- Skill 必须无状态，可被多个 Agent 复用
- Command 必须原子化，可组合成复杂操作
- Rule 必须模块化，可按需加载

### 7.3 可扩展性原则

- 新增 Workflow 不影响现有 Agent/Skill
- 新增 Agent 可复用现有 Skill
- 新增 Skill 可被多个 Agent 调用
- 新增 Rule 可按层加载

---

## 8. 最佳实践

### 8.1 Workflow 设计

1. **阶段清晰**: 每个阶段有明确的输入输出
2. **步骤原子**: 每个步骤对应一个原子命令
3. **依赖明确**: 步骤间依赖关系清晰
4. **可信源唯一**: 每个阶段有明确的可信源定义

### 8.2 Agent 设计

1. **职责单一**: 一个 Agent 负责一类任务
2. **Skill 复用**: 优先复用现有 Skill
3. **异常处理**: 完善的异常处理和用户交互
4. **决策透明**: 关键决策点记录决策理由

### 8.3 Skill 设计

1. **接口稳定**: Skill 接口保持向后兼容
2. **无状态**: 不依赖外部状态
3. **可测试**: 独立可测试
4. **文档完整**: 输入输出、约束条件文档化

---

## 9. 相关文档

- [Workflow 模板](../../orchestrator/WORKFLOWS/_TEMPLATE/workflow.yml)
- [Agent 开发指南](../../docs/guides/agent-creation-guide.md)
- [Skill 开发指南](../../docs/guides/skill-creation-guide.md)
- [Rule 开发指南](../../docs/guides/rule-creation-guide.md)
