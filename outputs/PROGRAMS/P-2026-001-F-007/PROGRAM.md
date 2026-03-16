# Program: F-007 智能员工解锁与激活

## 基本信息

| 属性 | 值 |
|------|-----|
| Program ID | P-2026-001-F-007 |
| 名称 | F-007 智能员工解锁与激活 |
| 类型 | implementation |
| 工作流 | feature-implementation |
| Feature ID | F-007 |
| 状态 | pending |

## 目标

实现 F-007 智能员工解锁与激活功能，包含：
- **应用层**（mall-agent-employee-service）：邀请链接生成、解锁进度跟踪、激活处理
- **门面层**（mall-toc-service）：APP端邀请落地页、解锁进度查询
- **门面层**（mall-admin）：管理端手动激活

## 服务分层

```
mall-toc-service（门面层）
    ActivationAppController（4接口）
    └── AgentEmployeeRemoteService（Feign）
            │
            ↓
mall-agent-employee-service（应用层）
    ActivationInnerController（6接口）
    └── ActivationApplicationService
        ├── QuotaManageService（名额相关）
        └── AimAgentActivationRecordService（激活记录）
            │
            ↓
mall-admin（门面层）
    ActivationAdminController（2接口）
    └── AgentEmployeeRemoteService（Feign）
```

## 输出产物

| 产物 | 路径 |
|------|------|
| 技术规格书 | `workspace/outputs/tech-spec.md` | 代码生成的唯一可信源（Markdown 格式，内嵌时序图）|
| 实现报告 | `workspace/outputs/implementation-report.md` |
| 质量报告 | `workspace/outputs/quality-report.md` |

## 当前阶段

pending - 待实现（需从已有代码反向生成文档）
