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
| Entity/DO | `AimXxxDO` | `domain/entity/` |
| Mapper Interface | `AimXxxMapper` | `mapper/` |
| Mapper XML | `AimXxxMapper.xml` | `mapper/xml/` |
| QueryService | `XxxQueryService` / `Impl` | `service/` |
| ManageService | `XxxManageService` / `Impl` | `service/` |
| InnerController | `XxxInnerController` | `controller/inner/` |

### 2. Application 层文件（应用服务）

| 文件类型 | 命名规范 | 路径模式 |
|----------|----------|----------|
| Entity/DO | `AimXxxDO` | `domain/entity/` |
| Mapper Interface | `AimXxxMapper` | `mapper/` |
| Mapper XML | `AimXxxMapper.xml` | `mapper/xml/` |
| QueryService | `XxxQueryService` / `Impl` | `service/` |
| ManageService | `XxxManageService` / `Impl` | `service/` |
| ApplicationService | `XxxApplicationService` / `Impl` | `service/` |
| InnerController | `XxxInnerController` | `controller/inner/` |
| Feign ApiRequest | `XxxApiRequest` | `mall-inner-api/request/` |
| Feign ApiResponse | `XxxApiResponse` | `mall-inner-api/response/` |
| RemoteService | `XxxRemoteService` | `mall-inner-api/feign/` |

### 3. Facade 层文件（门面服务）

| 文件类型 | 命名规范 | 路径模式 |
|----------|----------|----------|
| AdminController | `XxxAdminController` | `controller/admin/` |
| AppController | `XxxAppController` | `controller/app/` |
| ApplicationService | `XxxApplicationService` / `Impl` | `service/` |
| Request DTO | `XxxRequest` | `dto/request/` |
| Response DTO | `XxxResponse` / `XxxVO` | `dto/response/` |

### 4. 数据库文件

| 文件类型 | 命名规范 | 路径模式 |
|----------|----------|----------|
| 建表 SQL | `create_xxx_table.sql` | `sql/` |

### 5. 测试文件

| 文件类型 | 命名规范 | 路径模式 |
|----------|----------|----------|
| HTTP Test | `XxxControllerTest.http` | `test/http/` |

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
      - file_path: "mall-product/domain/entity/AimProductDO.java"
        file_type: entity
        service: mall-product
        generated: false
        
    application:
      - file_path: "mall-agent-employee-service/controller/inner/JobTypeInnerController.java"
        file_type: controller
        service: mall-agent-employee-service
        generated: false
        dependencies:
          - "mall-inner-api/feign/AgentEmployeeRemoteService.java"
          
    facade:
      - file_path: "mall-admin/controller/admin/JobTypeAdminController.java"
        file_type: controller
        service: mall-admin
        generated: false
        dependencies:
          - "mall-inner-api/feign/AgentEmployeeRemoteService.java"
          
  feign_interfaces:
    - file_path: "mall-inner-api/feign/AgentEmployeeRemoteService.java"
      methods:
        - createJobType
        - updateJobType
        - getJobTypeById
        - pageJobTypes
      
  database:
    - file_path: "sql/create_aim_agent_job_type.sql"
      table: aim_agent_job_type
```

## 约束检查

- 检查文件命名是否符合规范
- 验证文件路径是否正确
- 确保没有重复文件
- 确认依赖文件已列出
