# Feature 实现报告: F-007 智能员工解锁与激活

> Feature ID: F-007
> 生成时间: 2026-03-15
> 状态: 已完成（从代码反向生成文档）

## 1. 服务分层分析

| 服务名称 | 分层 | 生成内容 |
|----------|------|----------|
| mall-toc-service | facade | ActivationAppController（4接口） |
| mall-admin | facade | ActivationAdminController（3接口） |
| mall-agent-employee-service | application | ActivationInnerController（7接口） |
| mall-inner-api | api | ActivationRemoteService（Feign接口） |

## 2. 接口实现清单

### 2.1 APP端接口（mall-toc-service）

| 接口ID | 接口名称 | HTTP方法 | 路径 | 状态 |
|--------|----------|----------|------|------|
| REQ-F007-01 | 查询解锁进度 | GET | /app/api/v1/ai-employee/{employeeId}/unlock-progress | ✅ 已实现 |
| REQ-F007-02 | 获取邀请码 | POST | /app/api/v1/ai-employee/{employeeId}/share | ✅ 已实现 |
| REQ-F007-03 | 落地页详情 | GET | /app/api/v1/ai-employee/unlock-detail | ✅ 已实现 |
| REQ-F007-04 | 好友助力解锁 | POST | /app/api/v1/ai-employee/help-unlock | ✅ 已实现 |

### 2.2 管理端接口（mall-admin）

| 接口ID | 接口名称 | HTTP方法 | 路径 | 状态 |
|--------|----------|----------|------|------|
| REQ-F007-05 | 激活记录列表 | GET | /admin/api/v1/activation-records | ✅ 已实现 |
| REQ-F007-06 | 查询激活配置 | GET | /admin/api/v1/activation-config | ✅ 已实现 |
| REQ-F007-07 | 保存激活配置 | PUT | /admin/api/v1/activation-config | ✅ 已实现 |

### 2.3 Inner API（mall-agent-employee-service）

| 接口ID | 接口名称 | HTTP方法 | 路径 | 状态 |
|--------|----------|----------|------|------|
| REQ-F007-INNER-01 | 查询解锁进度 | GET | /inner/api/v1/activation/progress | ✅ 已实现 |
| REQ-F007-INNER-02 | 获取邀请码 | GET | /inner/api/v1/activation/invite-code | ✅ 已实现 |
| REQ-F007-INNER-03 | 落地页详情 | GET | /inner/api/v1/activation/unlock-detail | ✅ 已实现 |
| REQ-F007-INNER-04 | 好友助力解锁 | POST | /inner/api/v1/activation/help-unlock | ✅ 已实现 |
| REQ-F007-INNER-05 | 激活记录列表 | POST | /inner/api/v1/activation/records | ✅ 已实现 |
| REQ-F007-INNER-06 | 查询激活配置 | GET | /inner/api/v1/activation/config | ✅ 已实现 |
| REQ-F007-INNER-07 | 保存激活配置 | POST | /inner/api/v1/activation/config/save | ✅ 已实现 |

## 3. 关键设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 邀请码生成 | Base62(employeeId) | 简洁、可逆、无需存储映射表 |
| 邀请码存储 | 懒生成策略 | 首次分享时生成，减少存储压力 |
| 助力记录表 | 独立流水表 | 与员工主表解耦，支持审计追溯 |
| 删除策略 | 软删除 | 保留助力记录用于审计 |
| 用户姓名获取 | 批量查询 ClientRemoteService | 减少远程调用次数 |
| 解锁人数配置 | 通用配置表 aim_agent_configs | 与名额配置共用表结构 |

## 4. 数据模型实现

### 4.1 数据库表

| 表名 | 说明 | 删除策略 |
|------|------|----------|
| aim_agent_activation_record | 激活记录流水表 | 软删除（is_deleted） |

### 4.2 员工表扩展

| 字段名 | 类型 | 说明 |
|--------|------|------|
| invite_code | VARCHAR(16) | 邀请码（Base62编码） |

### 4.3 配置项

