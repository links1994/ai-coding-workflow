# Step: 生成 HTTP 测试文件

## 目的
基于生成的 Controller 代码和 tech-spec，生成 HTTP 接口测试文件。

## 输入
- `tech_spec`: 技术规格书
- `facade_layer_code`: 门面服务层代码
- `database_schema`: 数据库表结构
- `test_data_sql`: 测试数据 SQL

## 输出
- `test_files`: HTTP 测试文件集合

## 执行步骤

### 1. 解析接口定义

从 facade_layer_code 中提取：
- Controller 类和方法
- @RequestMapping 路径
- 请求方法（GET/POST/PUT/DELETE）
- 请求参数类型
- 响应类型

### 2. 生成测试场景

每个接口生成以下测试场景：

**正常场景**：
- 必填参数测试
- 完整参数测试

**异常场景**：
- 参数缺失测试
- 参数非法值测试
- 边界值测试

### 3. 构建 HTTP 请求

**格式**：
```http
### 创建{Name}-成功
POST {{baseUrl}}/admin/api/v1/{path}/create
Content-Type: application/json
Authorization: Bearer {{token}}

{
    "name": "测试名称",
    "description": "测试描述",
    "sortOrder": 1
}

> {%
    client.test("状态码为200", function() {
        client.assert(response.status === 200, "状态码应为200");
    });
    client.test("返回成功", function() {
        client.assert(response.body.code === 200, "返回码应为200");
    });
%}
```

### 4. 组织测试文件

按功能模块组织：
```
outputs/data/http/
└── {module}-api.http
```

## 输出格式

```http
# {模块名} API 测试
# @baseUrl = http://localhost:8080

### 健康检查
GET {{baseUrl}}/actuator/health

### 创建{Name}-成功
POST {{baseUrl}}/admin/api/v1/{path}/create
Content-Type: application/json
Authorization: Bearer {{token}}

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

### 分页查询{Name}
POST {{baseUrl}}/admin/api/v1/{path}/page
Content-Type: application/json

{
    "pageNum": 1,
    "pageSize": 10
}
```

## 环境变量

```http
# 环境变量定义
@baseUrl = http://localhost:8080
@token = eyJhbGciOiJIUzI1NiIs...
```

## 断言规则

- 状态码检查：200
- 返回码检查：code === 200
- 响应体字段检查
- 响应时间检查（可选）

## 命名规则

- 文件命名：`{module}-api.http`
- 请求命名：`{操作}-{场景}`
- 按功能模块分组

## 追加模式

同一 Controller 新增接口时：
1. 读取现有 HTTP 文件
2. 在文件末尾追加新接口
3. 添加注释标记：`### [Program-ID] {功能描述}`
