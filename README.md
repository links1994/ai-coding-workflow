# AI Agent 编排框架

一个支持"调研-决策-规划-执行-反馈-复盘"六阶段生命周期的 AI Agent 编排框架，适用于代码开发、知识管理、内容创作等多种场景。

---

## 快速开始

### 1. 初始化项目

```bash
# Unix/Mac
./init.sh

# Windows
.\init.ps1
```

初始化脚本会引导你选择：
- **使用场景**：团队协作开发 / 个人独立开发 / 内容生产 / 知识管理
- **工作语言**：中文 / English
- **仓库配置**：单仓库 / 多仓库（仅开发类场景）

### 2. 开始使用

```bash
# 创建新任务
"新 Program: 你的任务描述"

# 继续已有任务
"继续 P-2026-001"
```

---

## 框架架构

```
┌─────────────────────────────────────────────────────────────┐
│                      初始化引导层                            │
│  ├── init.sh / init.ps1    → 交互式初始化脚本               │
│  └── templates/            → 场景模板（dev-team/solo/content/knowledge） │
├─────────────────────────────────────────────────────────────┤
│                      编排中枢层                              │
│  orchestrator/                                               │
│  ├── ALWAYS/               → 核心配置（每次启动加载）       │
│  │   ├── BOOT.md           → 启动加载顺序                   │
│  │   ├── CORE.md           → 核心工作协议                   │
│  │   ├── DEV-FLOW.md       → 开发流程规范                   │
│  │   ├── SUB-AGENT.md      → 子智能体规范                   │
│  │   └── RESOURCE-MAP.yml  → 资源映射                       │
│  │                                                          │
│  ├── PROGRAMS_TEMPLATE/    → Program 模板                   │
│  │   └── P-YYYY-NNN-name/  → 任务目录结构                   │
│  │       ├── PROGRAM.md    → 任务定义                       │
│  │       ├── SCOPE.yml     → 写入范围声明                   │
│  │       ├── STATUS.yml    → 状态跟踪                       │
│  │       └── workspace/    → 工作区                         │
│  │                                                          │
│  └── WORKFLOWS/            → 工作流定义                     │
│      ├── dev-workflow/     → 开发类工作流                   │
│      ├── content-workflow/ → 内容生产工作流                 │
│      ├── knowledge-workflow/ → 知识管理工作流               │
│      └── ...                                               │
├─────────────────────────────────────────────────────────────┤
│                      运行时核心层                            │
│  .qoder/                                                     │
│  ├── agents/               → 智能体定义                     │
│  ├── skills/               → 技能库                         │
│  └── rules/                → 规则定义                       │
├─────────────────────────────────────────────────────────────┤
│                      原子步骤层                              │
│  steps/                                                      │
│  ├── research/             → 调研类步骤                     │
│  ├── decision/             → 决策类步骤                     │
│  ├── plan/                 → 规划类步骤                     │
│  ├── execute/              → 执行类步骤                     │
│  ├── feedback/             → 反馈类步骤                     │
│  └── review/               → 复盘类步骤                     │
├─────────────────────────────────────────────────────────────┤
│                      知识沉淀层                              │
│  knowledge/                                                  │
│  ├── concepts/             → 概念定义                       │
│  ├── patterns/             → 模式库                         │
│  ├── experiences/          → 经验条目                       │
│  └── decisions/            → 决策记录                       │
├─────────────────────────────────────────────────────────────┤
│                      输入/产出层                             │
│  inputs/               → 外部输入文档（PRD、参考等）        │
│  outputs/              → 产出物（代码、文档、数据）         │
│  docs/                 → 文档管理                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 核心概念

### Program（程序）

一个 Program 是一个独立的任务单元，遵循六阶段生命周期：

1. **调研 (Research)** - 收集信息、分析问题
2. **决策 (Decision)** - 评估选项、选择方案
3. **规划 (Plan)** - 拆解任务、制定计划
4. **执行 (Execute)** - 实施计划、生成产出
5. **反馈 (Feedback)** - 验证结果、收集反馈
6. **复盘 (Review)** - 提取经验、沉淀知识

### 场景模板

框架提供 **4 种核心场景模板**，分为两大类：

#### 开发类（代码为中心）

| 场景 | 适用场景 | 特点 |
|------|----------|------|
| `dev-team` | 团队协作开发 | 多仓库、CI/CD、代码审查、规范统一 |
| `dev-solo` | 个人独立开发 | 单仓库、快速迭代、轻量流程 |

#### 内容类（知识为中心）

| 场景 | 适用场景 | 特点 |
|------|----------|------|
| `content-create` | 内容生产 | 写作、编辑、发布、多媒体创作 |
| `knowledge-mgmt` | 知识管理 | 收集、整理、关联、检索 |

---

## 目录说明

| 目录 | 用途 | 说明 |
|------|------|------|
| `orchestrator/ALWAYS/` | 核心配置 | 每次启动必读的协议和规范 |
| `orchestrator/PROGRAMS_TEMPLATE/` | 任务模板 | 复制此模板创建新 Program |
| `orchestrator/WORKFLOWS/` | 工作流 | 定义各类任务的执行流程 |
| `steps/` | 原子步骤 | 可复用的步骤定义 |
| `templates/` | 场景模板 | 不同场景的初始化配置 |
| `knowledge/` | 知识沉淀 | 复盘产出的经验、模式 |
| `.qoder/` | 运行时 | 智能体、技能、规则 |

---

## 使用流程

### 创建新 Program

```bash
# 1. 复制模板
cp -r orchestrator/PROGRAMS_TEMPLATE/P-YYYY-NNN-name orchestrator/PROGRAMS/P-2026-001-my-task

