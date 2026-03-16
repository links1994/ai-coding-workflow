---
service: mall-admin
controller: ScriptTemplateAdminController
module: ScriptTemplateAdmin
title: 话术模板管理
version: v1.0.0
updated_at: 2026-03-16
updated_by: P-2026-001-F-005
---

# 话术模板管理 API 文档

> 服务：mall-admin  
> 控制器：ScriptTemplateAdminController  
> 路径前缀：`/mall-admin/admin/api/v1/script-templates`  
> 标签：`智能体管理/话术模板管理`

---

## 接口概览

| 序号 | 接口名称 | 方法 | 路径 | 说明 |
|------|----------|------|------|------|
| 1 | 获取导入模板下载链接 | GET | `/import-template` | 获取话术模板 xlsx 导入模板的 OSS 下载链接 |
| 2 | 查询岗位类型列表 | GET | `/job-types` | 查询全量岗位类型，包含未启用的 |
| 3 | 分页查询话术模板 | POST | `/page` | 支持名称模糊搜索、岗位类型、状态过滤 |
| 4 | 新增话术模板 | POST | `/` | 创建新的话术模板 |
| 5 | 编辑话术模板 | PUT | `/{templateId}` | 更新话术模板信息（模板编号不可修改） |
| 6 | 启用/禁用话术模板 | PUT | `/{templateId}/status` | 切换话术模板启用/禁用状态 |
| 7 | 删除话术模板 | DELETE | `/{templateId}` | 物理删除话术模板（启用中不可删除） |
| 8 | 批量导入话术模板 | POST | `/import` | 上传 xlsx 文件批量导入 |

---

## 1. 获取导入模板下载链接

### 基本信息

- **接口名称**：获取导入模板下载链接
- **请求方法**：GET
- **请求路径**：`/mall-admin/admin/api/v1/script-templates/import-template`
- **接口描述**：获取话术模板 xlsx 导入模板的 OSS 下载链接，无需传入 moduleCode

### 请求参数

无

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 状态码，0 表示成功 |
| message | String | 提示信息 |
| data | String | 模板文件 OSS 下载链接 |

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": "https://oss.example.com/templates/script_template_import.xlsx"
}
```

---

## 2. 查询岗位类型列表

### 基本信息

- **接口名称**：查询岗位类型列表
- **请求方法**：GET
- **请求路径**：`/mall-admin/admin/api/v1/script-templates/job-types`
- **接口描述**：查询全量岗位类型，包含未启用的，供话术模板下拉选择使用

### 请求参数

无

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 状态码，0 表示成功 |
| message | String | 提示信息 |
| data | Array | 岗位类型列表 |

#### JobTypeSimpleResponse

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 岗位类型ID |
| name | String | 岗位类型名称 |
| code | String | 岗位类型编码 |
| status | Integer | 状态：0-禁用，1-启用 |

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "客服专员",
      "code": "CS_SPECIALIST",
      "status": 1
    },
    {
      "id": 2,
      "name": "销售顾问",
      "code": "SALES_CONSULTANT",
      "status": 1
    }
  ]
}
```

---

## 3. 分页查询话术模板

### 基本信息

- **接口名称**：分页查询话术模板
- **请求方法**：POST
- **请求路径**：`/mall-admin/admin/api/v1/script-templates/page`
- **接口描述**：支持名称模糊搜索、岗位类型、状态过滤

### 请求参数

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|--------|------|------|------|------|
| Content-Type | Header | String | 是 | `application/json` |

#### ScriptTemplateListRequest

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| name | String | 否 | 模板名称（模糊搜索） |
| jobTypeId | Long | 否 | 岗位类型ID |
| status | Integer | 否 | 状态：0-禁用，1-启用 |
| pageNum | Integer | 否 | 页码，默认1，最小1 |
| pageSize | Integer | 否 | 每页条数，默认10，范围1-100 |

### 请求示例

```json
{
  "name": "欢迎语",
  "jobTypeId": 1,
  "status": 1,
  "pageNum": 1,
  "pageSize": 10
}
```

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 状态码，0 表示成功 |
| message | String | 提示信息 |
| data | Object | 分页数据 |
| data.items | Array | 话术模板列表 |
| data.totalCount | Long | 总记录数 |

