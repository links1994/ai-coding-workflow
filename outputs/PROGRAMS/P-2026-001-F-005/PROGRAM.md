# Program: F-005 话术模板管理

## 基本信息

| 属性 | 值 |
|------|-----|
| Program ID | P-2026-001-F-005 |
| 名称 | F-005 话术模板管理 |
| 类型 | implementation |
| 工作流 | feature-implementation |
| Feature ID | F-005 |
| 状态 | completed |

## 目标

实现 F-005 话术模板管理的完整功能，包含：
- **应用层**（mall-agent-employee-service）：话术模板 CRUD + xlsx 批量导入
- **门面层**（mall-admin）：管理后台话术模板接口
- **基础数据层**（mall-basic-service）：下载模板配置管理

## 服务分层

```
mall-admin（门面层）
    ScriptTemplateAdminController
    └── AgentEmployeeRemoteService（Feign）
    └── DownloadTemplateRemoteService（Feign）
            │
            ↓
mall-agent-employee-service（应用层）
    ScriptTemplateInnerController
    └── ScriptTemplateApplicationService
            │
            ↓
mall-basic-service（基础数据层）
    DownloadTemplateInnerController
    └── aim_download_template
```

## 输出产物

| 产物 | 路径 |
|------|------|
| 技术规格书 | `workspace/outputs/tech-spec.md` | 代码生成的唯一可信源（Markdown 格式，内嵌时序图）|
| 实现报告 | `workspace/outputs/implementation-report.md` |
| 质量报告 | `workspace/outputs/quality-report.md` |

## 当前阶段

completed - 实现已完成并部署
