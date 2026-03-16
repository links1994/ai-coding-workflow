---
service: mall-admin
controller: AgentProductAdminController
module: AgentProductAdmin
title: 代理商品管理
version: v1.0.1
updated_at: 2026-03-16
updated_by: P-2026-001-F-004
---

# 代理商品管理

> **Tag**: 智能体管理平台/代理商品管理  
> **Base URL**: `/mall-admin/admin/api/v1/agent-products`

---

## 接口概览

| 序号 | 接口名称 | 请求方法 | 路径 | 说明 |
|------|----------|----------|------|------|
| 1 | 代理商品列表查询 | GET | `/mall-admin/admin/api/v1/agent-products` | 分页查询代理商品池 |
| 2 | 批量导入代理商品 | POST | `/mall-admin/admin/api/v1/agent-products/import` | 上传 xlsx 文件批量导入 |
| 3 | 移除代理商品 | DELETE | `/mall-admin/admin/api/v1/agent-products/{spuCode}` | 逻辑删除代理商品 |
| 4 | 获取后台类目下拉列表 | GET | `/mall-admin/admin/api/v1/agent-products/backend-categories` | 返回对应后台类目列表 |
| 5 | 获取导入模板下载链接 | GET | `/mall-admin/admin/api/v1/agent-products/import-template` | 返回模板文件 OSS 链接 |
| 6 | 获取代理商品类目配置 | GET | `/mall-admin/admin/api/v1/agent-products/category-config` | 查询前台类目配置编码 |
| 7 | 保存代理商品类目配置 | POST | `/mall-admin/admin/api/v1/agent-products/category-config` | 配置前台类目编码 |
| 8 | 统计代理商品数据 | GET | `/mall-admin/admin/api/v1/agent-products/stat` | 返回代理商品统计数据 |

---

## 1. 代理商品列表查询

### 基本信息

- **接口名称**: 代理商品列表查询
- **请求方法**: GET
- **请求路径**: `/mall-admin/admin/api/v1/agent-products`
- **接口描述**: 分页查询代理商品池，支持按商品名称/编码/代理状态/后台类目筛选

### 请求参数

#### Query 参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| spuName | string | 否 | 商品名称（左前缀查询） |
| spuCode | string | 否 | 商品SPU编码（左前缀查询） |
| agentStatus | integer | 否 | 代理状态：0-未代理，1-已代理 |
| backendCategoryCode | string | 否 | 后台类目编码 |
| pageNum | integer | 否 | 页码，默认1 |
| pageSize | integer | 否 | 每页条数，默认20 |

### 响应参数

#### 响应体结构

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | object | 分页数据 |
| data.totalCount | integer | 总记录数 |
| data.items | array | 代理商品列表 |
| data.items[].id | integer | 主键ID |
| data.items[].spuCode | string | 商品SPU编码 |
| data.items[].spuName | string | 商品名称 |
| data.items[].spuPrice | BigDecimal | 商品价格 |
| data.items[].mainImage | string | 商品主图 URL |
| data.items[].backendCategoryCode | string | 后台三级类目编码 |
| data.items[].agentStatus | integer | 代理状态：0-未代理，1-已代理 |
| data.items[].createTime | string | 创建时间，格式：yyyy-MM-dd HH:mm:ss |

### 请求示例

```http
GET /mall-admin/admin/api/v1/agent-products?spuName=手机&agentStatus=1&pageNum=1&pageSize=20
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
        "spuCode": "SPU001",
        "spuName": "智能手机",
        "spuPrice": 8999.00,
        "mainImage": "https://example.com/image.jpg",
        "backendCategoryCode": "CAT001",
        "agentStatus": 1,
        "createTime": "2026-03-15 10:30:00"
      }
    ]
  }
}
```

---

## 2. 批量导入代理商品

### 基本信息

- **接口名称**: 批量导入代理商品
- **请求方法**: POST
- **请求路径**: `/mall-admin/admin/api/v1/agent-products/import`
- **Content-Type**: `multipart/form-data`
- **接口描述**: 上传 xlsx 文件批量导入；全部成功返回 JSON；有失败行返回错误 xlsx 文件流

### 请求参数

#### FormData 参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| file | file | 是 | 上传的 xlsx 文件（仅 spu_code 列） |

### 响应参数

#### 成功响应（全部导入成功）

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | integer | 成功导入的数量 |

#### 失败响应（部分导入失败）

返回 xlsx 文件流，Content-Type: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`

Excel 内容包含以下列：

| 列名 | 说明 |
|------|------|
| SPU编码 | 导入失败的商品编码 |
| 失败原因 | 导入失败的具体原因 |

### 请求示例

```http
POST /mall-admin/admin/api/v1/agent-products/import
Content-Type: multipart/form-data

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="agent_products.xlsx"
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

[文件内容]
```

### 响应示例

**全部成功：**

```json
{
  "code": 0,
  "message": "success",
  "data": 50
}
```

**部分失败：** 返回 xlsx 文件流（下载错误详情文件）

---

## 3. 移除代理商品

### 基本信息

- **接口名称**: 移除代理商品
- **请求方法**: DELETE
- **请求路径**: `/mall-admin/admin/api/v1/agent-products/{spuCode}`
- **接口描述**: 逻辑删除代理商品；已被代理的商品不可移除

### 请求参数

#### Path 参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| spuCode | string | 是 | 商品SPU编码 |

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | null | 无数据返回 |

### 请求示例

```http
DELETE /mall-admin/admin/api/v1/agent-products/SPU001
Content-Type: application/json
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

