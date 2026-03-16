# Step: 验证测试结果

## 目的
验证测试结果是否满足通过标准。

## 输入
- `test_results`: 测试结果
- `test_plan`: 测试计划

## 输出
- `validation_result`: 验证结果

## 验证标准

### 1. P0 用例

- 通过率必须 100%
- 不允许有任何失败

### 2. P1 用例

- 通过率 >= 90%
- 失败用例需记录原因

### 3. 无阻塞性缺陷

- 核心功能必须正常
- 无系统级错误

## 输出格式

```yaml
validation_result:
  status: passed  # passed / failed
  criteria:
    P0_pass_rate:
      required: 100
      actual: 100
      status: passed
    P1_pass_rate:
      required: 90
      actual: 85
      status: failed
  blockers: []
  warnings:
    - "P1用例通过率低于90%"
```
