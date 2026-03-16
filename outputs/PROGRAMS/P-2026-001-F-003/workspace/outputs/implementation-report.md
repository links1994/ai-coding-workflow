# Feature 实现报告: F-003 名额配置管理

> Feature ID: F-003
> 生成时间: 2026-03-10
> 基于流程: feature-implementation v1.0.0

## 1. Feature 定义摘要

```yaml
feature:
  id: F-003
  name: 名额配置管理
  domain: 配置管理域
  module: mall-agent-employee-service
  priority: P0
  description: 提供智能员工名额的查询、校验消耗、释放、销售额解锁能力
```

## 2. 服务分层分析

| 服务名称 | 分层 | 职责 | 生成内容 |
|----------|------|------|----------|
| mall-admin | facade | 管理后台门面服务 | QuotaConfigAdminController |
| mall-toc-service | facade | 用户端门面服务 | QuotaAppController |
| mall-agent-employee-service | application | 智能体员工应用服务 | InnerController、QueryService、ManageService |
| mall-inner-api | api | 内部服务接口定义 | Feign接口（合并至AgentEmployeeRemoteService） |

## 3. 生成文件清单

### 3.1 数据库表

| 表名 | 说明 |
|------|------|
| `aim_agent_configs` | 通用配置表（存储 QUOTA 类型配置） |
| `aim_agent_user_quota` | 用户名额汇总表 |

### 3.2 应用层接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/inner/api/v1/quota/user-quota` | 查询用户名额信息 |
| POST | `/inner/api/v1/quota/check` | 校验并消耗名额 |
| POST | `/inner/api/v1/quota/release` | 释放名额 |
| POST | `/inner/api/v1/quota/unlock` | 销售额解锁名额 |
| GET | `/inner/api/v1/quota/config` | 查询全量名额配置 |
| POST | `/inner/api/v1/quota/config/save` | 保存名额配置 |

### 3.3 门面层接口

**mall-admin**:
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/admin/api/v1/quota-config` | 获取名额配置 |
| PUT | `/admin/api/v1/quota-config` | 保存名额配置 |

**mall-toc-service**:
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/app/api/v1/quota/my-quota` | 查询我的名额 |

## 4. 关键设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 通用配置表设计 | aim_agent_configs | 通过 biz_type + config_key 区分配置域，灵活扩展 |
| 乐观锁并发控制 | version 字段 + @Version | 名额扣减/释放防并发超卖 |
| 新用户自动初始化 | 首次查询时初始化 | 按用户等级分配初始名额 |
| 销售额解锁防重 | unlocked_thresholds JSON 数组 | 同一阈值只能解锁一次 |
| Feign 接口合并 | 合并至 AgentEmployeeRemoteService | 遵循单 Feign 客户端原则 |

## 5. 验收标准验证

| 验收标准 | 状态 | 验证方式 |
|----------|------|----------|
| 用户名额查询（新用户自动初始化） | ✅ 完成 | HTTP接口测试 |
| 校验并消耗名额（乐观锁防并发） | ✅ 完成 | 并发测试 |
| 释放名额 | ✅ 完成 | HTTP接口测试 |
| 销售额解锁名额（防重复解锁） | ✅ 完成 | HTTP接口测试 |
| 管理端查询/保存配置 | ✅ 完成 | HTTP接口测试 |
| 用户端查询自己的名额 | ✅ 完成 | HTTP接口测试 |

## 6. 待办事项

| 描述 | 依赖 | 预计完成时间 |
|------|------|--------------|
| 调用 mall-client 查用户等级 | mall-client getUserLevel 接口 | mall-client 提供接口后 |

---

*报告生成时间: 2026-03-10*
