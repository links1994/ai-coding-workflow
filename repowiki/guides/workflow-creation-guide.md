# Workflow 创建指南

> 本文档指导如何设计符合项目标准的 Workflow 流程。

---

## 何时使用

在需要创建新的开发流程或优化现有流程时：
- 新增业务领域的工作流程（如数据分析、AI 模型训练）
- 现有流程的性能优化
- 流程间的依赖关系调整

---

## 六阶段生命周期规范

所有 Workflow 必须遵循以下六阶段生命周期：

```
research ──► decision ──► plan ──► execute ──► feedback ──► review
   │            │          │          │          │          │
   ▼            ▼          ▼          ▼          ▼          ▼
信息收集      决策澄清    计划制定    执行实施    反馈修正    审查归档
```

### 各阶段职责

| 阶段 | 核心职责 | 典型输出 |
|------|----------|----------|
| **research** | 收集信息、分析上下文、识别需求 | 分析报告、需求清单 |
| **decision** | 澄清模糊点、做出技术决策、确定策略 | 决策记录、澄清答案 |
| **plan** | 制定执行计划、生成规格文档、资源分配 | 技术规格书、执行计划 |
| **execute** | 执行具体任务、生成产物、实施变更 | 代码文件、配置文件 |
| **feedback** | 审查产物质量、收集反馈、修复问题 | 审查报告、修复记录 |
| **review** | 验证完整性、归档产物、总结复盘 | 归档文件、总结报告 |

### 阶段启用规则

- **enabled: true** - 阶段启用，必须包含至少一个步骤
- **enabled: false** - 阶段禁用，流程跳过此阶段
- 阶段间存在隐式依赖：前置阶段完成后才能进入下一阶段

---

## 步骤定义规范

### 步骤基本结构

```yaml
steps:
  - id: step_identifier          # 唯一标识，小写下划线命名
    name: 步骤显示名称            # 中文可读名称
    action: action_type          # 执行动作类型
    inputs: [input1, input2]     # 输入项列表
    outputs: [output1]           # 输出项列表
    description: |               # 详细描述（支持多行）
      步骤执行的具体说明
    require_confirmation: true   # 是否需要用户确认（可选，默认 false）
    condition: 条件表达式        # 执行条件（可选）
```

### 动作类型（action）

| 动作类型 | 用途 | 示例 |
|----------|------|------|
| `load` | 加载文件或配置 | 加载 PRD、加载规则文件 |
| `analyze` | 分析信息 | 分析需求、分析代码结构 |
| `clarify` | 澄清需求 | 接口设计澄清、数据模型澄清 |
| `generate` | 生成产物 | 生成代码、生成文档 |
| `delegate_to_agent` | 委托 Agent 执行 | 代码生成、测试执行 |
| `validate` | 验证产物 | 代码审查、完整性验证 |
| `confirm` | 用户确认 | 需求确认、产物确认 |
| `fix` | 修复问题 | 代码修复、配置修正 |
| `archive` | 归档产物 | 文件归档、状态更新 |

### 步骤依赖关系

```yaml
# 串行依赖（默认）
steps:
  - id: step_a
  - id: step_b      # 依赖 step_a 完成

# 显式依赖声明
steps:
  - id: step_a
  - id: step_b
    depends_on: [step_a]
    
# 并行执行（同一阶段内无依赖的步骤）
steps:
  - id: parallel_1
  - id: parallel_2  # 与 parallel_1 并行执行
```

---

## 可信源定义（source_of_truth）

### 定义规范

每个 Workflow 必须明确定义其产生的可信源：

```yaml
source_of_truth:
  - name: tech_spec              # 可信源名称
    type: markdown               # 文件类型
    location: workspace/outputs/tech-spec.md  # 文件路径
    description: |               # 可信源说明
      技术规格书是代码生成的唯一可信源。
      包含：接口定义、数据模型、业务规则、时序图。
```

### 可信源原则

1. **唯一性**：同一类信息只有一个可信源
2. **不可变性**：可信源一旦确认，下游必须遵循
3. **可追溯**：可信源变更必须记录变更原因
4. **级联更新**：可信源变更触发下游产物重新生成

---

## 级联更新规则（cascade_rules）

### 规则定义

```yaml
cascade_rules:
  - trigger: tech_spec           # 触发源
    effects: [generated_code, test_cases]  # 受影响产物
    action: regenerate           # 动作类型
    description: tech-spec 变更时重新生成代码和测试用例
    condition: 可选条件表达式
```

### 动作类型

| 动作 | 说明 | 适用场景 |
|------|------|----------|
| `regenerate` | 完全重新生成 | 规格变更影响产物结构 |
| `update` | 增量更新 | 局部变更，保留未变更部分 |
| `review` | 人工审查 | 需要人工判断是否更新 |
| `append` | 追加模式 | 在现有文件末尾追加内容 |

---

## 外部产物引用（external_artifacts）

### 引用规范

当 Workflow 需要引用上游流程的产物时：

```yaml
external_artifacts:
  description: 本流程引用的外部产物（只读）
  
  references:
    - name: tech_spec
      source: feature-implementation    # 来源 Workflow
      path: workspace/outputs/tech-spec.md
      usage: read-only                  # 使用方式
      strategy: append-mode-reference   # 引用策略
      description: 技术规格书，本流程只读取不修改
      
  constraints:
    - rule: no_modification
      description: 禁止修改外部产物
      enforcement: strict
```

