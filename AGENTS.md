# AGENTS.md

此文件为 AI Coding Agent 在本工作区工作时提供指导。

---

## 工作语言与风格

- 中文
- 简洁直接
- 代码注释清晰

---

## Boot Sequence

Agent 启动后：

1. **用户指定 Program**（如 "继续 P-2026-001" 或 "新 Program: xxx"）
2. **读取** `orchestrator/ALWAYS/BOOT.md`
3. **按指示加载**相关文件
4. **输出**当前状态和下一步

如果用户未指定 Program，扫描 `outputs/PROGRAMS/` 展示任务列表，询问要做什么。

---

## 目录结构

```
your-project/
├── AGENTS.md                      # 本文件
├── orchestrator/
│   ├── ALWAYS/                    # 核心配置（每次必读）
│   │   ├── BOOT.md                # 启动加载顺序
│   │   ├── CORE.md                # 工作协议
│   │   ├── DEV-FLOW.md            # 开发流程规范
│   │   ├── SUB-AGENT.md           # Sub-Agent 规范（按需使用）
│   │   └── RESOURCE-MAP.yml       # 资源索引
│   │
│   └── PROGRAMS/                  # Program 模板
│       └── _TEMPLATE/             # 模板目录
│
├── outputs/
│   └── PROGRAMS/                  # 开发任务（生成的 Program 放在这里）
│       └── P-YYYY-NNN-name/       # 每个 Program 一个目录
│           ├── PROGRAM.md         # 任务定义
│           ├── STATUS.yml         # 状态跟踪
│           ├── SCOPE.yml          # 写入范围
│           └── workspace/         # 工作文档
│
└── repos/                         # 代码仓库（可选，多仓库时使用）
```

---

## 快速命令

- "继续 P-2026-001" — 加载并继续该 Program
- "新 Program: xxx" — 创建新的开发任务
- "委托: xxx" — 使用 Sub-Agent 执行任务

---

## 工作流快速选择指南

**不确定用哪个工作流？按场景选择：**

| 你的场景 | 推荐工作流 | 指令示例 |
|----------|-----------|----------|
| 我有一个 PRD，需要拆分成可执行的任务 | req-decomposition | "基于 PRD 拆分需求" |
| 我要实现一个具体的 Feature | feature-implementation | "实现 F-001 的代码" |
| 我要测试已实现的接口 | http-api-testing | "测试 F-001 的接口" |

**工作流关系：**
```
PRD ──► req-decomposition ──► Feature 列表
                                │
                                ▼
                     feature-implementation ──► 代码
                                │
                                ▼
                       http-api-testing ──► 测试报告
```

---

## 状态来源

- **Programs 列表**: 扫描 `outputs/PROGRAMS/` 目录
- **Program 状态**: 读取各 Program 下的 `STATUS.yml`
- **仓库信息**: 读取 `orchestrator/ALWAYS/RESOURCE-MAP.yml`

不要在此文件维护状态副本，直接从源文件读取。