| biz_type | config_key | 默认值 | 说明 |
|----------|------------|--------|------|
| QUOTA | UNLOCK_PERSON_COUNT | 3 | 解锁所需人数阈值 |
| ACTIVATION | MAX_HELP_PER_USER | 0 | 单用户最多助力员工数（0=无限制） |

## 5. 错误码实现

| 错误码 | 枚举名 | 说明 |
|--------|--------|------|
| 40073101 | ACTIVATION_EMPLOYEE_NOT_APPROVED | 员工未通过审核，无法生成邀请码 |
| 40073102 | ACTIVATION_ALREADY_UNLOCKED | 员工已完成解锁，无需再助力 |
| 40073103 | ACTIVATION_ALREADY_HELPED | 您已助力过该员工 |
| 40073104 | ACTIVATION_CANNOT_HELP_SELF | 不可为自己的员工助力 |
| 40073105 | ACTIVATION_HELP_LIMIT_EXCEEDED | 您的助力次数已达上限 |
| 40073106 | ACTIVATION_INVITE_CODE_NOT_FOUND | 邀请码无效或已失效 |

## 6. 验收标准验证

| 验收标准 | 状态 |
|----------|------|
| APP端查询解锁进度 | ✅ 已实现 |
| APP端获取邀请码（懒生成） | ✅ 已实现 |
| 落地页详情查询（无需登录） | ✅ 已实现 |
| 好友助力解锁（幂等、不可自助、不可重复） | ✅ 已实现 |
| 助力人数达标自动解锁 | ✅ 已实现 |
| 管理端激活记录列表查询 | ✅ 已实现 |
| 管理端激活配置查询/保存 | ✅ 已实现 |

## 7. 实现类清单

### 7.1 mall-toc-service

```
src/main/java/com/aim/mall/agent/
├── controller/
│   └── ActivationAppController.java
├── service/
│   ├── ActivationAppApplicationService.java
│   └── impl/ActivationAppApplicationServiceImpl.java
└── dto/
    ├── request/HelpUnlockRequest.java
    └── response/
        ├── ShareResponse.java
        ├── UnlockProgressResponse.java
        └── UnlockDetailResponse.java
```

### 7.2 mall-admin

```
src/main/java/com/aim/mall/admin/
├── controller/agent/
│   └── ActivationAdminController.java
├── service/
│   ├── ActivationAdminApplicationService.java
│   └── impl/ActivationAdminApplicationServiceImpl.java
└── dto/
    ├── request/agent/
    │   ├── ActivationConfigSaveRequest.java
    │   └── ActivationRecordListRequest.java
    └── response/agent/
        ├── ActivationConfigResponse.java
        └── ActivationRecordResponse.java
```

### 7.3 mall-agent-employee-service

```
src/main/java/com/aim/mall/agent/
├── controller/inner/
│   └── ActivationInnerController.java
├── domain/
│   ├── entity/AimAgentActivationRecordDO.java
│   └── dto/ActivationRecordPageQuery.java
├── mapper/
│   └── AimAgentActivationRecordMapper.java
└── service/
    ├── ActivationApplicationService.java
    ├── ActivationQueryService.java
    ├── ActivationManageService.java
    └── impl/
        ├── ActivationApplicationServiceImpl.java
        ├── ActivationQueryServiceImpl.java
        └── ActivationManageServiceImpl.java

src/main/resources/mapper/
└── AimAgentActivationRecordMapper.xml
```

### 7.4 mall-inner-api

```
mall-agent-api/src/main/java/com/aim/mall/agent/api/
├── feign/
│   └── ActivationRemoteService.java
└── dto/
    ├── request/
    │   ├── HelpUnlockApiRequest.java
    │   ├── ActivationRecordListApiRequest.java
    │   └── ActivationConfigSaveApiRequest.java
    └── response/
        ├── UnlockProgressApiResponse.java
        ├── UnlockDetailApiResponse.java
        ├── ActivationRecordApiResponse.java
        └── ActivationConfigApiResponse.java
```

---

*报告生成时间: 2026-03-15*
