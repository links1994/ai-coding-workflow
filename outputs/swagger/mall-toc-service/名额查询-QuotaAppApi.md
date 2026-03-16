---
service: mall-toc-service
controller: QuotaAppController
module: QuotaApp
title: 名额查询
version: v1.0.0
updated_at: 2026-03-15
updated_by: P-2026-001-F-003
---

# 名额查询

## 基本信息

| 属性 | 值 |
|------|------|
| 服务 | mall-toc-service |
| Controller | QuotaAppController |
| 模块 | QuotaApp |
| 基础路径 | `/mall-toc-service/app/api/v1/quota` |
| Tag | 智能员工管理/名额查询 |

---

## 接口列表

### 1. 查询当前用户可用名额

查询当前登录用户的总名额、已用名额和可用名额。

#### 请求信息

| 属性 | 值 |
|------|------|
| 接口名称 | 查询当前用户可用名额 |
| 请求方法 | GET |
| 请求路径 | `/mall-toc-service/app/api/v1/quota/my-quota` |

#### 请求参数

无

#### 响应参数

##### 成功响应 (200)

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 响应码，0 表示成功 |
| message | String | 响应消息 |
| data | Object | 用户名额信息 |
| data.totalQuota | Integer | 总名额（初始+解锁） |
| data.usedQuota | Integer | 已用名额 |
| data.availableQuota | Integer | 可用名额（totalQuota - usedQuota） |

##### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "totalQuota": 10,
    "usedQuota": 3,
    "availableQuota": 7
  }
}
```

#### 错误码

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| 500 | 服务器内部错误 |

---

## 数据模型

### UserQuotaResponse

用户名额信息响应对象

| 字段名 | 类型 | 说明 |
|--------|------|------|
| totalQuota | Integer | 总名额（初始+解锁） |
| usedQuota | Integer | 已用名额 |
| availableQuota | Integer | 可用名额（totalQuota - usedQuota） |
