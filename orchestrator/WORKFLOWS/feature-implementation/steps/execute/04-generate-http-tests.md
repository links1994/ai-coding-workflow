# Step: 生成 HTTP 测试文件

## 目的
基于 tech-spec 中的门面层接口定义，生成可直接执行的 HTTP 接口冒烟测试文件。

## 输入
- `tech_spec`: 技术规格书
- `facade_layer_code`: 门面服务层代码

## 输出
- `test_files`: HTTP 测试文件集合

## 覆盖范围

**仅覆盖门面层接口（Facade Layer）**，即路径前缀为以下之一的接口：
- `/admin/api/v1/`（管理端）
- `/merchant/api/v1/`（商家端）
- `/app/api/v1/`（APP端）

**明确排除**应用层内部接口（路径前缀 `/inner/api/v1/`），内部接口不生成此类测试文件。

---

## 文件类型与命名规范

### 目录结构

```
outputs/data/http/{模块名}/
├── {controller-name}-admin-api.http       # 管理端门面接口 local 环境
├── {controller-name}-admin-api.dev.http   # 管理端门面接口 dev 环境（走网关）
├── {controller-name}-app-api.http         # APP端门面接口 local 环境
├── {controller-name}-app-api.dev.http     # APP端门面接口 dev 环境（走网关）
└── {controller-name}-inner-api.http       # 内部接口（应用服务直连，调试用，按需生成）
```

命名规则：
- `{模块名}`：业务功能模块名，kebab-case，如 `job-type`、`knowledge`、`employee-script`
- `{controller-name}`：Controller 对应的业务名，kebab-case，去掉 `Controller` 后缀，如 `job-type-admin`、`knowledge-app`
- 后缀区分：`-api.http`（local）、`-api.dev.http`（dev）、`-inner-api.http`（应用服务内部）

### 三类文件对比

| 类型 | 文件后缀 | Host | Context Path | Authorization |
|------|---------|------|------|------|
| 门面层 local | `-api.http` | 门面服务直连 IP:Port | **无** | **无** |
| 门面层 dev | `-api.dev.http` | 网关 IP:8080 | **有**（`/{service-name}/`） | **有**（`Bearer {{token}}`） |
| 应用层 inner | `-inner-api.http` | 应用服务直连 IP:Port | **无** | **无** |

---

## 格式规范

### 1. 门面层 local（`{controller-name}-api.http`）

直连门面服务，跳过网关，无需 Context Path 和 token。

```http
### {模块名} {端} 接口测试 - local 环境
### Controller: {ControllerClassName}
### Service: {facade-service-name}
### 调用方式：直连门面服务（绕过网关）

@baseUrl = http://192.168.110.101:{port}

### 创建{Name}-成功
POST {{baseUrl}}/admin/api/v1/{path}/create
Content-Type: application/json

{
    "name": "测试名称",
    "description": "测试描述"
}

### 创建{Name}-参数缺失
POST {{baseUrl}}/admin/api/v1/{path}/create
Content-Type: application/json

{
    "description": "缺少name参数"
}
```

### 2. 门面层 dev（`{controller-name}-api.dev.http`）

走网关，需携带 Context Path 和 Authorization token。

```http
### {模块名} {端} 接口测试 - dev 环境
### Controller: {ControllerClassName}
### Service: {facade-service-name}
### 调用方式：经网关（gateway:8080），需有效 token

@gatewayUrl = http://{gateway-ip}:8080
@token = <替换为有效 token>

### 创建{Name}-成功
POST {{gatewayUrl}}/{facade-service-name}/admin/api/v1/{path}/create
Content-Type: application/json
Authorization: Bearer {{token}}

{
    "name": "测试名称",
    "description": "测试描述"
}

### 创建{Name}-参数缺失
POST {{gatewayUrl}}/{facade-service-name}/admin/api/v1/{path}/create
Content-Type: application/json
Authorization: Bearer {{token}}

{
    "description": "缺少name参数"
}
```

### 3. 应用层 inner（`{controller-name}-inner-api.http`）

直连应用服务，调试用，不纳入自动化测试。

```http
### {模块名} 内部接口 - 调试用
### Controller: {NameInnerController}
### Service: {app-service-name}
### 调用方式：直连应用服务（调试专用，不经网关）

@innerHost = http://192.168.110.101:{port}

### 创建{Name}（内部）
POST {{innerHost}}/inner/api/v1/{path}/create
Content-Type: application/json

{
    "name": "测试名称",
    "operatorId": 9001
}
```

---

## 执行步骤

### 1. 解析门面层接口定义

从 facade_layer_code 中提取：
- Controller 类和方法
- @RequestMapping 路径
- 请求方法（GET/POST/PUT/DELETE）
- 请求参数类型（RequestBody / RequestParam / PathVariable）
- 响应类型

### 2. 确定文件归属

- 同一个 Controller 的所有接口放同一个文件
- 一个 Controller 对应一组文件（local + dev）
- 如果同一个业务功能有 AdminController 和 AppController，分别生成对应文件

### 3. 生成测试场景

每个接口生成以下测试场景：

**正常场景**：
- 必填参数测试
- 完整参数测试

**异常场景**：
- 参数缺失测试
- 参数非法值测试
- 边界值测试

### 4. 断言规则

```http
> {%
    client.test("状态码为200", function() {
        client.assert(response.status === 200, "状态码应为200");
    });
    client.test("返回成功", function() {
        client.assert(response.body.code === 200, "返回码应为200");
    });
%}
```

---

## 追加模式

同一 Controller 新增接口时：
1. 读取现有对应 HTTP 文件（local + dev 各一个）
2. 在文件末尾追加新接口
3. 添加注释标记：`### [Program-ID] {功能描述}`
4. local 和 dev 两个文件同步追加
