---
service: mall-admin
controller: StyleConfigAdminController
module: StyleConfigAdmin
title: 人设风格管理
version: v1.0.0
updated_at: 2026-03-16
updated_by: P-2026-001-F-002
---

# 人设风格管理 API

## 基本信息

| 属性 | 值 |
|------|-----|
| 服务 | mall-admin |
| 控制器 | StyleConfigAdminController |
| 路径前缀 | /mall-admin/admin/api/v1/style-configs |
| 模块 | 智能体管理平台/人设风格管理 |

## 接口列表

### 1. 人设风格列表

获取所有人设风格列表，按排序权重升序排列。

**请求信息**

| 属性 | 值 |
|------|-----|
| 接口名称 | list |
| 请求方法 | GET |
| 请求路径 | /mall-admin/admin/api/v1/style-configs |
| 摘要 | 人设风格列表 |

**请求参数**

无

**响应参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| code | integer | 是 | 响应码 |
| message | string | 是 | 响应消息 |
| data | array | 是 | 风格列表 |
| data[].id | integer | 是 | 风格ID |
| data[].name | string | 是 | 风格名称 |
| data[].description | string | 否 | 风格描述 |
| data[].iconName | string | 否 | 图标标识符 |
| data[].promptStyle | string | 是 | Prompt模板片段 |
| data[].sortOrder | integer | 是 | 排序权重 |
| data[].status | string | 是 | 状态：ENABLED-启用，DISABLED-禁用 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "name": "专业严谨",
      "description": "适合正式商务场景",
      "iconName": "briefcase",
      "promptStyle": "请以专业、严谨的态度回复客户",
      "sortOrder": 1,
      "status": "ENABLED"
    }
  ]
}
```

---

### 2. 新增人设风格

创建新的人设风格配置。

**请求信息**

| 属性 | 值 |
|------|-----|
| 接口名称 | create |
| 请求方法 | POST |
| 请求路径 | /mall-admin/admin/api/v1/style-configs |
| 摘要 | 新增人设风格 |

**请求体参数**

| 参数名 | 类型 | 必填 | 约束 | 说明 |
|--------|------|------|------|------|
| name | string | 是 | 非空，最大50字符 | 风格名称 |
| description | string | 否 | 最大200字符 | 风格描述 |
| iconName | string | 否 | 最大100字符 | 图标标识符 |
| promptStyle | string | 是 | 非空，最大500字符 | Prompt模板片段 |
| sortOrder | integer | 是 | 非空 | 排序权重 |

**请求示例**

```json
{
  "name": "专业严谨",
  "description": "适合正式商务场景",
  "iconName": "briefcase",
  "promptStyle": "请以专业、严谨的态度回复客户，使用规范用语",
  "sortOrder": 1
}
```

**响应参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| code | integer | 是 | 响应码 |
| message | string | 是 | 响应消息 |
| data | integer | 是 | 新记录ID |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": 1
}
```

---

### 3. 编辑人设风格

更新人设风格配置信息。

**请求信息**

| 属性 | 值 |
|------|-----|
| 接口名称 | update |
| 请求方法 | PUT |
| 请求路径 | /mall-admin/admin/api/v1/style-configs/{styleId} |
| 摘要 | 编辑人设风格 |

**路径参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| styleId | integer | 是 | 风格ID |

**请求体参数**

| 参数名 | 类型 | 必填 | 约束 | 说明 |
|--------|------|------|------|------|
| name | string | 否 | 最大50字符 | 风格名称 |
| description | string | 否 | 最大200字符 | 风格描述 |
| iconName | string | 否 | 最大100字符 | 图标标识符 |
| promptStyle | string | 否 | 最大500字符 | Prompt模板片段 |
| sortOrder | integer | 否 | - | 排序权重 |

**请求示例**

```json
{
  "name": "专业严谨",
  "description": "适合正式商务场景",
  "iconName": "briefcase",
  "promptStyle": "请以专业、严谨的态度回复客户",
  "sortOrder": 1
}
```

**响应参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| code | integer | 是 | 响应码 |
| message | string | 是 | 响应消息 |
| data | boolean | 是 | 是否成功 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

---

### 4. 启用/禁用人设风格

切换人设风格启用/禁用状态。

**请求信息**

| 属性 | 值 |
|------|-----|
| 接口名称 | updateStatus |
| 请求方法 | PUT |
| 请求路径 | /mall-admin/admin/api/v1/style-configs/{styleId}/status |
| 摘要 | 启用/禁用人设风格 |

**路径参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| styleId | integer | 是 | 风格ID |

**请求体参数**

| 参数名 | 类型 | 必填 | 约束 | 说明 |
|--------|------|------|------|------|
| status | string | 是 | 非空 | 状态：ENABLED-启用，DISABLED-禁用 |

**请求示例**

```json
{
  "status": "DISABLED"
}
```

**响应参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| code | integer | 是 | 响应码 |
| message | string | 是 | 响应消息 |
| data | boolean | 是 | 是否成功 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

---

### 5. 删除人设风格

删除指定人设风格（有关联员工时不允许删除）。

**请求信息**

| 属性 | 值 |
|------|-----|
| 接口名称 | delete |
| 请求方法 | DELETE |
| 请求路径 | /mall-admin/admin/api/v1/style-configs/{styleId} |
| 摘要 | 删除人设风格 |

**路径参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| styleId | integer | 是 | 风格ID |

**响应参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| code | integer | 是 | 响应码 |
| message | string | 是 | 响应消息 |
| data | boolean | 是 | 是否成功 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

---

## 数据模型

### StyleConfigCreateRequest

人设风格创建请求

| 字段名 | 类型 | 必填 | 约束 | 说明 |
|--------|------|------|------|------|
| name | string | 是 | 非空，最大50字符 | 风格名称 |
| description | string | 否 | 最大200字符 | 风格描述 |
| iconName | string | 否 | 最大100字符 | 图标标识符 |
| promptStyle | string | 是 | 非空，最大500字符 | Prompt模板片段 |
| sortOrder | integer | 是 | 非空 | 排序权重 |

### StyleConfigUpdateRequest

人设风格更新请求

| 字段名 | 类型 | 必填 | 约束 | 说明 |
|--------|------|------|------|------|
| name | string | 否 | 最大50字符 | 风格名称 |
| description | string | 否 | 最大200字符 | 风格描述 |
| iconName | string | 否 | 最大100字符 | 图标标识符 |
| promptStyle | string | 否 | 最大500字符 | Prompt模板片段 |
| sortOrder | integer | 否 | - | 排序权重 |

### StyleConfigStatusRequest

人设风格状态更新请求

| 字段名 | 类型 | 必填 | 约束 | 说明 |
|--------|------|------|------|------|
| status | string | 是 | 非空 | 状态：ENABLED-启用，DISABLED-禁用 |

### StyleConfigResponse

人设风格响应

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | integer | 是 | 风格ID |
| name | string | 是 | 风格名称 |
| description | string | 否 | 风格描述 |
| iconName | string | 否 | 图标标识符 |
| promptStyle | string | 是 | Prompt模板片段 |
| sortOrder | integer | 是 | 排序权重 |
| status | string | 是 | 状态：ENABLED-启用，DISABLED-禁用 |

---

## 状态码说明

| 状态码 | 说明 |
|--------|------|
| 200 | 操作成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |
