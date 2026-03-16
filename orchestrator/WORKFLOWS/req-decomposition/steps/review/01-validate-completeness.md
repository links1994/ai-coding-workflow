# Step: 验证完整性

## 目的
验证拆分是否完整覆盖原始需求。

## 输入
- `decomposition_report`: 拆分报告
- `product_requirements`: 产品需求

## 输出
- `completeness_check`: 完整性检查结果

## 验证项

### 1. 功能覆盖

- 所有功能点都有对应 Feature
- 验收标准完整

### 2. 非功能覆盖

- 性能要求已考虑
- 安全要求已考虑

### 3. 边界检查

- 最大深度检查
- 最大节点数检查

## 输出格式

```yaml
completeness_check:
  status: passed
  coverage:
    functional: 100%
    non_functional: 100%
  missing: []
```
