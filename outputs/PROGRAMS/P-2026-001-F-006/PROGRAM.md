# Program: F-006 智能员工申请与审核

## 基本信息

| 属性 | 值 |
|------|-----|
| Program ID | P-2026-001-F-006 |
| 名称 | F-006 智能员工申请与审核 |
| 类型 | implementation |
| 工作流 | feature-implementation |
| Feature ID | F-006 |
| 状态 | completed |

## 目标

实现 F-006 智能员工申请与审核的完整功能，包含：
- **应用层**（mall-agent-employee-service）：员工申请/审核业务逻辑、名额扣减释放
- **门面层**（mall-admin）：运营端审核列表、审核详情、审核通过/驳回
- **门面层**（mall-toc-service）：APP端功能介绍、提交申请、查询审核状态、员工列表

## 服务分层

```
mall-toc-service（门面层）
    AiEmployeeAppController（4接口）
    └── AgentEmployeeRemoteService（Feign）
            │
            ↓
mall-agent-employee-service（应用层）
    AiEmployeeInnerController（8接口）
    └── AiEmployeeApplicationService
        ├── QuotaManageService（名额扣减/释放）
        ├── AgentProductRemoteService（商品代理校验）
        └── IdGenRemoteService（员工编号生成）
            │
            ↓
mall-admin（门面层）
    EmployeeAuditAdminController（5接口）
    └── AgentEmployeeRemoteService（Feign）
```

## 输出产物

| 产物 | 路径 |
|------|------|
| 技术规格书 | `workspace/outputs/tech-spec.md` | 代码生成的唯一可信源（Markdown 格式，内嵌时序图）|
| 实现报告 | `workspace/outputs/implementation-report.md` |
| 质量报告 | `workspace/outputs/quality-report.md` |

## 当前阶段

completed - 实现已完成并部署
