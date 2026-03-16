---
service: mall-toc-service
controller: AgentProductAppController
module: AgentProductApp
title: 代理商品查询
version: v1.0.1
updated_at: 2026-03-16
updated_by: P-2026-001-F-004
---

# 代理商品查询 API

> **服务**: mall-toc-service  
> **Controller**: AgentProductAppController  
> **Tag**: 智能员工管理/代理商品  
> **Base URL**: `/mall-toc-service/app/api/v1/agent-products`

---

## 接口列表

### 1. 申请表单-获取商品后台类目列表

获取申请表单中可代理商品的后台类目列表，内部自动从代理商品配置获取 frontCategoryConfigCode，无需前端传参。

| 属性 | 值 |
|------|-----|
| **接口路径** | `GET /mall-toc-service/app/api/v1/agent-products/apply-categories` |
| **接口说明** | REQ-F006-11：申请表单 - 获取可代理商品后台类目列表（无参） |

#### 请求参数

无

#### 响应数据

**成功响应 (200)**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| code | Integer | 是 | 状态码，成功为 200 |
| message | String | 是 | 响应消息 |
| data | Array | 是 | 后台类目列表 |
| data[].categoryCode | String | 是 | 后台类目编码 |
| data[].categoryName | String | 是 | 后台类目名称 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "categoryCode": "CAT001",
      "categoryName": "数码产品"
    },
    {
      "categoryCode": "CAT002",
      "categoryName": "家用电器"
    }
  ]
}
```

---

### 2. 按后台类目搜索可代理商品

用户端按后台类目编码查询可代理商品（agent_status=0），支持 keyword 关键词过滤，分页返回。

| 属性 | 值 |
|------|-----|
| **接口路径** | `GET /mall-toc-service/app/api/v1/agent-products` |
| **接口说明** | 按后台类目搜索可代理商品（agent_status=0，分页） |

#### 请求参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| backendCategoryCode | String | 是 | - | 后台类目编码 |
| keyword | String | 否 | - | 商品名称关键词，模糊查询 |
| pageNum | Integer | 否 | 1 | 页码 |
| pageSize | Integer | 否 | 20 | 每页条数 |

#### 响应数据

**成功响应 (200)**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| code | Integer | 是 | 状态码，成功为 200 |
| message | String | 是 | 响应消息 |
| data | Object | 是 | 分页数据 |
| data.items | Array | 是 | 商品列表 |
| data.items[].spuCode | String | 是 | 商品SPU编码 |
| data.items[].spuName | String | 是 | 商品名称 |
| data.items[].mainImage | String | 是 | 商品主图 URL |
| data.items[].spuPrice | BigDecimal | 是 | 商品价格 |
| data.items[].backendCategoryCode | String | 是 | 后台三级类目编码 |
| data.totalCount | Long | 是 | 总记录数 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "items": [
      {
        "spuCode": "SPU20240001",
        "spuName": "iPhone 15 Pro",
        "mainImage": "https://cdn.example.com/images/iphone15.jpg",
        "spuPrice": 8999.00,
        "backendCategoryCode": "CAT001"
      },
      {
        "spuCode": "SPU20240002",
        "spuName": "MacBook Pro 16",
        "mainImage": "https://cdn.example.com/images/macbook.jpg",
        "spuPrice": 19999.00,
        "backendCategoryCode": "CAT001"
      }
    ],
    "totalCount": 100
  }
}
```

**错误响应 (400)**

当 `backendCategoryCode` 为空时返回：

```json
{
  "code": 400,
  "message": "后台类目编码不能为空",
  "data": null
}
```

---

## 数据模型

### BackendCategoryAppResponse

后台类目响应（用户端）

| 字段 | 类型 | 说明 |
|------|------|------|
| categoryCode | String | 后台类目编码 |
| categoryName | String | 后台类目名称 |

### AgentProductAppResponse

代理商品响应（用户端）

| 字段 | 类型 | 说明 |
|------|------|------|
| spuCode | String | 商品SPU编码 |
| spuName | String | 商品名称 |
| mainImage | String | 商品主图 URL |
| spuPrice | BigDecimal | 商品价格 |
| backendCategoryCode | String | 后台三级类目编码 |

---

## 变更日志

| 版本 | 日期 | 变更内容 | 变更人 |
|------|------|----------|--------|
| v1.0.1 | 2026-03-16 | 新增 spuPrice 字段 | P-2026-001-F-004 |
| v1.0.0 | 2026-03-15 | 初始版本 | P-2026-001-F-004 |