#### ScriptTemplateResponse

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 模板ID |
| templateCode | String | 模板编号（系统生成） |
| name | String | 模板名称 |
| triggerCondition | String | 触发条件 |
| content | String | 话术内容 |
| jobType | Object | 关联岗位类型 |
| status | Integer | 状态：0-禁用，1-启用 |
| createTime | String | 创建时间，格式：yyyy-MM-dd HH:mm:ss |

#### JobTypeRefResponse

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 岗位类型ID |
| name | String | 岗位类型名称 |
| code | String | 岗位类型编码 |

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 1,
        "templateCode": "ST202503150001",
        "name": "欢迎语模板",
        "triggerCondition": "客户首次进入会话",
        "content": "您好，欢迎光临！我是您的专属客服，很高兴为您服务。",
        "jobType": {
          "id": 1,
          "name": "客服专员",
          "code": "CS_SPECIALIST"
        },
        "status": 1,
        "createTime": "2026-03-15 10:30:00"
      }
    ],
    "totalCount": 100
  }
}
```

---

## 4. 新增话术模板

### 基本信息

- **接口名称**：新增话术模板
- **请求方法**：POST
- **请求路径**：`/mall-admin/admin/api/v1/script-templates`
- **接口描述**：创建新的话术模板

### 请求参数

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|--------|------|------|------|------|
| Content-Type | Header | String | 是 | `application/json` |

#### ScriptTemplateCreateRequest

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| name | String | 是 | 模板名称，最大长度128 |
| triggerCondition | String | 是 | 触发条件，最大长度255 |
| content | String | 是 | 话术内容 |
| jobTypeId | Long | 是 | 适用岗位类型ID |
| status | Integer | 否 | 状态：0-禁用，1-启用，默认1 |

### 请求示例

```json
{
  "name": "欢迎语模板",
  "triggerCondition": "客户首次进入会话",
  "content": "您好，欢迎光临！我是您的专属客服，很高兴为您服务。",
  "jobTypeId": 1,
  "status": 1
}
```

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 状态码，0 表示成功 |
| message | String | 提示信息 |
| data | Long | 新创建模板ID |

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": 10001
}
```

---

## 5. 编辑话术模板

### 基本信息

- **接口名称**：编辑话术模板
- **请求方法**：PUT
- **请求路径**：`/mall-admin/admin/api/v1/script-templates/{templateId}`
- **接口描述**：更新话术模板信息（模板编号不可修改）

### 请求参数

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|--------|------|------|------|------|
| Content-Type | Header | String | 是 | `application/json` |
| templateId | Path | Long | 是 | 模板ID |

#### ScriptTemplateUpdateRequest

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| name | String | 是 | 模板名称，最大长度128 |
| triggerCondition | String | 是 | 触发条件，最大长度255 |
| content | String | 是 | 话术内容 |

### 请求示例

```json
{
  "name": "欢迎语模板-更新",
  "triggerCondition": "客户首次进入会话或重新连接",
  "content": "您好，欢迎回来！有什么可以帮您的吗？"
}
```

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 状态码，0 表示成功 |
| message | String | 提示信息 |
| data | Boolean | 是否成功 |

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": true
}
```

---

## 6. 启用/禁用话术模板

### 基本信息

- **接口名称**：启用/禁用话术模板
- **请求方法**：PUT
- **请求路径**：`/mall-admin/admin/api/v1/script-templates/{templateId}/status`
- **接口描述**：切换话术模板启用/禁用状态

### 请求参数

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|--------|------|------|------|------|
| Content-Type | Header | String | 是 | `application/json` |
| templateId | Path | Long | 是 | 模板ID |

#### ScriptTemplateStatusRequest

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| status | Integer | 是 | 状态：0-禁用，1-启用 |

### 请求示例

```json
{
  "status": 0
}
```

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 状态码，0 表示成功 |
| message | String | 提示信息 |
| data | Boolean | 是否成功 |

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": true
}
```

---

## 7. 删除话术模板

### 基本信息

- **接口名称**：删除话术模板
- **请求方法**：DELETE
- **请求路径**：`/mall-admin/admin/api/v1/script-templates/{templateId}`
- **接口描述**：物理删除话术模板（启用中不可删除）

