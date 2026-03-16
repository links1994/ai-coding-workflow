---
service: mall-admin
controller: EmployeeManageAdminController
module: EmployeeManageAdmin
title: 员工运营管理
version: v1.0.0
updated_at: 2026-03-16
updated_by: P-2026-001-F-008
---

# 员工运营管理 API 文档

## 基本信息

| 项目 | 内容 |
|------|------|
| 服务 | mall-admin |
| Controller | EmployeeManageAdminController |
| 基础路径 | `/mall-admin/admin/api/v1/employee-manage` |
| Tag | 智能体管理平台/员工运营管理 |
| 功能编号 | F-008 |

---

## 接口列表

### 1. 员工运营管理列表

- **接口编号**: REQ-F008-01
- **请求方式**: GET
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage`
- **接口说明**: 分页查询员工运营管理列表，支持员工状态/岗位类型/关键词筛选

#### 请求参数 (Query)

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeStatus | integer | 否 | 员工状态筛选（可选，不传=全部） |
| jobTypeId | integer | 否 | 工作岗位筛选（可选，传岗位类型ID，不传=全部） |
| keyword | string | 否 | 关键词筛选：若为纯数字则精确匹配 user_id，否则按员工名称左前缀匹配（name LIKE 'xxx%'） |
| pageNum | integer | 否 | 页码，默认 1 |
| pageSize | integer | 否 | 每页条数，默认 10 |

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "items": [
      {
        "employeeId": 1,
        "employeeNo": "E202403150001",
        "name": "张三",
        "userId": 10001,
        "jobType": {
          "id": 1,
          "name": "客服专员"
        },
        "spuCode": "SPU001",
        "employeeStatus": 2,
        "employeeStatusDesc": "营业中",
        "commissionRate": 5.00,
        "consultCount": 0,
        "conversionRate": 0,
        "totalRevenue": 0,
        "createTime": "2024-03-15 10:30:00"
      }
    ],
    "totalCount": 100
  }
}
```

**响应字段说明**

| 字段 | 类型 | 说明 |
|------|------|------|
| employeeId | integer | 员工ID |
| employeeNo | string | 员工编号 |
| name | string | 员工名称 |
| userId | integer | 关联用户ID |
| jobType | object | 岗位类型（含 id/name） |
| jobType.id | integer | 岗位类型ID |
| jobType.name | string | 岗位类型名称 |
| spuCode | string | SPU编码 |
| employeeStatus | integer | 员工状态 |
| employeeStatusDesc | string | 员工状态描述 |
| commissionRate | number | 佣金比例 |
| consultCount | integer | 咨询量（本期占位返回0） |
| conversionRate | number | 转化率（本期占位返回0） |
| totalRevenue | number | 累计成交额（本期占位返回0） |
| createTime | string | 创建时间 |

---

### 2. 员工统计头部数据

- **接口编号**: REQ-F008-02
- **请求方式**: GET
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage/stats`
- **接口说明**: 查询员工总数、当前在线数、累计成交额

#### 请求参数

无

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "totalCount": 100,
    "onlineCount": 50,
    "totalRevenue": 0
  }
}
```

**响应字段说明**

| 字段 | 类型 | 说明 |
|------|------|------|
| totalCount | integer | 员工总数 |
| onlineCount | integer | 当前在线数（employee_status=2 营业中） |
| totalRevenue | number | 累计成交额（本期占位返回0） |

---

### 3. 员工详情

- **接口编号**: REQ-F008-03
- **请求方式**: GET
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage/{employeeId}/detail`
- **接口说明**: 查询员工运营管理详情，含风格配置名称

#### 请求参数 (Path)

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | integer | 是 | 员工ID |

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "employeeId": 1,
    "employeeNo": "E202403150001",
    "name": "张三",
    "userId": 10001,
    "jobType": {
      "id": 1,
      "name": "客服专员"
    },
    "spuCode": "SPU001",
    "styleConfigName": "标准客服风格",
    "employeeStatus": 2,
    "employeeStatusDesc": "营业中",
    "commissionRate": 5.00,
    "consultCount": 0,
    "conversionRate": 0,
    "totalRevenue": 0,
    "createTime": "2024-03-15 10:30:00",
    "updateTime": "2024-03-15 14:30:00"
  }
}
```

**响应字段说明**

| 字段 | 类型 | 说明 |
|------|------|------|
| employeeId | integer | 员工ID |
| employeeNo | string | 员工编号 |
| name | string | 员工名称 |
| userId | integer | 关联用户ID |
| jobType | object | 岗位类型（含 jobTypeId/jobTypeName） |
| jobType.id | integer | 岗位类型ID |
| jobType.name | string | 岗位类型名称 |
| spuCode | string | SPU编码 |
| styleConfigName | string | 风格配置名称 |
| employeeStatus | integer | 员工状态 |
| employeeStatusDesc | string | 员工状态描述 |
| commissionRate | number | 佣金比例 |
| consultCount | integer | 咨询量（本期占位返回0） |
| conversionRate | number | 转化率（本期占位返回0） |
| totalRevenue | number | 累计成交额（本期占位返回0） |
| createTime | string | 创建时间 |
| updateTime | string | 更新时间 |

