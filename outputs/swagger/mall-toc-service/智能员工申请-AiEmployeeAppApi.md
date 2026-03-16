---
service: mall-toc-service
controller: AiEmployeeAppController
module: AiEmployeeApp
title: 智能员工申请
version: v1.0.0
updated_at: 2026-03-15
updated_by: P-2026-001-F-006
---

# 智能员工申请 - APP 端接口文档

## 基础信息

| 项目 | 值 |
|------|-----|
| 服务 | mall-toc-service |
| Controller | AiEmployeeAppController |
| 路径前缀 | `/mall-toc-service/app/api/v1/ai-employee` |
| Tag | 智能员工/申请与审核 |

---

## 接口列表

### 1. 智能员工功能介绍页

获取功能介绍页数据，含当前用户可用名额。

- **请求方式**: `GET`
- **请求路径**: `/mall-toc-service/app/api/v1/ai-employee/intro`
- **接口标识**: REQ-F006-01

#### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | object | 响应数据 |
| ├─ availableQuota | integer | 当前用户可用名额 |
| ├─ totalQuota | integer | 当前用户总名额 |

#### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "availableQuota": 3,
    "totalQuota": 5
  }
}
```

---

### 2. 提交智能员工申请

用户提交智能员工申请，含名额/商品代理/重复申请多项校验。

- **请求方式**: `POST`
- **请求路径**: `/mall-toc-service/app/api/v1/ai-employee/apply`
- **接口标识**: REQ-F006-02

#### 请求参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| jobTypeId | long | 是 | 岗位类型ID |
| spuCode | string | 否 | 代理商品SPU编码（商品销售岗必填，客服岗为null） |
| styleConfigId | long | 是 | 人设风格配置ID |
| socialLinks | string | 否 | 社交平台链接（可选，JSON数组字符串） |
| socialScreenshots | string | 否 | 社交截图URL列表（可选，JSON数组字符串） |

#### 请求示例

```json
{
  "jobTypeId": 1,
  "spuCode": "SPU20240315001",
  "styleConfigId": 2,
  "socialLinks": "[\"https://weibo.com/user1\", \"https://xiaohongshu.com/user2\"]",
  "socialScreenshots": "[\"https://cdn.example.com/img1.jpg\", \"https://cdn.example.com/img2.jpg\"]"
}
```

#### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | long | 新创建的员工ID |

#### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": 10001
}
```

---

### 3. 查询员工审核状态

查询指定员工的审核状态，驳回时返回驳回原因。

- **请求方式**: `GET`
- **请求路径**: `/mall-toc-service/app/api/v1/ai-employee/{employeeId}/status`
- **接口标识**: REQ-F006-03

#### 路径参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | long | 是 | 员工ID |

#### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | object | 响应数据 |
| ├─ employeeId | long | 员工ID |
| ├─ employeeNo | string | 员工编号，格式：AIM{yyyyMM}{序列号} |
| ├─ auditResult | integer | 审核状态：0=待审核 1=已驳回 2=已通过 |
| ├─ auditStatusDesc | string | 审核状态描述 |
| ├─ rejectReason | string | 驳回原因（审核驳回时有值） |

#### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "employeeId": 10001,
    "employeeNo": "AIM2025030001",
    "auditResult": 1,
    "auditStatusDesc": "已驳回",
    "rejectReason": "商品信息不符合要求"
  }
}
```

---

### 4. 用户员工列表（分页）

获取当前用户名下员工列表，支持 APP端聚合状态筛选。

- **请求方式**: `GET`
- **请求路径**: `/mall-toc-service/app/api/v1/ai-employee/list`
- **接口标识**: REQ-F006-04

#### 查询参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| status | integer | 否 | APP端聚合状态筛选：1=待审核/2=待激活/3=已激活，默认返回全部 |
| pageNum | integer | 否 | 页码，默认1 |
| pageSize | integer | 否 | 每页条数，默认10 |

#### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | object | 分页数据 |
| ├─ totalCount | long | 总记录数 |
| ├─ items | array | 员工列表 |
| ├─ ├─ employeeId | long | 员工ID |
| ├─ ├─ employeeNo | string | 员工编号，格式：AIM{yyyyMM}{序列号} |
| ├─ ├─ name | string | 员工名称 |
| ├─ ├─ jobType | object | 岗位类型 |
| ├─ ├─ ├─ id | long | 岗位类型ID |
| ├─ ├─ ├─ name | string | 岗位类型名称 |
| ├─ ├─ auditResult | integer | 审核状态：0=待审核/1=已驳回/2=已通过 |
| ├─ ├─ auditStatusDesc | string | 审核状态描述 |
| ├─ ├─ employeeStatus | integer | 员工状态：0=待激活/1=已上线/2=已暂停/3=已封禁，NULL=未通过审核 |
| ├─ ├─ employeeStatusDesc | string | 员工状态描述 |
| ├─ ├─ createTime | string | 创建时间，格式：yyyy-MM-dd HH:mm:ss |
| ├─ ├─ product | object | 代理商品信息（商品销售岗时有值，商城客服岗为null） |
| ├─ ├─ ├─ spuCode | string | 商品SPU编码 |
| ├─ ├─ ├─ spuName | string | 商品名称 |
| ├─ ├─ ├─ spuImage | string | 商品主图URL |
| ├─ ├─ ├─ spuPrice | number | 商品价格 |

#### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "totalCount": 2,
    "items": [
      {
        "employeeId": 10001,
        "employeeNo": "AIM2025030001",
        "name": "智能员工-001",
        "jobType": {
          "id": 1,
          "name": "商品销售岗"
        },
        "auditResult": 2,
        "auditStatusDesc": "已通过",
        "employeeStatus": 1,
        "employeeStatusDesc": "已上线",
        "createTime": "2025-03-15 10:30:00",
        "product": {
          "spuCode": "SPU20240315001",
          "spuName": "智能手表 Pro",
          "spuImage": "https://cdn.example.com/product1.jpg",
          "spuPrice": 1999.00
        }
      }
    ]
  }
}
```