## 4. 获取后台类目下拉列表

### 基本信息

- **接口名称**: 获取后台类目下拉列表
- **请求方法**: GET
- **请求路径**: `/mall-admin/admin/api/v1/agent-products/backend-categories`
- **接口描述**: 读取配置的前台类目编码，返回对应后台类目列表

### 请求参数

无

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | array | 后台类目列表 |
| data[].categoryCode | string | 后台类目编码 |
| data[].categoryName | string | 后台类目名称 |

### 请求示例

```http
GET /mall-admin/admin/api/v1/agent-products/backend-categories
Content-Type: application/json
```

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "categoryCode": "CAT001",
      "categoryName": "手机数码"
    },
    {
      "categoryCode": "CAT002",
      "categoryName": "家用电器"
    }
  ]
}
```

---

## 5. 获取导入模板下载链接

### 基本信息

- **接口名称**: 获取导入模板下载链接
- **请求方法**: GET
- **请求路径**: `/mall-admin/admin/api/v1/agent-products/import-template`
- **接口描述**: 返回代理商品导入 xlsx 模板文件 OSS 链接

### 请求参数

无

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | string | 模板文件 OSS 下载链接 |

### 请求示例

```http
GET /mall-admin/admin/api/v1/agent-products/import-template
Content-Type: application/json
```

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": "https://oss.example.com/templates/agent_product_import_template.xlsx"
}
```

---

## 6. 获取代理商品类目配置

### 基本信息

- **接口名称**: 获取代理商品类目配置
- **请求方法**: GET
- **请求路径**: `/mall-admin/admin/api/v1/agent-products/category-config`
- **接口描述**: 查询当前配置的前台类目配置编码

### 请求参数

无

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | string | 前台类目配置编码 |

### 请求示例

```http
GET /mall-admin/admin/api/v1/agent-products/category-config
Content-Type: application/json
```

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": "FRONT_CAT_CONFIG_001"
}
```

---

## 7. 保存代理商品类目配置

### 基本信息

- **接口名称**: 保存代理商品类目配置
- **请求方法**: POST
- **请求路径**: `/mall-admin/admin/api/v1/agent-products/category-config`
- **接口描述**: 配置代理商品小程序择品所使用的前台类目配置编码

### 请求参数

#### Query 参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| frontCategoryConfigCode | string | 是 | 前台类目配置编码 |

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | boolean | 是否保存成功 |

### 请求示例

```http
POST /mall-admin/admin/api/v1/agent-products/category-config?frontCategoryConfigCode=FRONT_CAT_CONFIG_001
Content-Type: application/json
```

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": true
}
```

---

## 8. 统计代理商品数据

### 基本信息

- **接口名称**: 统计代理商品数据
- **请求方法**: GET
- **请求路径**: `/mall-admin/admin/api/v1/agent-products/stat`
- **接口描述**: 返回代理商品总数量/代理数量/未代理数量

### 请求参数

无

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码，0表示成功 |
| message | string | 响应消息 |
| data | object | 统计数据 |
| data.totalCount | integer | 商品总数量 |
| data.agentedCount | integer | 已代理数量 |
| data.unAgentedCount | integer | 未代理数量 |

### 请求示例

```http
GET /mall-admin/admin/api/v1/agent-products/stat
Content-Type: application/json
```

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "totalCount": 1000,
    "agentedCount": 350,
    "unAgentedCount": 650
  }
}
```

---

## 数据模型

### AgentProductListRequest

代理商品列表查询请求

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| spuName | string | 否 | 商品名称（左前缀查询） |
| spuCode | string | 否 | 商品SPU编码（左前缀查询） |
| agentStatus | integer | 否 | 代理状态：0-未代理，1-已代理 |
| backendCategoryCode | string | 否 | 后台类目编码 |
| pageNum | integer | 否 | 页码，默认1 |
| pageSize | integer | 否 | 每页条数，默认20 |

### AgentProductResponse

代理商品列表响应

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | integer | 主键ID |
| spuCode | string | 商品SPU编码 |
| spuName | string | 商品名称 |
| spuPrice | BigDecimal | 商品价格 |
| mainImage | string | 商品主图 URL |
| backendCategoryCode | string | 后台三级类目编码 |
| agentStatus | integer | 代理状态：0-未代理，1-已代理 |
| createTime | string | 创建时间，格式：yyyy-MM-dd HH:mm:ss |

### AgentProductStatResponse

代理商品统计数据响应

| 字段名 | 类型 | 说明 |
|--------|------|------|
| totalCount | integer | 商品总数量 |
| agentedCount | integer | 已代理数量 |
| unAgentedCount | integer | 未代理数量 |

### BackendCategoryResponse

后台类目下拉响应

| 字段名 | 类型 | 说明 |
|--------|------|------|
| categoryCode | string | 后台类目编码 |
| categoryName | string | 后台类目名称 |

---

## 枚举值说明

### 代理状态 (agentStatus)

| 值 | 说明 |
|----|------|
| 0 | 未代理 |
| 1 | 已代理 |

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

## 变更日志

| 版本 | 日期 | 变更内容 | 变更人 |
|------|------|----------|--------|
| v1.0.1 | 2026-03-16 | 新增 spuPrice 字段 | P-2026-001-F-004 |
| v1.0.0 | 2026-03-16 | 初始版本 | P-2026-001-F-004 |

---

*文档生成时间: 2026-03-16*
