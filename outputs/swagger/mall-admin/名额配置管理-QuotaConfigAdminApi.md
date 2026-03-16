---
service: mall-admin
controller: QuotaConfigAdminController
module: QuotaConfigAdmin
title: 名额配置管理
version: v1.0.0
updated_at: 2026-03-16
updated_by: P-2026-001-F-003
---

# 名额配置管理

## 基本信息

| 属性 | 值 |
|------|------|
| Controller | QuotaConfigAdminController |
| 路径前缀 | /mall-admin/admin/api/v1/quota-config |
| Tag | 智能员工管理/名额配置 |

---

## 接口列表

### 1. 查询名额配置

获取当前全局名额配置。

**请求信息**

| 属性 | 值 |
|------|------|
| 接口路径 | GET /mall-admin/admin/api/v1/quota-config |
| 接口描述 | 获取当前全局名额配置 |

**请求参数**

无

**响应参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | object | 名额配置信息 |
| data.levelQuotas | object | 各等级初始名额，key 为等级枚举名（A/B/C/D/E），value 为名额数量 |
| data.salesUnlockConfig | object | 销售额解锁配置 |
| data.salesUnlockConfig.unlockCeiling | integer | 销售额解锁上限（分） |
| data.salesUnlockConfig.unlockRules | array | 销售额解锁规则列表 |
| data.salesUnlockConfig.unlockRules[].salesAmount | integer | 销售额阈值（分） |
| data.salesUnlockConfig.unlockRules[].unlockCount | integer | 解锁名额数量 |
| data.quotaUnlockSetting | object | 名额解锁参数配置 |
| data.quotaUnlockSetting.quotaUnlockLimit | integer | 名额解锁总上限 |
| data.quotaUnlockSetting.defaultUnlockCount | integer | 默认解锁人数 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "levelQuotas": {
      "A": 10,
      "B": 8,
      "C": 6,
      "D": 4,
      "E": 2
    },
    "salesUnlockConfig": {
      "unlockCeiling": 100000000,
      "unlockRules": [
        {
          "salesAmount": 1000000,
          "unlockCount": 1
        },
        {
          "salesAmount": 5000000,
          "unlockCount": 2
        }
      ]
    },
    "quotaUnlockSetting": {
      "quotaUnlockLimit": 100,
      "defaultUnlockCount": 1
    }
  }
}
```

---

### 2. 保存名额配置

整体覆盖保存名额配置（各等级初始名额、解锁规则、全局参数）。

**请求信息**

| 属性 | 值 |
|------|------|
| 接口路径 | PUT /mall-admin/admin/api/v1/quota-config |
| 接口描述 | 整体覆盖保存名额配置（各等级初始名额、解锁规则、全局参数） |

**请求参数**

| 参数名 | 类型 | 必填 | 说明 | 校验规则 |
|--------|------|------|------|----------|
| levelQuotas | object | 是 | 各等级初始名额，key 为等级枚举名（A/B/C/D/E），value 为名额数量 | 不能为空，值范围 0-100 |
| salesUnlockConfig | object | 是 | 销售额解锁配置 | 不能为空 |
| salesUnlockConfig.unlockCeiling | integer | 是 | 销售额解锁上限（分） | 必须大于 0 |
| salesUnlockConfig.unlockRules | array | 否 | 销售额解锁规则列表 | - |
| salesUnlockConfig.unlockRules[].salesAmount | integer | 是 | 销售额阈值（分） | 必须大于 0 |
| salesUnlockConfig.unlockRules[].unlockCount | integer | 是 | 解锁名额数量 | 必须大于 0 |
| quotaUnlockSetting | object | 是 | 名额解锁参数配置 | 不能为空 |
| quotaUnlockSetting.quotaUnlockLimit | integer | 是 | 名额解锁总上限 | 必须大于 0 |
| quotaUnlockSetting.defaultUnlockCount | integer | 是 | 默认解锁人数 | 必须大于 0 |

**请求示例**

```json
{
  "levelQuotas": {
    "A": 10,
    "B": 8,
    "C": 6,
    "D": 4,
    "E": 2
  },
  "salesUnlockConfig": {
    "unlockCeiling": 100000000,
    "unlockRules": [
      {
        "salesAmount": 1000000,
        "unlockCount": 1
      },
      {
        "salesAmount": 5000000,
        "unlockCount": 2
      }
    ]
  },
  "quotaUnlockSetting": {
    "quotaUnlockLimit": 100,
    "defaultUnlockCount": 1
  }
}
```

**响应参数**

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 响应码 |
| message | string | 响应消息 |
| data | null | 无数据返回 |

**响应示例**

```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

---

## 数据模型

### QuotaConfigResponse

名额配置查询响应

| 字段名 | 类型 | 说明 |
|--------|------|------|
| levelQuotas | Map<String, Integer> | 各等级初始名额，key 为等级枚举名（A/B/C/D/E），value 为名额数量 |
| salesUnlockConfig | SalesUnlockConfig | 销售额解锁配置 |
| quotaUnlockSetting | QuotaUnlockSetting | 名额解锁参数配置 |

### SalesUnlockConfig

销售额解锁配置

| 字段名 | 类型 | 说明 |
|--------|------|------|
| unlockCeiling | Long | 销售额解锁上限（分） |
| unlockRules | List<UnlockRuleItem> | 销售额解锁规则列表 |

### QuotaUnlockSetting

名额解锁参数配置

| 字段名 | 类型 | 说明 |
|--------|------|------|
| quotaUnlockLimit | Integer | 名额解锁总上限 |
| defaultUnlockCount | Integer | 默认解锁人数 |

### UnlockRuleItem

销售额解锁规则条目

| 字段名 | 类型 | 说明 |
|--------|------|------|
| salesAmount | Long | 销售额阈值（分） |
| unlockCount | Integer | 解锁名额数量 |

### QuotaSaveRequest

名额配置保存请求

| 字段名 | 类型 | 必填 | 说明 | 校验规则 |
|--------|------|------|------|----------|
| levelQuotas | Map<String, Integer> | 是 | 各等级初始名额 | 不能为空，值范围 0-100 |
| salesUnlockConfig | SalesUnlockConfig | 是 | 销售额解锁配置 | 不能为空，unlockCeiling 必须大于 0 |
| quotaUnlockSetting | QuotaUnlockSetting | 是 | 名额解锁参数配置 | 不能为空，quotaUnlockLimit 和 defaultUnlockCount 必须大于 0 |
