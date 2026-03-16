# Program: F-001 岗位类型管理

## 基本信息

| 属性 | 值 |
|------|-----|
| Program ID | P-2026-001-F-001 |
| 名称 | F-001 岗位类型管理 |
| 类型 | implementation |
| 工作流 | feature-implementation |
| Feature ID | F-001 |
| 状态 | completed |

## 输入文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 需求拆分报告 | `../P-2026-003-ai-agent-decomposition/workspace/decomposition.md` | Feature 定义参考源 |
| PRD | `inputs/products/ai-agent-platform-prd.md` | 产品需求文档 |

## 目标

实现 F-001 岗位类型管理的完整功能，包含：
- **应用层**（mall-agent-employee-service）：岗位类型 CRUD 业务逻辑、Inner API
- **门面层**（mall-admin）：管理后台岗位类型接口，通过 Feign 调用应用层

## 服务分层

```
┌──────────────────────────────────────────┐
│  mall-admin（门面层）                     │
│  - 岗位管理 Controller + VO              │
│  - 通过 AgentEmployeeRemoteService Feign  │
└─────────────────┬────────────────────────┘
                  │ Feign (mall-agent-api)
                  ↓
┌──────────────────────────────────────────┐
│  mall-agent-employee-service（应用层）    │
│  - JobTypeApplicationService             │
│  - JobTypeQueryService / ManageService   │
│  - AimJobTypeService / AimJobTypeMapper  │
└──────────────────────────────────────────┘
```

## 输出产物

| 产物 | 路径 | 说明 |
|------|------|------|
| 技术规格书 | `workspace/outputs/tech-spec.md` | 代码生成的唯一可信源（Markdown 格式，内嵌时序图）|
| 实现报告 | `workspace/outputs/implementation-report.md` | 实现摘要 |
| 质量报告 | `workspace/outputs/quality-report.md` | 代码质量审查结果 |

## 当前阶段

completed - 实现已完成并部署
