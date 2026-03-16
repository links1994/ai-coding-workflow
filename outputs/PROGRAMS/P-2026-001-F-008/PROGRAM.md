# Program: F-008 智能员工运营管理

## 基本信息

| 属性 | 值 |
|------|-----|
| Program ID | P-2026-001-F-008 |
| 名称 | F-008 智能员工运营管理 |
| 类型 | implementation |
| 工作流 | feature-implementation |
| Feature ID | F-008 |
| 状态 | in_progress |

## 目标

实现 F-008 智能员工运营管理的完整功能，包含：
- **应用层**（mall-agent-employee-service）：员工列表查询、状态变更、佣金修改
- **门面层**（mall-admin）：运营端员工管理接口
- **门面层**（mall-toc-service）：用户端员工详情、主动下线

## 服务分层

```
mall-admin（门面层）
    EmployeeManageAdminController（7接口）
    └── AgentEmployeeRemoteService（Feign）
            │
            ↓
mall-agent-employee-service（应用层）
    AiEmployeeInnerController（6接口扩展）
    └── AiEmployeeApplicationService
        ├── AiEmployeeQueryService（列表/统计）
        └── AiEmployeeManageService（状态变更/佣金修改）
            │
            ↓
mall-toc-service（门面层）
    AiEmployeeAppController（2接口扩展）
    └── AgentEmployeeRemoteService（Feign）
```

## 输出产物

| 产物 | 路径 |
|------|------|
| 技术规格书 | `workspace/outputs/tech-spec.md` | 代码生成的唯一可信源（Markdown 格式，内嵌时序图）|
| 实现报告 | `workspace/outputs/implementation-report.md` |
| 质量报告 | `workspace/outputs/quality-report.md` |

## 当前阶段

in_progress - 技术规格书已完成，代码生成中
