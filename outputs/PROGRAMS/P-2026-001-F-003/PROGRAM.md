# Program: F-003 名额配置管理

## 基本信息

| 属性 | 值 |
|------|-----|
| Program ID | P-2026-001-F-003 |
| 名称 | F-003 名额配置管理 |
| 类型 | implementation |
| 工作流 | feature-implementation |
| Feature ID | F-003 |
| 状态 | completed |

## 输入文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 需求拆分报告 | `../P-2026-003-ai-agent-decomposition/workspace/decomposition.md` | Feature 定义参考源 |
| PRD | `inputs/products/ai-agent-platform-prd.md` | 产品需求文档 |

## 目标

实现 F-003 名额配置管理的完整功能，包含：
- **应用层**（mall-agent-employee-service）：名额查询/校验消耗/释放/解锁、配置管理
- **门面层**（mall-admin）：管理端名额配置接口
- **门面层**（mall-toc-service）：用户端名额查询接口

## 服务分层

```
┌──────────────────────────────────────────┐
│  mall-admin（门面层）                     │
│  - QuotaConfigAdminController            │
│  - 通过 AgentEmployeeRemoteService Feign  │
└─────────────────┬────────────────────────┘
                  │ Feign (mall-agent-api)
                  ↓
┌──────────────────────────────────────────┐
│  mall-agent-employee-service（应用层）    │
│  - QuotaApplicationService               │
│  - QuotaQueryService / ManageService     │
│  - aim_agent_configs / aim_agent_user_quota│
└─────────────────┬────────────────────────┘
                  │ Feign (mall-client-api)
                  ↓
┌──────────────────────────────────────────┐
│  mall-client（数据层）                    │
│  - 用户等级查询                           │
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