---

### 4. 强制离线

- **接口编号**: REQ-F008-04
- **请求方式**: POST
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage/{employeeId}/force-offline`
- **接口说明**: 将营业中（status=2）的员工强制离线（status=3）

#### 请求参数 (Path)

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | integer | 是 | 员工ID |

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

---

### 5. 恢复上线

- **接口编号**: REQ-F008-05
- **请求方式**: POST
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage/{employeeId}/restore-online`
- **接口说明**: 将强制离线（status=3）的员工恢复上线（status=2）

#### 请求参数 (Path)

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | integer | 是 | 员工ID |

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

---

### 6. 封禁员工

- **接口编号**: REQ-F008-06
- **请求方式**: POST
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage/{employeeId}/ban`
- **接口说明**: 封禁员工（不可逆），已注销员工不可封禁

#### 请求参数 (Path)

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | integer | 是 | 员工ID |

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": true
}
```

---

### 7. 警告员工

- **接口编号**: REQ-F008-07
- **请求方式**: POST
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage/{employeeId}/warn`
- **接口说明**: 向员工发送警告通知（APP推送+站内信），不变更员工状态

#### 请求参数 (Path)

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | integer | 是 | 员工ID |

#### 请求体 (Body)

| 参数名 | 类型 | 必填 | 说明 | 校验规则 |
|--------|------|------|------|----------|
| warnReason | string | 是 | 警告原因 | 不能为空，最多200字 |

**请求示例**

```json
{
  "warnReason": "服务态度不佳，请改进"
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

---

### 8. 修改佣金比例

- **接口编号**: REQ-F008-08
- **请求方式**: POST
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage/{employeeId}/update-commission`
- **接口说明**: 修改员工佣金比例（0.00~100.00）

#### 请求参数 (Path)

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| employeeId | integer | 是 | 员工ID |

#### 请求体 (Body)

| 参数名 | 类型 | 必填 | 说明 | 校验规则 |
|--------|------|------|------|----------|
| commissionRate | number | 是 | 佣金比例 | 不能小于0，不能大于100，最多3位整数2位小数 |

**请求示例**

```json
{
  "commissionRate": 5.50
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

---

### 9. 岗位类型下拉列表

- **接口编号**: REQ-F008-09
- **请求方式**: GET
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage/job-types`
- **接口说明**: 查询启用中的岗位类型列表，供员工管理筛选条件下拉使用

#### 请求参数

无

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "id": 1,
      "name": "客服专员",
      "code": "CUSTOMER_SERVICE",
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

**响应字段说明**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 岗位类型ID |
| name | string | 岗位类型名称 |
| code | string | 岗位类型编码 |
| status | integer | 状态：0-禁用，1-启用 |

---

### 10. 员工状态枚举列表

- **接口编号**: REQ-F008-10
- **请求方式**: GET
- **请求路径**: `/mall-admin/admin/api/v1/employee-manage/employee-status-options`
- **接口说明**: 查询员工状态枚举（value+label），供员工管理筛选条件下拉使用

#### 请求参数

无

#### 响应数据

**成功响应 (200)**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": [
    {
      "value": 0,
      "label": "未营业"
    },
    {
      "value": 1,
      "label": "休息中"
    },
    {
      "value": 2,
      "label": "营业中"
    },
    {
      "value": 3,
      "label": "强制离线"
    },
    {
      "value": 4,
      "label": "已封禁"
    },
    {
      "value": 5,
      "label": "已注销"
    }
  ]
}
```

**响应字段说明**

| 字段 | 类型 | 说明 |
|------|------|------|
| value | integer | 状态值 |
| label | string | 状态描述（展示文案） |

---

## 员工状态说明

| 状态值 | 状态名称 | 说明 |
|--------|----------|------|
| 0 | 未营业 | 初始状态 |
| 1 | 休息中 | 员工主动休息 |
| 2 | 营业中 | 正常在线营业 |
| 3 | 强制离线 | 被管理员强制下线 |
| 4 | 已封禁 | 被封禁，不可逆 |
| 5 | 已注销 | 已注销，不可逆 |

---

## 通用响应格式

### 成功响应

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {}
}
```

### 错误响应

```json
{
  "code": 500,
  "message": "错误信息",
  "data": null
}
```

### 响应码说明

| 响应码 | 说明 |
|--------|------|
| 200 | 操作成功 |
| 400 | 请求参数错误 |
| 401 | 未登录或登录已过期 |
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |
