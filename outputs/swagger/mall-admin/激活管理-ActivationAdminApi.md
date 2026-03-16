---
service: mall-admin
controller: ActivationAdminController
module: ActivationAdmin
title: 激活管理
version: v1.0.0
updated_at: 2026-03-16
updated_by: P-2026-001-F-007
---

# 激活管理

> **Tag**: 智能体管理平台/激活管理  
> **Base URL**: `/mall-admin/admin/api/v1`

---

## 接口概览

| 序号 | 接口名称 | 请求方法 | 路径 | 说明 |
|------|----------|----------|------|------|
| 1 | 激活记录列表查询 | GET | `/mall-admin/admin/api/v1/activation-records` | 按员工编号/邀请者/助力人/日期范围筛选，分页返回 |
| 2 | 查询激活配置 | GET | `/mall-admin/admin/api/v1/activation-config` | 查询激活配置（单用户最多可助力员工数） |
| 3 | 保存激活配置 | PUT | `/mall-admin/admin/api/v1/activation-config` | 保存激活配置（maxHelpPerUser） |

---

## 1. 激活记录列表查询

### 基本信息

- **接口名称**: 激活记录列表查询
- **请求方法**: GET
- **请求路径**: `/mall-admin/admin/api/v1/activation-records`
- **接口描述**: 按员工编号/邀请者/助力人/日期范围筛选，分页返回

### 请求参数

#### Query 参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeNo | string | 否 | 员工编号（模糊查询） |
| inviterUserId | integer | 否 | 邀请者用户ID |
| helperUserId | integer | 否 | 助力人用户ID |
| startDate | string | 否 | 开始日期，格式：yyyy-MM-dd |
| endDate | string | 否 | 结束日期，格式：yyyy-MM-dd |
| pageNum | integer | 否 | 页码，默认1 |
| pageSize | integer | 否 | 每页数量，默认10 |

### 响应参数

#### 响应体结构

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | object | 分页数据 |
| data.totalCount | integer | 总记录数 |
| data.items | array | 激活记录列表 |
| data.items[].id | integer | 记录ID |
| data.items[].employeeId | integer | 员工ID |
| data.items[].employeeNo | string | 员工编号 |
| data.items[].employeeName | string | 员工名称 |
| data.items[].inviterUserId | integer | 邀请者用户ID |
| data.items[].inviterUserName | string | 邀请者用户名 |
| data.items[].helperUserId | integer | 助力人用户ID |
| data.items[].helperUserName | string | 助力人用户名 |
| data.items[].createTime | string | 助力时间，格式：yyyy-MM-dd HH:mm:ss |

### 请求示例

```http
GET /mall-admin/admin/api/v1/activation-records?employeeNo=E001&pageNum=1&pageSize=10
Content-Type: application/json
```

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "totalCount": 100,
    "items": [
      {
        "id": 1,
        "employeeId": 1001,
        "employeeNo": "E001",
        "employeeName": "张三",
        "inviterUserId": 2001,
        "inviterUserName": "李四",
        "helperUserId": 3001,
        "helperUserName": "王五",
        "createTime": "2026-03-15 10:30:00"
      }
    ]
  }
}
```

---

## 2. 查询激活配置

### 基本信息

- **接口名称**: 查询激活配置
- **请求方法**: GET
- **请求路径**: `/mall-admin/admin/api/v1/activation-config`
- **接口描述**: 查询激活配置（单用户最多可助力员工数）

### 请求参数

无

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | object | 激活配置数据 |
| data.maxHelpPerUser | integer | 单用户最多可助力员工数（0=无限制） |

### 请求示例

```http
GET /mall-admin/admin/api/v1/activation-config
Content-Type: application/json
```

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "maxHelpPerUser": 5
  }
}
```

---

## 3. 保存激活配置

### 基本信息

- **接口名称**: 保存激活配置
- **请求方法**: PUT
- **请求路径**: `/mall-admin/admin/api/v1/activation-config`
- **接口描述**: 保存激活配置（maxHelpPerUser）

### 请求参数

#### Body 参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| maxHelpPerUser | integer | 是 | 单用户最多可助力员工数（0=无限制，>0则限制助力数量） |

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | null | 无数据返回 |

### 请求示例

```http
PUT /mall-admin/admin/api/v1/activation-config
Content-Type: application/json

{
  "maxHelpPerUser": 5
}
```

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": null
}
```

---

## 数据模型

### ActivationRecordListRequest

激活记录列表查询请求

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeNo | string | 否 | 员工编号（模糊查询，可选） |
| inviterUserId | integer | 否 | 邀请者用户ID（可选） |
| helperUserId | integer | 否 | 助力人用户ID（可选） |
| startDate | string | 否 | 开始日期（可选，格式：yyyy-MM-dd） |
| endDate | string | 否 | 结束日期（可选，格式：yyyy-MM-dd） |
| pageNum | integer | 否 | 页码，默认1 |
| pageSize | integer | 否 | 每页数量，默认10 |

### ActivationConfigSaveRequest

保存激活配置请求

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| maxHelpPerUser | integer | 是 | 单用户最多可助力员工数（0=无限制，>0则限制助力数量） |

### ActivationRecordResponse

激活记录响应

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | integer | 记录ID |
| employeeId | integer | 员工ID |
| employeeNo | string | 员工编号 |
| employeeName | string | 员工名称 |
| inviterUserId | integer | 邀请者用户ID |
| inviterUserName | string | 邀请者用户名 |
| helperUserId | integer | 助力人用户ID |
| helperUserName | string | 助力人用户名 |
| createTime | string | 助力时间，格式：yyyy-MM-dd HH:mm:ss |

### ActivationConfigResponse

激活配置响应

| 字段名 | 类型 | 说明 |
|--------|------|------|
| maxHelpPerUser | integer | 单用户最多可助力员工数（0=无限制） |

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| 500 | 系统内部错误 |
| 400 | 请求参数错误 |
| 401 | 未授权/登录已过期 |
| 403 | 无权限访问 |

---

*文档生成时间: 2026-03-16*
