# Step: 确定拆分策略

## 目的
确定需求拆分的策略和维度。

## 输入
- `context_analysis`: 上下文分析
- `split_patterns_context`: 历史拆分模式

## 输出
- `split_strategy`: 拆分策略

## 策略选项

### 1. 拆分维度

| 维度 | 适用场景 | 优点 |
|------|----------|------|
| 业务域 | 跨域需求 | 与架构对齐 |
| 技术模块 | 技术复杂 | 降低风险 |
| 用户角色 | 多角色 | 聚焦场景 |

### 2. 拆分深度

- **深度优先**：先拆分到原子需求
- **广度优先**：先识别所有大模块

### 3. 驱动方式

- **功能驱动**：按功能点拆分
- **数据驱动**：按数据实体拆分

## 输出格式

```yaml
split_strategy:
  dimension: business_domain
  approach: depth_first
  driver: functional
  rationale: "与公司微服务架构对齐"
```