# 2. 编辑 PROGRAM.md 定义任务
# 3. 编辑 SCOPE.yml 声明写入范围
# 4. 开始执行
```

### Agent 工作指令

- **"新 Program: xxx"** — 创建并启动新任务
- **"继续 P-2026-001"** — 加载并继续已有任务
- **"委托: xxx"** — 使用 Sub-Agent 执行子任务

---

## 扩展框架

### 添加新场景模板

1. 在 `templates/` 下创建新目录
2. 添加 `RESOURCE-MAP.yml` 定义该场景的资源映射
3. 更新 `init.sh` / `init.ps1` 添加场景选项

### 添加新工作流

1. 在 `orchestrator/WORKFLOWS/` 下创建目录
2. 编写 `workflow.yml` 定义步骤序列
3. 在 `steps/` 下实现所需步骤

### 添加新步骤

1. 在 `steps/{phase}/` 下创建 YAML 文件
2. 定义步骤的输入、输出、执行逻辑
3. 更新 `steps/_registry.yml` 注册步骤

---

## 文档索引

| 文档 | 位置 | 说明 |
|------|------|------|
| 启动协议 | `orchestrator/ALWAYS/BOOT.md` | Agent 启动加载顺序 |
| 核心协议 | `orchestrator/ALWAYS/CORE.md` | 工作协议和约定 |
| 开发流程 | `orchestrator/ALWAYS/DEV-FLOW.md` | 开发流程规范 |
| 子智能体 | `orchestrator/ALWAYS/SUB-AGENT.md` | Sub-Agent 使用规范 |
| 资源映射 | `orchestrator/ALWAYS/RESOURCE-MAP.yml` | 仓库和基础设施配置 |

---

## 详细使用指南

### 初始化后的操作步骤

#### 1. 配置 RESOURCE-MAP.yml

这是项目的"身份证"，告诉 Agent 你的项目信息：

```yaml
# orchestrator/ALWAYS/RESOURCE-MAP.yml
repos:
  backend:
    path: repos/backend
    git: https://github.com/your-org/backend.git
    desc: 后端服务
    lang: TypeScript
    status: active

infrastructure:
  databases:
    postgres:
      host: localhost
      port: 5432
```

#### 2. 创建 Program（任务）

每个开发任务对应一个 Program：

```bash
# 1. 从模板创建
cp -r orchestrator/PROGRAMS_TEMPLATE outputs/PROGRAMS/P-2026-001-my-feature

