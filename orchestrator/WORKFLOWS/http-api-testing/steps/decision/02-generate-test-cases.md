# Step: 生成测试用例

## 目的
生成标准化测试用例文件。

## 输入
- `test_strategy`: 测试策略
- `tech_spec`: 技术规格书

## 输出
- `test_cases`: 测试用例集合

## 覆盖范围

**仅覆盖门面层接口（Facade Layer）**，即路径前缀为以下之一的接口：
- `/admin/api/v1/`（管理端）
- `/merchant/api/v1/`（商家端）
- `/app/api/v1/`（APP端）

**明确排除**应用层内部接口（路径前缀 `/inner/api/v1/`），内部接口不生成测试用例。

## 对应 HTTP 文件规范

测试用例与 HTTP 文件一一对应，文件结构如下：

```
outputs/data/http/{模块名}/
├── {controller-name}-api.http         # local 环境（直连门面服务，无 Context Path，无 token）
└── {controller-name}-api.dev.http     # dev 环境（走网关，有 Context Path，有 Authorization）
```

- **local 版本**：host 为门面服务直连地址，URL 不含 Context Path，无 Authorization header
- **dev 版本**：host 为网关地址（`{gateway-ip}:8080`），URL 含 Context Path（`/{service-name}/`），每个请求携带 `Authorization: Bearer {{token}}`

## URL 规范（仅 dev 版本）

dev 版本测试用例中的请求路径必须携带服务上下文路径（Context Path），格式为 `/{service-name}/{path}`，
与 Swagger 文档保持一致。

例如：门面服务 `mall-admin`，接口路径 `/admin/api/v1/job-type/page`
→ dev 版本 path：`/mall-admin/admin/api/v1/job-type/page`
→ local 版本 path：`/admin/api/v1/job-type/page`

## 用例结构

```yaml
test_case:
  id: TC001
  name: 创建{Name}-成功
  interface: IF001
  priority: P0
  request:
    method: POST
    path: /{service-name}/admin/api/v1/{path}/create
    headers:
      Content-Type: application/json
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
