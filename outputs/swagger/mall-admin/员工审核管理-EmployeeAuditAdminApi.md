---
service: mall-admin
controller: EmployeeAuditAdminController
module: EmployeeAuditAdmin
title: 员工审核管理
version: v1.0.0
updated_at: 2026-03-16
updated_by: P-2026-001-F-006
---

# 员工审核管理 API 文档

## 基本信息

| 属性 | 值 |
|------|-----|
| **服务** | mall-admin |
| **Controller** | EmployeeAuditAdminController |
| **路径前缀** | /mall-admin/admin/api/v1/employee-audits |
| **所属模块** | 智能体管理平台/员工审核 |
| **功能编号** | F-006 |

---

## 接口列表

### 1. 员工审核列表

分页查询员工审核列表，待审核记录优先排序。

- **请求方式**: `GET`
- **请求路径**: `/mall-admin/admin/api/v1/employee-audits`
- **接口说明**: REQ-F006-05

#### 请求参数

| 参数名 | 类型 | 是否必填 | 描述 |
|--------|------|----------|------|
| auditResult | Integer | 否 | 审核维度筛选：0=待审核 / 1=已驳回 / 2=已通过，不传=全部 |
| pageNum | Integer | 否 | 页码，默认1，最小1 |
| pageSize | Integer | 否 | 每页条数，默认10，范围1-100 |

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "items": [
      {
        "employeeId": 10001,
        "employeeNo": "AIM2025030001",
        "userId": 20001,
        "jobType": {
          "id": 1,
          "name": "带货主播"
        },
        "spuCode": "SPU20250001",
        "auditResult": 0,
        "auditStatusDesc": "待审核",
        "employeeStatus": null,
        "employeeStatusDesc": null,
        "createTime": "2026-03-15 10:30:00"
      }
    ],
    "totalCount": 100
  }
}
```

#### 响应字段说明

| 字段名 | 类型 | 描述 |
|--------|------|------|
| employeeId | Long | 员工ID |
| employeeNo | String | 员工编号（格式：AIM{yyyyMM}{序列号}） |
| userId | Long | 用户ID |
| jobType | Object | 岗位类型，包含 id 和 name |
| spuCode | String | 代理商品SPU编码（客服岗为null） |
| auditResult | Integer | 审核状态：0=待审核 1=已驳回 2=已通过 |
| auditStatusDesc | String | 审核状态描述 |
| employeeStatus | Integer | 员工状态：0=待激活/1=已上线/2=已暂停/3=已封禁，null=未审核通过 |
| employeeStatusDesc | String | 员工状态描述 |
| createTime | String | 申请时间（格式：yyyy-MM-dd HH:mm:ss） |

---

### 2. 员工审核状态计数

查询三种审核状态的员工数量，用于 Tab 徽标展示。

- **请求方式**: `GET`
- **请求路径**: `/mall-admin/admin/api/v1/employee-audits/status-count`
- **接口说明**: REQ-F006-05b

#### 请求参数

无

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "pendingCount": 15,
    "rejectedCount": 8,
    "approvedCount": 120
  }
}
```

#### 响应字段说明

| 字段名 | 类型 | 描述 |
|--------|------|------|
| pendingCount | Integer | 待审核数量（audit_status=0） |
| rejectedCount | Integer | 已驳回数量（audit_status=1） |
| approvedCount | Integer | 已通过数量（audit_status=2） |

---

### 3. 员工审核详情

获取员工审核详情，含申请记录信息。

- **请求方式**: `GET`
- **请求路径**: `/mall-admin/admin/api/v1/employee-audits/{employeeId}/detail`
- **接口说明**: REQ-F006-06

#### 请求参数

