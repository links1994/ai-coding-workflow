# Step: 创建文件清单

## 目的
根据 Feature 定义和代码生成策略，列出需要生成的所有文件。

## 输入
- `feature_definition`: Feature 定义
- `code_generation_strategy`: 代码生成策略

## 输出
- `file_inventory`: 文件清单

## 文件类型映射

### 1. Data 层文件（基础数据服务）

| 文件类型 | 命名规范 | 路径模式 |
|----------|----------|----------|
| Entity/DO | `Aim{Name}DO` | `domain/entity/` |
| Mapper Interface | `Aim{Name}Mapper` | `mapper/` |
| Mapper XML | `Aim{Name}Mapper.xml` | `mapper/xml/` |
| QueryService | `{Name}QueryService` / `Impl` | `service/` |
| ManageService | `{Name}ManageService` / `Impl` | `service/` |
| InnerController | `{Name}InnerController` | `controller/inner/` |

### 2. Application 层文件（应用服务）

| 文件类型 | 命名规范 | 路径模式 |
|----------|----------|----------|
| Entity/DO | `Aim{Name}DO` | `domain/entity/` |
| Mapper Interface | `Aim{Name}Mapper` | `mapper/` |
| Mapper XML | `Aim{Name}Mapper.xml` | `mapper/xml/` |
| QueryService | `{Name}QueryService` / `Impl` | `service/` |
| ManageService | `{Name}ManageService` / `Impl` | `service/` |
| ApplicationService | `{Name}ApplicationService` / `Impl` | `service/` |
| InnerController | `{Name}InnerController` | `controller/inner/` |
| Feign ApiRequest | `{Name}ApiRequest` | `{inner-api-service}/request/` |
| Feign ApiResponse | `{Name}ApiResponse` | `{inner-api-service}/response/` |
| RemoteService | `{Name}RemoteService` | `{inner-api-service}/feign/` |

### 3. Facade 层文件（门面服务）

| 文件类型 | 命名规范 | 路径模式 |
|----------|----------|----------|
| AdminController | `{Name}AdminController` | `controller/admin/` |
| AppController | `{Name}AppController` | `controller/app/` |
| ApplicationService | `{Name}ApplicationService` / `Impl` | `service/` |
| Request DTO | `{Name}Request` | `dto/request/` |
| Response DTO | `{Name}Response` / `{Name}VO` | `dto/response/` |

### 4. 数据库文件

| 文件类型 | 命名规范 | 路径模式 |
|----------|----------|----------|
| 建表 SQL | `create_xxx_table.sql` | `sql/` |

### 5. 测试文件

| 文件类型 | 命名规范 | 路径模式 |
|----------|----------|----------|
| HTTP Test | `{Name}ControllerTest.http` | `test/http/` |

## 文件清单生成逻辑

1. **根据 tables 生成数据库相关文件**
   - 每个 table → Entity + Mapper + SQL

2. **根据 services 生成分层文件**
   - facade 层 → Controller + ApplicationService + DTO
   - application 层 → 完整分层 + Feign 接口
   - data 层 → 基础数据访问层

3. **根据 interfaces 数量估算文件数**
   - 每个接口通常对应：Controller 方法 + Service 方法

## 输出格式

```yaml
file_inventory:
  total_files: 15
  
  by_layer:
    data:
      - file_path: "{data-service}/domain/entity/Aim{Name}DO.java"
        file_type: entity
        service: {data-service}
        generated: false
        
    application:
      - file_path: "{app-service}/controller/inner/{Name}InnerController.java"
        file_type: controller
        service: {app-service}
        generated: false
        dependencies:
          - "{inner-api-service}/feign/{Name}RemoteService.java"
          
    facade:
      - file_path: "{facade-service}/controller/admin/{Name}AdminController.java"
        file_type: controller
        service: {facade-service}
        generated: false
        dependencies:
          - "{inner-api-service}/feign/{Name}RemoteService.java"
          
  feign_interfaces:
    - file_path: "{inner-api-service}/feign/{Name}RemoteService.java"
      methods:
        - create{Name}
        - update{Name}
        - get{Name}ById
        - page{Name}s
      
  database:
    - file_path: "sql/create_{table_name}.sql"
      table: {table_name}
```

## 约束检查

- 检查文件命名是否符合规范
- 验证文件路径是否正确
- 确保没有重复文件
- 确认依赖文件已列出
