# Program: F-004 代理商品配置

## 基本信息

| 属性 | 值 |
|------|-----|
| Program ID | P-2026-001-F-004 |
| 名称 | F-004 代理商品配置 |
| 类型 | implementation |
| 工作流 | feature-implementation |
| Feature ID | F-004 |
| 状态 | completed |

## 输入文档

| 文档 | 路径 | 说明 |
|------|------|------|
| 需求拆分报告 | `../P-2026-003-ai-agent-decomposition/workspace/decomposition.md` | Feature 定义参考源 |
| PRD | `inputs/products/ai-agent-platform-prd.md` | 产品需求文档 |

## 目标

实现 F-004 代理商品配置的完整功能，包含：
- **应用层**（mall-agent-employee-service）：代理商品池管理、批量导入、Inner API
- **门面层**（mall-admin）：管理端代理商品接口
- **门面层**（mall-toc-service）：用户端可代理商品搜索

## 服务分层

```
┌──────────────────────────────────────────┐
│  mall-admin（门面层）                     │
│  - AgentProductAdminController           │
│  - 通过 AgentProductRemoteService Feign   │
└─────────────────┬────────────────────────┘
                  │ Feign (mall-agent-api)
                  ↓
┌──────────────────────────────────────────┐
│  mall-agent-employee-service（应用层）    │
│  - AgentProductApplicationService        │
│  - AgentProductQueryService / ManageService│
│  - aim_agent_product                     │
└─────────────────┬────────────────────────┘
                  │ Feign (mall-product)
                  ↓
┌──────────────────────────────────────────┐
│  mall-product（数据层）                   │
│  - 商品校验、类目查询                      │
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