---

### 5. 修改员工昵称

员工本人修改昵称，需通过内容审核（纯汉字1~10个）。

- **请求方式**: `POST`
- **请求路径**: `/mall-toc-service/app/api/v1/ai-employee/{employeeId}/update-nickname`
- **接口标识**: REQ-F008-09

#### 路径参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | long | 是 | 员工ID |

#### 请求参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| nickname | string | 是 | 新昵称（1~10个汉字，内容审核通过后生效） |

#### 请求示例

```json
{
  "nickname": "小明助手"
}
```

#### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | boolean | 是否成功 |

#### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

---

### 6. 注销员工

员工本人申请注销，软删除，封禁状态不可注销。

- **请求方式**: `POST`
- **请求路径**: `/mall-toc-service/app/api/v1/ai-employee/{employeeId}/cancel`
- **接口标识**: REQ-F008-10

#### 路径参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | long | 是 | 员工ID |

#### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | boolean | 是否成功 |

#### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

---

### 7. 申请表单-启用岗位类型列表

获取申请表单可选岗位类型，仅返回启用状态（status=1），按 sort_order ASC。

- **请求方式**: `GET`
- **请求路径**: `/mall-toc-service/app/api/v1/ai-employee/apply/job-types`
- **接口标识**: REQ-F006-09

#### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | array | 岗位类型列表 |
| ├─ id | long | 岗位类型ID |
| ├─ name | string | 岗位类型名称 |
| ├─ code | string | 岗位类型编码（前端据此判断是否为商品销售岗） |

#### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "name": "商品销售岗",
      "code": "PRODUCT_SALES"
    },
    {
      "id": 2,
      "name": "商城客服岗",
      "code": "CUSTOMER_SERVICE"
    }
  ]
}
```

---

### 8. 申请表单-启用人设风格列表

获取申请表单可选人设风格，仅返回启用状态（status=1），按 sort_order ASC。

- **请求方式**: `GET`
- **请求路径**: `/mall-toc-service/app/api/v1/ai-employee/apply/style-configs`
- **接口标识**: REQ-F006-10

#### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | array | 人设风格列表 |
| ├─ id | long | 风格配置ID |
| ├─ name | string | 风格名称 |
| ├─ description | string | 风格描述 |

#### 响应示例

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "name": "专业严谨",
      "description": "适合商务场景，语气正式专业"
    },
    {
      "id": 2,
      "name": "亲切友好",
      "description": "适合日常交流，语气温暖亲切"
    }
  ]
}
```

---

## 数据字典

### 审核状态（auditResult）

| 值 | 含义 |
|----|------|
| 0 | 待审核 |
| 1 | 已驳回 |
| 2 | 已通过 |

### 员工状态（employeeStatus）

| 值 | 含义 | 说明 |
|----|------|------|
| 0 | 待激活 | 审核通过但未激活 |
| 1 | 已上线 | 正常运行中 |
| 2 | 已暂停 | 暂时停用 |
| 3 | 已封禁 | 违规被封禁 |
| null | - | 未通过审核 |

### APP端聚合状态（status 查询参数）

| 值 | 含义 |
|----|------|
| 1 | 待审核（auditResult=0 或 auditResult=1） |
| 2 | 待激活（auditResult=2 且 employeeStatus=0） |
| 3 | 已激活（auditResult=2 且 employeeStatus IN (1,2,3)） |

---

## 错误码

| 错误码 | 说明 |
|--------|------|
| 200 | 操作成功 |
| 400 | 请求参数错误 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |
