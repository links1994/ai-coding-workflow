# Feature: F-001 岗位类型管理

## 基本信息

| 属性 | 值 |
|------|-----|
| Feature ID | F-001 |
| 名称 | 岗位类型管理 |
| 域 | 配置管理域 |
| 优先级 | P0 |
| 首次实现 | 2026-03-08 |

## 功能描述

运营人员管理智能员工岗位类型，支持增删改查及启用禁用。

## 服务分层

| 服务 | 层级 | 职责 |
|------|------|------|
| mall-admin | facade | 管理后台岗位类型接口 |
| mall-agent-employee-service | application | 岗位类型业务逻辑 |
| mall-inner-api | api | Feign 接口定义 |

## 接口清单

### 门面层

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /admin/api/v1/job-types | 岗位类型列表 |
| POST | /admin/api/v1/job-types | 新增岗位类型 |
| PUT | /admin/api/v1/job-types/{id} | 编辑岗位类型 |
| PUT | /admin/api/v1/job-types/{id}/status | 启用/禁用 |

### 应用层

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /inner/api/v1/job-types/list | 分页列表 |
| POST | /inner/api/v1/job-types/create | 创建 |
| PUT | /inner/api/v1/job-types/update | 更新 |
| PUT | /inner/api/v1/job-types/status | 状态变更 |
| DELETE | /inner/api/v1/job-types/delete | 删除 |

## 数据表

- [aim_agent_job_type](../schemas/aim_agent_job_type.md)

## 实现历史

| 版本 | 日期 | Program | 说明 |
|------|------|---------|------|
| 1.0 | 2026-03-08 | P-2026-001-F-001 | 初始实现 |

## 依赖关系

- **上游依赖**: 无
- **下游依赖**: F-006（员工申请审核）、F-008（运营管理）
