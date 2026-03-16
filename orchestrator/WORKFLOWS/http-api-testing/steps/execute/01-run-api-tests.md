# Step: 执行 API 测试

## 目的
执行 HTTP 接口自动化测试。

## 输入
- `test_plan`: 测试计划
- `prepared_test_data`: 准备好的测试数据

## 输出
- `test_results`: 测试结果
- `test_report`: 测试报告

## 执行步骤

### 1. 按顺序执行用例

```yaml
execution:
  - phase: 冒烟测试
    cases: [TC001, TC002]
  - phase: 功能测试
    cases: [TC003, TC004, ...]
```

### 2. 记录请求/响应

```yaml
test_result:
  case_id: TC001
  status: passed
  request:
    method: POST
    url: http://localhost:8080/admin/api/v1/{path}/create
    headers: {...}
    body: {...}
  response:
    status: 200
    headers: {...}
    body: {...}
  duration: 150ms
  assertions:
    - type: status_code
      expected: 200
      actual: 200
      status: passed
```

### 3. 执行断言验证

- 状态码断言
- JSON 路径断言
- 响应时间断言
- 自定义脚本断言

## 输出格式

```yaml
test_results:
  summary:
    total: 20
    passed: 18
    failed: 2
    skipped: 0
    duration: 5000ms
  by_priority:
    P0: {total: 10, passed: 10, failed: 0}
    P1: {total: 8, passed: 6, failed: 2}
    P2: {total: 2, passed: 2, failed: 0}
  details:
    - case_id: TC001
      status: passed
      ...
```