| 参数名 | 类型 | 是否必填 | 描述 |
|--------|------|----------|------|
| employeeId | Long | 是 | 员工ID（路径参数） |

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "employeeId": 10001,
    "employeeNo": "AIM2025030001",
    "userId": 20001,
    "jobType": {
      "id": 1,
      "name": "带货主播"
    },
    "spuCode": "SPU20250001",
    "styleConfigName": "专业带货风格",
    "socialLinks": "[\"https://douyin.com/user/xxx\", \"https://xiaohongshu.com/user/yyy\"]",
    "socialScreenshots": "[\"https://cdn.example.com/img1.jpg\", \"https://cdn.example.com/img2.jpg\"]",
    "auditResult": 0,
    "auditStatusDesc": "待审核",
    "rejectReason": null,
    "createTime": "2026-03-15 10:30:00"
  }
}
```

#### 响应字段说明

| 字段名 | 类型 | 描述 |
|--------|------|------|
| employeeId | Long | 员工ID |
| employeeNo | String | 员工编号 |
| userId | Long | 用户ID |
| jobType | Object | 岗位类型，包含 id 和 name |
| spuCode | String | 代理商品SPU编码（客服岗为null） |
| styleConfigName | String | 人设风格名称 |
| socialLinks | String | 社交平台链接（JSON数组字符串） |
| socialScreenshots | String | 社交截图URL列表（JSON数组字符串） |
| auditResult | Integer | 审核状态：0=待审核 1=已驳回 2=已通过 |
| auditStatusDesc | String | 审核状态描述 |
| rejectReason | String | 驳回原因（仅驳回时有值） |
| createTime | String | 申请时间（格式：yyyy-MM-dd HH:mm:ss） |

---

### 4. 审核通过

审核通过，可选免邀请激活。

- **请求方式**: `POST`
- **请求路径**: `/mall-admin/admin/api/v1/employee-audits/{employeeId}/approve`
- **接口说明**: REQ-F006-07

#### 请求参数

**路径参数**

| 参数名 | 类型 | 是否必填 | 描述 |
|--------|------|----------|------|
| employeeId | Long | 是 | 员工ID |

**请求体参数**

| 参数名 | 类型 | 是否必填 | 描述 |
|--------|------|----------|------|
| skipActivation | Boolean | 否 | 是否免邀请激活，默认false。false=待激活，true=直接上线 |

**请求示例**

```json
{
  "skipActivation": false
}
```

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

#### 业务说明

- `skipActivation=false`（默认）：员工状态变为"待激活"（employee_status=0），需等待 F-007 激活步骤
- `skipActivation=true`：员工直接上线（employee_status=1），跳过 F-007 激活步骤

---

### 5. 审核驳回

审核驳回，必须填写驳回原因，名额释放。

- **请求方式**: `POST`
- **请求路径**: `/mall-admin/admin/api/v1/employee-audits/{employeeId}/reject`
- **接口说明**: REQ-F006-08

#### 请求参数

**路径参数**

| 参数名 | 类型 | 是否必填 | 描述 |
|--------|------|----------|------|
| employeeId | Long | 是 | 员工ID |

**请求体参数**

| 参数名 | 类型 | 是否必填 | 描述 |
|--------|------|----------|------|
| rejectReason | String | 是 | 驳回原因，1-200字 |

**请求示例**

```json
{
  "rejectReason": "社交截图不清晰，请重新上传"
}
```

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

#### 业务说明

- 驳回时必须填写驳回原因
- 驳回后释放该员工占用的名额
- 员工可重新提交申请

---

## 数据字典

### 审核状态 (auditResult)

| 值 | 含义 |
|----|------|
| 0 | 待审核 |
| 1 | 已驳回 |
| 2 | 已通过 |

### 员工状态 (employeeStatus)

| 值 | 含义 | 说明 |
|----|------|------|
| 0 | 待激活 | 审核通过但未激活 |
| 1 | 已上线 | 已激活并可正常工作 |
| 2 | 已暂停 | 暂时停止服务 |
| 3 | 已封禁 | 永久封禁 |
| null | 未审核通过 | 待审核或已驳回状态 |

---

## 错误码说明

| 错误码 | 描述 |
|--------|------|
| 200 | 操作成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 变更日志

| 版本 | 日期 | 变更内容 | 变更人 |
|------|------|----------|--------|
| v1.0.0 | 2026-03-16 | 初始版本 | P-2026-001-F-006 |