# 2. 编辑三个核心文件：
#    - PROGRAM.md  → 定义任务目标、需求
#    - SCOPE.yml   → 定义 Agent 可以修改的文件范围
#    - STATUS.yml  → 跟踪任务进度
```

#### 3. 启动工作

对 Agent 说：**"继续 P-2026-001"**

Agent 会自动加载：
1. CORE.md → 了解工作协议
2. RESOURCE-MAP.yml → 了解项目结构
3. PROGRAM.md → 了解任务目标
4. STATUS.yml → 了解当前进度

---

### 文件管理规范

| 文件类型 | 位置 | 用途 |
|---------|------|------|
| **核心协议** | `orchestrator/ALWAYS/` | 工作规范、资源索引 |
| **工作流模板** | `orchestrator/WORKFLOWS/` | 场景化的步骤组合 |
| **步骤定义** | `steps/{category}/` | 原子步骤的 YAML 定义 |
| **任务目录** | `outputs/PROGRAMS/P-XXX/` | 每个任务的独立空间 |
| **状态文件** | `STATUS.yml` | 任务进度跟踪 |
| **范围控制** | `SCOPE.yml` | 写入权限控制 |
| **交接文档** | `workspace/HANDOFF.md` | 跨会话状态保存 |
| **检查点** | `workspace/CHECKPOINT.md` | 上下文紧张时保存 |

---

### 如何添加新步骤

#### 1. 创建步骤定义文件

```yaml
# steps/execute/my_custom_step.yml
name: my_custom_step
description: 我的自定义步骤
category: execute

params:
  - name: input_data
    type: string
    required: true
    description: 输入数据

outputs:
  - name: result
    type: string
    description: 处理结果

implementation:
  type: prompt
  template: |
    请处理以下数据：{{input_data}}
```

#### 2. 在 _registry.yml 中注册

```yaml
# steps/_registry.yml
execute:
  my_custom_step:
    name: my_custom_step
    description: 我的自定义步骤
    path: steps/execute/my_custom_step.yml
    category: execute
    params:
      - name: input_data
        type: string
        required: true
    outputs:
      - name: result
        type: string
```

#### 3. 在工作流中使用

```yaml
# orchestrator/WORKFLOWS/xxx/workflow.yml
execute:
  steps:
    - step: steps/execute/my_custom_step
      description: 执行自定义处理
      params:
        input_data: "some data"
```

---

### 如何添加新规范

#### 添加 ALWAYS 规范文件

```bash
# 1. 创建规范文件
touch orchestrator/ALWAYS/MY-GUIDE.md
```

#### 修改 BOOT.md 加载顺序

```markdown
# orchestrator/ALWAYS/BOOT.md
## 加载顺序
1. CORE.md
2. DEV-FLOW.md
3. MY-GUIDE.md    # ← 添加你的新规范
4. RESOURCE-MAP.yml
```

#### 添加新的工作流类型

```bash
# 1. 创建工作流目录
mkdir orchestrator/WORKFLOWS/my-workflow

# 2. 复制模板并修改
cp orchestrator/WORKFLOWS/code-development/workflow.yml \
   orchestrator/WORKFLOWS/my-workflow/workflow.yml
```

---

### 实际使用示例

假设你要开发一个新功能：

```bash
# 1. 创建 Program
cp -r orchestrator/PROGRAMS_TEMPLATE outputs/PROGRAMS/P-2026-001-user-auth

# 2. 编辑 PROGRAM.md 定义任务
# 3. 编辑 SCOPE.yml 限定修改范围（如只允许修改 src/auth/ 目录）
# 4. 编辑 STATUS.yml 设置初始状态
```

然后对 Agent 说：**"继续 P-2026-001"**

Agent 会：
1. 读取所有配置
2. 根据 WORKFLOW 执行六阶段流程
3. 自动更新 STATUS.yml
4. 超出 SCOPE 范围时会询问你

---

### 核心设计思想

1. **标准化**：所有任务都走六阶段流程，确保不遗漏环节
2. **可配置**：通过 YAML 文件控制行为，无需改代码
3. **安全**：SCOPE.yml 控制写入范围，防止误操作
4. **可恢复**：HANDOFF/CHECKPOINT 机制支持跨会话继续
5. **可扩展**：步骤和工作流都可以自定义添加

---

*框架版本: 0.1.0*  
*最后更新: 2026-03-15*
