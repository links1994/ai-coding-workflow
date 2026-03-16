# Feature 实现报告: F-008 智能员工运营管理

> Feature ID: F-008
> 生成时间: 2026-03-16
> 状态: 已完成

## 1. 服务分层分析

| 服务名称 | 分层 | 生成内容 | 文件路径 |
|----------|------|----------|----------|
| mall-admin | facade | EmployeeManageAdminController（10接口） | controller/agent/EmployeeManageAdminController.java |
| mall-admin | facade | EmployeeManageAdminServiceImpl | service/impl/EmployeeManageAdminServiceImpl.java |
| mall-admin | facade | Request/Response DTO | dto/request/agent/, dto/response/agent/ |
| mall-toc-service | facade | AiEmployeeAppController扩展（2接口） | controller/AiEmployeeAppController.java |
| mall-agent-employee-service | application | AiEmployeeInnerController扩展（6接口） | controller/inner/AiEmployeeInnerController.java |
| mall-agent-employee-service | application | AiEmployeeApplicationServiceImpl | service/impl/AiEmployeeApplicationServiceImpl.java |
| mall-agent-employee-service | application | AiEmployeeManageServiceImpl | service/impl/AiEmployeeManageServiceImpl.java |
| mall-agent-employee-service | application | AiEmployeeQueryServiceImpl | service/impl/AiEmployeeQueryServiceImpl.java |
| mall-inner-api | api | AgentEmployeeRemoteService扩展 | feign/AgentEmployeeRemoteService.java |
| mall-inner-api | api | EmployeeStatusEnum | enums/EmployeeStatusEnum.java |

## 2. 接口清单

### 2.1 门面层接口（mall-admin）

| 接口 | 路径 | 方法 | 描述 |
|------|------|------|------|
| list | /admin/api/v1/employee-manage | GET | 员工运营管理列表（分页） |
| getStats | /admin/api/v1/employee-manage/stats | GET | 员工统计头部数据 |
| getDetail | /admin/api/v1/employee-manage/{employeeId}/detail | GET | 员工详情 |
| forceOffline | /admin/api/v1/employee-manage/{employeeId}/force-offline | POST | 强制离线 |
| restoreOnline | /admin/api/v1/employee-manage/{employeeId}/restore-online | POST | 恢复上线 |
| ban | /admin/api/v1/employee-manage/{employeeId}/ban | POST | 封禁员工 |
| warn | /admin/api/v1/employee-manage/{employeeId}/warn | POST | 警告员工 |
| updateCommission | /admin/api/v1/employee-manage/{employeeId}/update-commission | POST | 修改佣金比例 |
| listJobTypes | /admin/api/v1/employee-manage/job-types | GET | 岗位类型下拉列表 |
| listEmployeeStatusOptions | /admin/api/v1/employee-manage/employee-status-options | GET | 员工状态枚举列表 |

### 2.2 门面层接口（mall-toc-service）

| 接口 | 路径 | 方法 | 描述 |
|------|------|------|------|
| updateNickname | /app/api/v1/ai-employee/{employeeId}/update-nickname | POST | 修改昵称（本人操作） |
| cancel | /app/api/v1/ai-employee/{employeeId}/cancel | POST | 注销员工（本人操作） |

### 2.3 内部服务接口（mall-agent-employee-service）

| 接口 | 路径 | 方法 | 描述 |
|------|------|------|------|
| forceOfflineEmployee | /inner/api/v1/ai-employee/force-offline | POST | 强制离线 |
| restoreOnlineEmployee | /inner/api/v1/ai-employee/restore-online | POST | 恢复上线 |
| banEmployee | /inner/api/v1/ai-employee/ban | POST | 封禁 |
| warnEmployee | /inner/api/v1/ai-employee/warn | POST | 警告 |
| updateCommissionRate | /inner/api/v1/ai-employee/update-commission | POST | 修改佣金比例 |
| updateEmployeeNickname | /inner/api/v1/ai-employee/update-nickname | POST | 修改昵称 |
| cancelEmployee | /inner/api/v1/ai-employee/cancel | POST | 注销员工 |
| pageEmployeesForManage | /inner/api/v1/ai-employee/page | POST | 运营管理列表分页 |
| getEmployeeStats | /inner/api/v1/ai-employee/stats | GET | 员工统计 |

## 3. 关键设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| employee_status 枚举 | 6种状态（0-5） | 覆盖完整生命周期：待激活/待上线/营业中/强制离线/已封禁/已注销 |
| 统计数据来源 | 直接查询主表 | 本期占位返回，F-013实现后迁移至统计表 |
| 封禁不释放名额 | 仅注销时释放 | 业务规则：封禁可恢复，注销不可逆 |
| 警告推送降级 | try-catch 处理 | 推送失败不影响主流程，仅记录日志 |
| 注销事务 | 3步事务（更新状态+释放名额+解绑代理） | 保证数据一致性 |

## 4. 验收标准验证

| 验收标准 | 状态 | 说明 |
|----------|------|------|
| 员工列表查询（含筛选） | ✅ 完成 | 支持 employeeStatus/jobTypeId/keyword 三维筛选 |
| 员工统计（总数/在线数/累计成交额） | ✅ 完成 | 成交额本期占位返回0 |
| 状态变更（强制离线/恢复上线/警告/封禁） | ✅ 完成 | 状态机转换校验完整 |
| 佣金比例修改 | ✅ 完成 | 范围校验 0.00~100.00 |
| 用户主动下线 | ✅ 完成 | 本人校验 + 事务处理 |
| 修改昵称 | ✅ 完成 | 内容审核 + 本人校验 |
| 注销员工 | ✅ 完成 | 事务：状态更新+名额释放+代理解绑 |

## 5. 数据库变更

本期无需新增数据库表，所有运营管理数据存储在 `aim_agent_employee` 主表中。

`aim_agent_employee_stats` 统计表预留，F-013 实现后启用。

---

*报告生成时间: 2026-03-16*
