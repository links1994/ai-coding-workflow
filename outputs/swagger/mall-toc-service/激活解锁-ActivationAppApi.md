---
service: mall-toc-service
controller: ActivationAppController
module: ActivationApp
title: 激活解锁
version: v1.0.0
updated_at: 2026-03-15
updated_by: P-2026-001-F-007
---

# 激活解锁 API 文档

> 服务：mall-toc-service  
> 模块：智能员工/激活解锁  
> 基础路径：`/mall-toc-service/app/api/v1/ai-employee`

---

## 接口概览

| 序号 | 接口名称 | 请求方式 | 路径 | 说明 |
|------|----------|----------|------|------|
| 1 | 解锁进度查询 | GET | `/mall-toc-service/app/api/v1/ai-employee/{employeeId}/unlock-progress` | 查询指定员工的解锁进度 |
| 2 | 获取邀请码 | POST | `/mall-toc-service/app/api/v1/ai-employee/{employeeId}/share` | 获取员工邀请码，懒生成 |
| 3 | 落地页详情 | GET | `/mall-toc-service/app/api/v1/ai-employee/unlock-detail` | 根据邀请码查询落地页详情 |
| 4 | 好友助力解锁 | POST | `/mall-toc-service/app/api/v1/ai-employee/help-unlock` | 好友为员工提交助力 |

---

## 1. 解锁进度查询

### 基本信息

- **接口名称**：查询员工解锁进度
- **请求方式**：GET
- **请求路径**：`/mall-toc-service/app/api/v1/ai-employee/{employeeId}/unlock-progress`
- **接口描述**：查询指定员工的解锁进度（已助力人数、目标人数、是否已解锁）

### 请求参数

#### 路径参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | Long | 是 | 员工ID |

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 响应码，200表示成功 |
| message | String | 响应消息 |
| data | Object | 响应数据 |
| data.employeeId | Long | 员工ID |
| data.currentCount | Integer | 当前助力人数 |
| data.targetCount | Integer | 目标助力人数 |
| data.unlocked | Boolean | 是否已解锁 |

### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "employeeId": 10001,
    "currentCount": 3,
    "targetCount": 5,
    "unlocked": false
  }
}
```

---

## 2. 获取邀请码

### 基本信息

- **接口名称**：获取员工邀请码
- **请求方式**：POST
- **请求路径**：`/mall-toc-service/app/api/v1/ai-employee/{employeeId}/share`
- **接口描述**：获取员工邀请码，首次调用时生成并持久化，用于组装微信小程序分享参数

### 请求参数

#### 路径参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | Long | 是 | 员工ID |

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 响应码，200表示成功 |
| message | String | 响应消息 |
| data | Object | 响应数据 |
| data.inviteCode | String | 邀请码（Base62编码） |

### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "inviteCode": "a1B2c3D4"
  }
}
```

---

## 3. 落地页详情

### 基本信息

- **接口名称**：落地页详情查询
- **请求方式**：GET
- **请求路径**：`/mall-toc-service/app/api/v1/ai-employee/unlock-detail`
- **接口描述**：根据 inviteCode 查询员工信息用于落地页展示

### 请求参数

#### 查询参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| inviteCode | String | 是 | 邀请码 |

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 响应码，200表示成功 |
| message | String | 响应消息 |
| data | Object | 响应数据 |
| data.employeeId | Long | 员工ID |
| data.employeeNo | String | 员工编号 |
| data.employeeName | String | 员工名称 |
| data.jobTypeName | String | 岗位类型名称 |
| data.spuCode | String | 商品SPU编码 |
| data.styleConfigName | String | 人设风格名称 |
| data.currentCount | Integer | 当前助力人数 |
| data.targetCount | Integer | 目标助力人数 |

### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "employeeId": 10001,
    "employeeNo": "EMP20240315001",
    "employeeName": "智能导购员小美",
    "jobTypeName": "导购员",
    "spuCode": "SPU123456",
    "styleConfigName": "甜美可爱",
    "currentCount": 3,
    "targetCount": 5
  }
}
```

---

## 4. 好友助力解锁

### 基本信息

- **接口名称**：好友助力解锁
- **请求方式**：POST
- **请求路径**：`/mall-toc-service/app/api/v1/ai-employee/help-unlock`
- **接口描述**：好友为员工提交助力，幂等，助力人数达标自动解锁

### 请求参数

#### 请求体

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| inviteCode | String | 是 | 邀请码 |

### 请求示例

```json
{
  "inviteCode": "a1B2c3D4"
}
```

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 响应码，200表示成功 |
| message | String | 响应消息 |
| data | Object | 响应数据 |
| data.employeeId | Long | 员工ID |
| data.currentCount | Integer | 当前助力人数 |
| data.targetCount | Integer | 目标助力人数 |
| data.unlocked | Boolean | 是否已解锁 |

### 响应示例

```json
{
  "code": 200,
  "message": "助力成功",
  "data": {
    "employeeId": 10001,
    "currentCount": 4,
    "targetCount": 5,
    "unlocked": false
  }
}
```

---

## 数据模型

### UnlockProgressResponse

| 字段名 | 类型 | 说明 |
|--------|------|------|
| employeeId | Long | 员工ID |
| currentCount | Integer | 当前助力人数 |
| targetCount | Integer | 目标助力人数 |
| unlocked | Boolean | 是否已解锁 |

### ShareResponse

| 字段名 | 类型 | 说明 |
|--------|------|------|
| inviteCode | String | 邀请码（Base62编码） |

### UnlockDetailResponse

| 字段名 | 类型 | 说明 |
|--------|------|------|
| employeeId | Long | 员工ID |
| employeeNo | String | 员工编号 |
| employeeName | String | 员工名称 |
| jobTypeName | String | 岗位类型名称 |
| spuCode | String | 商品SPU编码 |
| styleConfigName | String | 人设风格名称 |
| currentCount | Integer | 当前助力人数 |
| targetCount | Integer | 目标助力人数 |

### HelpUnlockRequest

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| inviteCode | String | 是 | 邀请码 |

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 操作成功 |
| 400 | 请求参数错误 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

*文档生成时间：2026-03-15*  
*关联需求：P-2026-001-F-007*
