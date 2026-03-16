# Step: 生成测试用例

## 目的
生成标准化测试用例文件。

## 输入
- `test_strategy`: 测试策略
- `tech_spec`: 技术规格书

## 输出
- `test_cases`: 测试用例集合

## 用例结构

```yaml
test_case:
  id: TC001
  name: 创建{Name}-成功
  interface: IF001
  priority: P0
  request:
    method: POST
    path: /admin/api/v1/{path}/create
    headers:
      Content-Type: application/json
      Authorization: Bearer {{token}}
    body:
      name: "测试{Name}"
      description: "测试描述"
      sortOrder: 1
  expected:
    status: 200
    code: 200
    data:
      id: "@exists"
  assertions:
    - type: status_code
      expected: 200
    - type: json_path
      path: $.code
      expected: 200
    - type: json_path
      path: $.data.id
      operator: exists
```

## 生成规则

1. **正常场景**：每个必填参数组合生成一个用例
2. **异常场景**：每个校验规则生成一个用例
3. **边界场景**：边界值各生成一个用例
