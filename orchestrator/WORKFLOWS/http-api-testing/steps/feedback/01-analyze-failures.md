# Step: 分析失败用例

## 目的
分析测试失败原因。

## 输入
- `test_results`: 测试结果

## 输出
- `failure_analysis`: 失败分析

## 分析维度

### 1. 失败分类

- **代码缺陷**：业务逻辑错误
- **环境问题**：配置、网络、数据库
- **用例问题**：断言错误、数据问题

### 2. 根因定位

```yaml
failure_analysis:
  failures:
    - case_id: TC005
      type: code_defect
      root_cause: "空指针异常"
      location: "{Name}Service.java:45"
      suggestion: "添加空值检查"
    - case_id: TC008
      type: environment
      root_cause: "数据库连接超时"
      suggestion: "检查数据库连接池配置"
```

### 3. 修复成本评估

- 高：架构级问题
- 中：业务逻辑问题
- 低：配置/数据问题