### 引用策略

| 策略 | 说明 |
|------|------|
| `read-only` | 只读引用，禁止任何修改 |
| `append-mode-reference` | 追加模式引用，支持读取追加内容 |
| `version-aware` | 版本感知，需检查版本匹配性 |

---

## 输入输出定义规范

### 输入定义

```yaml
inputs:
  - name: input_name             # 输入项名称
    type: string                 # 数据类型
    required: true               # 是否必填
    description: 输入项说明
    path: 文件路径（文件类型）
    format: markdown             # 文件格式
    pattern: "^F-[0-9]{3}$"      # 格式校验（可选）
    default: 默认值（可选）
    condition: 条件（可选）
```

### 输出定义

```yaml
outputs:
  - name: output_name
    type: file                   # file / directory / object
    description: 输出项说明
    path: 输出路径
    format: markdown
    sections:                    # 文件结构（可选）
      - section1
      - section2
```

### 数据类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `string` | 字符串 | "F-001" |
| `file` | 文件路径 | workspace/outputs/spec.md |
| `directory` | 目录路径 | workspace/outputs/code/ |
| `array` | 数组 | [item1, item2] |
| `object` | 对象 | {key: value} |
| `rule` | 规则引用 | .qoder/rules/code-generation/ |

---

## 错误处理配置

### 全局错误处理

```yaml
error_handling:
  strategy: pause_and_report     # 错误处理策略
  max_retries: 3                 # 最大重试次数
  retry_delay: 5s                # 重试间隔
  escalation: manual             # 升级策略
  
  # 特定错误类型处理
  error_types:
    - type: validation_error
      strategy: report_and_continue
    - type: generation_error
      strategy: pause_and_report
    - type: network_error
      strategy: auto_retry
      max_retries: 5
```

### 策略类型

| 策略 | 说明 | 适用场景 |
|------|------|----------|
| `pause_and_report` | 暂停并报告错误 | 需要人工决策的错误 |
| `auto_retry` | 自动重试 | 网络超时等临时错误 |
| `report_and_continue` | 报告但继续 | 非阻塞性警告 |
| `skip_and_continue` | 跳过并继续 | 可选步骤失败 |

---

## 执行约束（constraints）

### 常用约束

```yaml
constraints:
  require_confirmation: true     # 是否需要用户确认
  require_tech_spec_confirmation: true  # 必须确认 tech-spec
  require_clarification: true    # 必须通过澄清阶段
  require_code_review: true      # 要求代码审查
  idempotent_generation: true    # 幂等生成
  max_requirements: 100          # 最大需求数
  max_depth: 5                   # 最大深度
```

---

## Workflow 模板

### 最小 Workflow 模板

```yaml
workflow:
  name: workflow-name
  description: Workflow 描述
  version: 1.0.0
  type: development              # development / analysis / testing
  
  lifecycle:
    research:
      enabled: true
      description: 信息收集阶段
      steps: []
    decision:
      enabled: true
      description: 决策澄清阶段
      steps: []
    plan:
      enabled: true
      description: 计划制定阶段
      steps: []
    execute:
      enabled: true
      description: 执行实施阶段
      steps: []
    feedback:
      enabled: true
      description: 反馈修正阶段
      steps: []
    review:
      enabled: true
      description: 审查归档阶段
      steps: []
  
  inputs: []
  outputs: []
  source_of_truth: []
  cascade_rules: []
  
  metadata:
    author: workflow-designer
    created: "2026-03-17"
    version: "1.0.0"
    tags: []
```

---

## 设计原则

### 必须遵守

1. **六阶段完整**：即使某阶段无步骤，也应显式声明 `enabled: false`
2. **可信源唯一**：每个核心产物有且只有一个可信源
3. **输入输出明确**：所有步骤的输入输出必须清晰定义
4. **错误处理完备**：必须配置错误处理策略

### 应该遵守

1. **步骤粒度适中**：一个步骤完成一个单一职责
2. **描述清晰完整**：description 应说明步骤的具体行为
3. **确认点合理**：关键决策点设置 `require_confirmation: true`
4. **级联规则完整**：上游产物变更需定义下游影响

### 禁止事项

1. **禁止循环依赖**：步骤间不能形成循环依赖
2. **禁止模糊输入**：输入项必须有明确的类型和描述
3. **禁止缺失错误处理**：执行类步骤必须有错误处理配置
4. **禁止重复可信源**：同一信息不能在多个地方定义为可信源

---

## 快速参考

### 常见 Workflow 类型

| 类型 | 用途 | 典型阶段 |
|------|------|----------|
| `analysis` | 分析类流程 | research → decision → plan → review |
| `development` | 开发类流程 | 六阶段完整 |
| `testing` | 测试类流程 | research → plan → execute → feedback → review |

### 步骤 ID 命名规范

- 使用小写字母和下划线
- 动词开头，描述动作
- 示例：`load_inputs`, `generate_code`, `validate_result`

### 文件路径规范

- 使用相对路径，基于 workspace/
- 输入文件：workspace/inputs/
- 输出文件：workspace/outputs/
- 产物归档：outputs/{类型}/{模块}/
