# Program: F-012 AI对话引擎

## 基本信息

| 属性 | 值 |
|------|-----|
| Program ID | P-2026-001-F-012 |
| 名称 | F-012 AI对话引擎 |
| 类型 | implementation |
| 工作流 | feature-implementation |
| Feature ID | F-012 |
| 状态 | created |

## 输入文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 需求拆分报告 | `../P-2026-001-ai-agent-decomposition/workspace/decomposition.md` | Feature 定义参考源 |
| PRD | `inputs/products/ai-agent-platform-prd.md` | 产品需求文档 |

## 目标

实现 F-012 AI对话引擎的完整功能，包含：
- **门面层**（mall-toc-service）：C端AI对话接口
- **门面层**（mall-ai）：AI服务对话接口（SSE流式输出）
- **应用层**（mall-agent-employee-service）：对话引擎业务逻辑、话术匹配、知识库检索、Prompt组装、AI调用

## 服务分层

```
┌──────────────────────────────────────────┐
│  mall-toc-service（门面层）               │
│  - 对话相关 Controller                    │
│  - 通过 AgentEmployeeRemoteService Feign  │
└─────────────────┬────────────────────────┘
                  │
┌──────────────────────────────────────────┐
│  mall-ai（门面层）                        │
│  - SSE流式对话接口                        │
│  - 通过 AgentEmployeeRemoteService Feign  │
└─────────────────┬────────────────────────┘
                  │ Feign (mall-inner-api)
                  ↓
┌──────────────────────────────────────────┐
│  mall-agent-employee-service（应用层）    │
│  - ConversationApplicationService        │
│  - ConversationQueryService              │
│  - ConversationManageService             │
│  - ScriptQueryService（话术匹配）         │
│  - KnowledgeQueryService（知识库检索）    │
│  - PromptService（Prompt组装）            │
│  - LLMService（大模型调用）               │
└──────────────────────────────────────────┘
```

## 依赖Feature

| Feature ID | 名称 | 状态 | 说明 |
|------------|------|------|------|
| F-006 | 智能员工申请与审核 | 已完成 | 员工基础数据 |
| F-009 | Prompt管理与生成 | 进行中 | Prompt模板 |
| F-010 | 话术管理与审核 | 进行中 | 话术库数据 |
| F-011 | 知识库管理与审核 | 进行中 | 知识库向量检索 |
| F-013 | 对话记录与内容审核 | 进行中 | 对话记录存储 |

## 核心功能点

1. **SSE流式对话**：首字响应≤2s，支持流式输出
2. **话术优先匹配**：相似度≥0.85时直接返回话术
3. **知识库检索**：未命中话术时检索Top3知识片段
4. **Prompt动态组装**：根据员工配置动态生成Prompt
5. **对话记录**：完整记录对话内容和消息来源
6. **商品导购入口**：商品详情页按需展示AI导购按钮

## 输出产物

| 产物 | 路径 | 说明 |
|------|------|------|
| 技术规格书 | `workspace/outputs/tech-spec.md` | 代码生成的唯一可信源（Markdown 格式，内嵌时序图）|
| 实现报告 | `workspace/outputs/implementation-report.md` | 实现摘要 |
| 质量报告 | `workspace/outputs/quality-report.md` | 代码质量审查结果 |

## 当前阶段

created - 等待启动