### 请求参数

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|--------|------|------|------|------|
| templateId | Path | Long | 是 | 模板ID |

### 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | Integer | 状态码，0 表示成功 |
| message | String | 提示信息 |
| data | Boolean | 是否成功 |

### 响应示例

```json
{
  "code": 0,
  "message": "success",
  "data": true
}
```

---

## 8. 批量导入话术模板

### 基本信息

- **接口名称**：批量导入话术模板
- **请求方法**：POST
- **请求路径**：`/mall-admin/admin/api/v1/script-templates/import`
- **接口描述**：上传 xlsx 文件批量导入；全部成功返回 JSON；有失败返回 xlsx 错误文件流
- **Content-Type**：`multipart/form-data`

### 请求参数

| 参数名 | 位置 | 类型 | 必填 | 说明 |
|--------|------|------|------|------|
| file | FormData | File | 是 | xlsx 文件 |

### 请求示例

```http
POST /mall-admin/admin/api/v1/script-templates/import
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="templates.xlsx"
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

[文件内容]
------WebKitFormBoundary--
```

### 响应说明

- **全部成功**：返回 JSON，包含成功条数
- **部分/全部失败**：返回 xlsx 错误文件流，包含失败原因

### 响应示例 - 全部成功

```json
{
  "code": 0,
  "message": "success",
  "data": 10
}
```

### 响应示例 - 有失败（返回文件流）

返回 `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` 格式的文件流，文件名为 `话术模板导入错误.xlsx`

#### 错误文件列说明

| 列名 | 说明 |
|------|------|
| 行号 | Excel 行号（从2开始） |
| 模板名称 | 导入的模板名称 |
| 触发条件 | 导入的触发条件 |
| 话术内容 | 导入的话术内容 |
| 岗位类型ID | 导入的岗位类型ID |
| 失败原因 | 导入失败的具体原因 |

---

## 数据模型

### ScriptTemplateCreateRequest

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| name | String | 是 | 模板名称，最大长度128 |
| triggerCondition | String | 是 | 触发条件，最大长度255 |
| content | String | 是 | 话术内容 |
| jobTypeId | Long | 是 | 适用岗位类型ID |
| status | Integer | 否 | 状态：0-禁用，1-启用，默认1 |

### ScriptTemplateUpdateRequest

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| name | String | 是 | 模板名称，最大长度128 |
| triggerCondition | String | 是 | 触发条件，最大长度255 |
| content | String | 是 | 话术内容 |

### ScriptTemplateStatusRequest

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| status | Integer | 是 | 状态：0-禁用，1-启用 |

### ScriptTemplateListRequest

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| name | String | 否 | 模板名称（模糊搜索） |
| jobTypeId | Long | 否 | 岗位类型ID |
| status | Integer | 否 | 状态：0-禁用，1-启用 |
| pageNum | Integer | 否 | 页码，默认1，最小1 |
| pageSize | Integer | 否 | 每页条数，默认10，范围1-100 |

### ScriptTemplateResponse

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 模板ID |
| templateCode | String | 模板编号（系统生成） |
| name | String | 模板名称 |
| triggerCondition | String | 触发条件 |
| content | String | 话术内容 |
| jobType | JobTypeRefResponse | 关联岗位类型 |
| status | Integer | 状态：0-禁用，1-启用 |
| createTime | String | 创建时间，格式：yyyy-MM-dd HH:mm:ss |

### JobTypeRefResponse

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 岗位类型ID |
| name | String | 岗位类型名称 |
| code | String | 岗位类型编码 |

### JobTypeSimpleResponse

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | Long | 岗位类型ID |
| name | String | 岗位类型名称 |
| code | String | 岗位类型编码 |
| status | Integer | 状态：0-禁用，1-启用 |

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |
| 1001 | 模板名称已存在 |
| 1002 | 岗位类型不存在 |
| 1003 | 启用中模板不可删除 |
| 1004 | 模板编号生成失败 |

---

## 变更日志

| 版本 | 日期 | 变更内容 | 变更人 |
|------|------|----------|--------|
| v1.0.0 | 2026-03-16 | 初始版本 | P-2026-001-F-005 |
