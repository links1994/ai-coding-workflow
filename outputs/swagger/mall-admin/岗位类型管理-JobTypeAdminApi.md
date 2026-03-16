---
service: mall-admin
controller: JobTypeAdminController
module: JobTypeAdmin
title: 岗位类型管理
version: v1.0.0
updated_at: 2026-03-16
updated_by: P-2026-001-F-001
---

# 岗位类型管理 API 文档

## 目录

- [1. 岗位类型列表](#1-岗位类型列表)
- [2. 新增岗位类型](#2-新增岗位类型)
- [3. 编辑岗位类型](#3-编辑岗位类型)
- [4. 启用禁用岗位类型](#4-启用禁用岗位类型)
- [5. 删除岗位类型](#5-删除岗位类型)

---

## 1. 岗位类型列表

### 基本信息

| 项目 | 内容 |
|------|------|
| 接口名称 | 岗位类型列表 |
| 接口路径 | `/mall-admin/admin/api/v1/job-types` |
| 请求方法 | GET |
| 接口描述 | 分页查询岗位类型列表，支持关键词搜索 |

### 请求参数

#### Query 参数

| 参数名 | 类型 | 必填 | 描述 | 默认值 |
|--------|------|------|------|--------|
| keyword | String | 否 | 关键词（匹配名称/编码） | - |
| pageNum | Integer | 否 | 页码，必须大于等于1 | 1 |
| pageSize | Integer | 否 | 每页大小，1-100之间 | 10 |

### 响应结果

#### 响应结构

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "items": [
      {
        "id": 1,
        "name": "销售专员",
        "code": "SALES",
        "description": "负责产品销售和客户维护",
        "status": 1,
        "isDefault": 0,
        "sortOrder": 1,
        "employeeCount": 5,
        "createTime": "2026-03-15 10:00:00",
        "updateTime": "2026-03-15 10:00:00"
      }
    ],
    "totalCount": 1
  }
}
```

#### 响应字段说明

| 字段名 | 类型 | 描述 |
|--------|------|------|
| code | Integer | 响应码，200 表示成功 |
| message | String | 响应消息 |
| data | Object | 分页数据 |
| data.items | Array | 岗位类型列表 |
| data.items[].id | Long | 岗位类型ID |
| data.items[].name | String | 岗位类型名称 |
| data.items[].code | String | 岗位类型编码 |
| data.items[].description | String | 岗位描述 |
| data.items[].status | Integer | 状态：0-禁用，1-启用 |
| data.items[].isDefault | Integer | 是否默认：0-非默认，1-默认 |
| data.items[].sortOrder | Integer | 排序号 |
| data.items[].employeeCount | Integer | 关联员工数 |
| data.items[].createTime | String | 创建时间，格式：yyyy-MM-dd HH:mm:ss |
| data.items[].updateTime | String | 更新时间，格式：yyyy-MM-dd HH:mm:ss |
| data.totalCount | Long | 总记录数 |

---

## 2. 新增岗位类型

### 基本信息

| 项目 | 内容 |
|------|------|
| 接口名称 | 新增岗位类型 |
| 接口路径 | `/mall-admin/admin/api/v1/job-types` |
| 请求方法 | POST |
| 接口描述 | 创建新的岗位类型 |

### 请求参数

#### Body 参数

| 参数名 | 类型 | 必填 | 描述 | 限制条件 |
|--------|------|------|------|----------|
| name | String | 是 | 岗位类型名称 | 不能为空，长度不超过64 |
| description | String | 否 | 岗位描述 | 长度不超过255 |
| status | Integer | 否 | 状态：0-禁用，1-启用 | 默认1 |

#### 请求示例

```json
{
  "name": "销售专员",
  "description": "负责产品销售和客户维护",
  "status": 1
}
```

### 响应结果

#### 响应结构

```json
{
  "code": 200,
  "message": "操作成功",
  "data": 1
}
```

#### 响应字段说明

| 字段名 | 类型 | 描述 |
|--------|------|------|
| code | Integer | 响应码，200 表示成功 |
| message | String | 响应消息 |
| data | Long | 新创建的岗位类型ID |

---

## 3. 编辑岗位类型

### 基本信息

| 项目 | 内容 |
|------|------|
| 接口名称 | 编辑岗位类型 |
| 接口路径 | `/mall-admin/admin/api/v1/job-types/{jobTypeId}` |
| 请求方法 | PUT |
| 接口描述 | 更新岗位类型信息 |

### 请求参数

#### Path 参数

| 参数名 | 类型 | 必填 | 描述 |
|--------|------|------|------|
| jobTypeId | Long | 是 | 岗位类型ID |

#### Body 参数

| 参数名 | 类型 | 必填 | 描述 | 限制条件 |
|--------|------|------|------|----------|
| name | String | 是 | 岗位类型名称 | 不能为空，长度不超过64 |
| description | String | 否 | 岗位描述 | 长度不超过255 |
| status | Integer | 否 | 状态：0-禁用，1-启用 | - |

#### 请求示例

```json
{
  "name": "高级销售专员",
  "description": "负责产品销售、客户维护和大客户拓展",
  "status": 1
}
```

### 响应结果

#### 响应结构

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

#### 响应字段说明

| 字段名 | 类型 | 描述 |
|--------|------|------|
| code | Integer | 响应码，200 表示成功 |
| message | String | 响应消息 |
| data | Boolean | 是否更新成功 |

---

## 4. 启用/禁用岗位类型

### 基本信息

| 项目 | 内容 |
|------|------|
| 接口名称 | 启用/禁用岗位类型 |
| 接口路径 | `/mall-admin/admin/api/v1/job-types/{jobTypeId}/status` |
| 请求方法 | PUT |
| 接口描述 | 切换岗位类型启用/禁用状态 |

### 请求参数

#### Path 参数

| 参数名 | 类型 | 必填 | 描述 |
|--------|------|------|------|
| jobTypeId | Long | 是 | 岗位类型ID |

#### Body 参数

| 参数名 | 类型 | 必填 | 描述 |
|--------|------|------|------|
| status | Integer | 是 | 状态：0-禁用，1-启用 |

#### 请求示例

```json
{
  "status": 0
}
```

### 响应结果

#### 响应结构

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

#### 响应字段说明

| 字段名 | 类型 | 描述 |
|--------|------|------|
| code | Integer | 响应码，200 表示成功 |
| message | String | 响应消息 |
| data | Boolean | 是否更新成功 |

---

## 5. 删除岗位类型

### 基本信息

| 项目 | 内容 |
|------|------|
| 接口名称 | 删除岗位类型 |
| 接口路径 | `/mall-admin/admin/api/v1/job-types/{jobTypeId}` |
| 请求方法 | DELETE |
| 接口描述 | 删除指定岗位类型（有关联员工时不允许删除） |

### 请求参数

#### Path 参数

| 参数名 | 类型 | 必填 | 描述 |
|--------|------|------|------|
| jobTypeId | Long | 是 | 岗位类型ID |

### 响应结果

#### 响应结构

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

#### 响应字段说明

| 字段名 | 类型 | 描述 |
|--------|------|------|
| code | Integer | 响应码，200 表示成功 |
| message | String | 响应消息 |
| data | Boolean | 是否删除成功 |

### 错误码说明

| 错误码 | 描述 | 解决方案 |
|--------|------|----------|
| 500 | 岗位类型已被员工关联，无法删除 | 请先解除该岗位类型下所有员工的关联后再删除 |

---

## 通用错误码

| 错误码 | 描述 |
|--------|------|
| 200 | 操作成功 |
| 400 | 请求参数错误 |
| 401 | 未授权，请先登录 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |
