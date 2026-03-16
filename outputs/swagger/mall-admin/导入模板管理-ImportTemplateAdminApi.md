---
service: mall-admin
controller: ImportTemplateAdminController
module: ImportTemplateAdmin
title: 导入模板管理
version: v1.0.0
updated_at: 2026-03-16
updated_by: P-2026-001-F-008
---

# 导入模板管理

> 统一管理各业务模块的 xlsx 导入模板下载链接

## 基本信息

| 属性 | 值 |
|------|-----|
| 服务 | mall-admin |
| 模块 | ImportTemplateAdmin |
| Controller | ImportTemplateAdminController |
| 基础路径 | `/mall-admin/admin/api/v1/import-templates` |
| Tag | 公共/导入模板管理 |

## 模块编码说明

通过 `moduleCode` 区分业务模块，取值如下：

| 编码 | 说明 |
|------|------|
| `AGENT_PRODUCT` | 代理商品导入模板 |
| `SCRIPT_TEMPLATE` | 话术模板导入模板 |

---

## 接口列表

### 1. 获取导入模板下载链接

根据 moduleCode 返回对应业务的 xlsx 模板文件 OSS 链接。

#### 请求信息

| 属性 | 值 |
|------|-----|
| 接口名称 | 获取导入模板下载链接 |
| 请求方式 | GET |
| 请求路径 | `/mall-admin/admin/api/v1/import-templates` |
| Content-Type | - |

#### 请求参数

**Query 参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| moduleCode | String | 是 | 模块编码（AGENT_PRODUCT / SCRIPT_TEMPLATE） |

#### 响应信息

**成功响应 (200)**

| 字段 | 类型 | 说明 |
|------|------|------|
| code | Integer | 状态码 |
| message | String | 消息 |
| data | String | 模板文件 OSS 链接 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": "https://cdn.example.com/excel/template/agent_product_template.xlsx"
}
```

---

### 2. 保存/更新导入模板文件链接

将 xlsx 模板文件的 OSS 链接写入数据库（upsert by module_code）。

#### 请求信息

| 属性 | 值 |
|------|-----|
| 接口名称 | 保存/更新导入模板文件链接 |
| 请求方式 | POST |
| 请求路径 | `/mall-admin/admin/api/v1/import-templates` |
| Content-Type | `application/json` |

#### 请求参数

**Body 参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| moduleCode | String | 是 | 模块编码，枚举值：AGENT_PRODUCT / SCRIPT_TEMPLATE |
| templateUrl | String | 是 | 模板文件 OSS 链接 |

**请求示例**

```json
{
  "moduleCode": "AGENT_PRODUCT",
  "templateUrl": "https://cdn.example.com/excel/template/agent_product_template.xlsx"
}
```

#### 响应信息

**成功响应 (200)**

| 字段 | 类型 | 说明 |
|------|------|------|
| code | Integer | 状态码 |
| message | String | 消息 |
| data | Boolean | 是否成功 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

---

### 3. 上传导入模板文件

将 xlsx 模板文件上传至 CDN，返回文件访问链接，供后续保存模板链接接口使用。

#### 请求信息

| 属性 | 值 |
|------|-----|
| 接口名称 | 上传导入模板文件 |
| 请求方式 | POST |
| 请求路径 | `/mall-admin/admin/api/v1/import-templates/upload` |
| Content-Type | `multipart/form-data` |

#### 请求参数

**FormData 参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| file | File | 是 | 模板文件（xlsx） |

#### 响应信息

**成功响应 (200)**

| 字段 | 类型 | 说明 |
|------|------|------|
| code | Integer | 状态码 |
| message | String | 消息 |
| data | String | 文件 CDN 访问链接 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": "https://cdn.example.com/excel/template/agent_product_template.xlsx"
}
```

---

## 数据模型

### ImportTemplateSaveRequest

保存/更新导入模板文件链接请求

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| moduleCode | String | 是 | 模块编码，枚举值：AGENT_PRODUCT / SCRIPT_TEMPLATE |
| templateUrl | String | 是 | 模板文件 OSS 链接 |

---

## 错误码

| 错误码 | 说明 |
|--------|------|
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 500 | 服务器内部错误 |
