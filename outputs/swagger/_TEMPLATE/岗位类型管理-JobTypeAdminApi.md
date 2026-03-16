---
service: mall-admin
controller: JobTypeAdminController
module: JobTypeAdmin
title: 岗位类型管理
version: v1.0.0
updated_at: 2026-03-08
updated_by: P-2026-001-F-001
---

# 岗位类型管理 API 文档（JobTypeAdminController）

> 本文档由 Phase 9 Swagger 文档生成 Skill 自动生成，最后更新：2026-03-08

## 目录

- [岗位类型列表](#岗位类型列表)
- [新增岗位类型](#新增岗位类型)
- [编辑岗位类型](#编辑岗位类型)
- [启用/禁用岗位类型](#启用禁用岗位类型)
- [删除岗位类型](#删除岗位类型)

---

## JobTypeAdmin（岗位类型管理）

### 岗位类型列表

- **路径**：`GET /admin/api/v1/job-types`
- **描述**：分页查询岗位类型列表，支持关键词搜索（匹配名称或编码）

#### 请求参数

| 字段 | 类型 | 是否必填 | 默认值 | 说明 |
|------|------|---------|-------|------|
| `keyword` | String | 否 | - | 关键词，匹配岗位类型名称或编码 |
| `pageNum` | Integer | 否 | 1 | 页码，最小值 1 |
| `pageSize` | Integer | 否 | 10 | 每页大小，范围 1~100 |

#### 响应结构

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "totalCount": 20,
    "items": [
      {
        "id": 1,
        "name": "销售顾问",
        "code": "J2026000001",
        "description": "负责销售相关工作",
        "status": 1,
        "isDefault": 0,
        "sortOrder": 1,
        "employeeCount": 5,
        "createTime": "2026-03-08 10:00:00",
        "updateTime": "2026-03-08 10:00:00"
      }
    ]
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `totalCount` | Long | 总记录数 |
| `items` | Array\<JobTypeResponse\> | 分页数据列表 |
| `items[].id` | Long | 岗位类型 ID |
| `items[].name` | String | 岗位类型名称 |
| `items[].code` | String | 岗位类型编码（系统自动生成，格式：J+年+6位序号，如 J2026000001） |
| `items[].description` | String | 岗位描述 |
| `items[].status` | Integer | 状态：0-禁用，1-启用 |
| `items[].isDefault` | Integer | 是否默认岗位类型：0-否，1-是 |
| `items[].sortOrder` | Integer | 排序号（系统自动生成，越小越靠前） |
| `items[].employeeCount` | Integer | 关联员工数量 |
| `items[].createTime` | String | 创建时间，格式：yyyy-MM-dd HH:mm:ss |
| `items[].updateTime` | String | 更新时间，格式：yyyy-MM-dd HH:mm:ss |

---

### 新增岗位类型

- **路径**：`POST /admin/api/v1/job-types`
- **描述**：创建新的岗位类型，编码和排序号由系统自动生成

#### 请求参数

| 字段 | 类型 | 是否必填 | 说明 |
|------|------|---------|------|
| `name` | String | 是 | 岗位类型名称，最大长度 64，不可重复 |
| `description` | String | 否 | 岗位描述，最大长度 255 |
| `status` | Integer | 否 | 状态：0-禁用，1-启用，默认 1 |

#### 响应结构

```json
{
  "code": 200,
  "message": "success",
  "data": 1
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `data` | Long | 新创建的岗位类型 ID |

#### 业务规则

- 岗位类型名称不允许重复
- 编码由系统自动生成（格式：J+年(yyyy)+6位序号，如 J2026000001）
- 排序号由系统自动生成（当前最大值 +1）

---

### 编辑岗位类型

- **路径**：`PUT /admin/api/v1/job-types/{jobTypeId}`
- **描述**：更新岗位类型信息（编码和排序号不允许修改）

#### 请求参数

| 字段 | 类型 | 是否必填 | 说明 |
|------|------|---------|------|
| `name` | String | 是 | 岗位类型名称，最大长度 64，不可与其他记录重复 |
| `description` | String | 否 | 岗位描述，最大长度 255 |
| `status` | Integer | 否 | 状态：0-禁用，1-启用 |

#### 响应结构

```json
{
  "code": 200,
  "message": "success",
  "data": true
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `data` | Boolean | 是否更新成功 |

---

### 启用/禁用岗位类型

- **路径**：`PUT /admin/api/v1/job-types/{jobTypeId}/status`
- **描述**：切换岗位类型的启用/禁用状态

#### 请求参数

| 字段 | 类型 | 是否必填 | 说明 |
|------|------|---------|------|
| `status` | Integer | 是 | 目标状态：0-禁用，1-启用 |

#### 响应结构

```json
{
  "code": 200,
  "message": "success",
  "data": true
}
```

---

### 删除岗位类型

- **路径**：`DELETE /admin/api/v1/job-types/{jobTypeId}`
- **描述**：删除指定岗位类型（物理删除，有关联员工时不允许删除）

#### 响应结构

```json
{
  "code": 200,
  "message": "success",
  "data": true
}
```

#### 业务规则

- 采用**物理删除**，删除后数据不可恢复
- 删除前校验：若该岗位类型下存在关联员工，则拒绝删除并返回错误信息

#### 错误码

| 错误码 | 说明 |
|-------|------|
| `40023001` | 岗位类型名称已存在（新增/编辑时名称重复） |
| `40023002` | 岗位类型不存在 |
| `40023003` | 岗位类型已被员工引用，无法删除 |
