# Step: 验证功能完整性

## 目的
验证生成的代码是否完整实现了 Feature 定义中的所有功能点。

## 输入
- `feature_definition`: Feature 定义
- `application_layer_code`: 应用服务层代码
- `facade_layer_code`: 门面服务层代码

## 输出
- `completeness_check`: 完整性验证报告

## 验证维度

### 1. 功能点覆盖检查

根据 `feature_definition.description` 和 `acceptance_criteria`，检查：

| 功能点 | 对应接口 | 状态 |
|--------|----------|------|
| 创建操作 | POST /create | ✅/❌ |
| 更新操作 | POST /update | ✅/❌ |
| 删除操作 | POST /delete 或 /status | ✅/❌ |
| 查询详情 | GET /detail | ✅/❌ |
| 分页查询 | POST /page | ✅/❌ |

### 2. 验收标准验证

逐项验证 `acceptance_criteria`：

```yaml
acceptance_criteria:
  - criteria: "支持岗位CRUD操作"
    validation:
      - check: "create 接口存在"
        status: ✅
      - check: "update 接口存在"
        status: ✅
      - check: "delete 接口存在"
        status: ✅
      - check: "getById 接口存在"
        status: ✅
        
  - criteria: "返回该岗位下关联员工数"
    validation:
      - check: "JobTypeApiResponse 包含 employeeCount 字段"
        status: ✅
      - check: "ApplicationService 中填充 employeeCount"
        status: ✅
        
  - criteria: "启用/禁用状态正确联动"
    validation:
      - check: "updateStatus 接口存在"
        status: ✅
      - check: "状态变更逻辑正确"
        status: ✅
        
  - criteria: "接口返回符合CommonResult规范"
    validation:
      - check: "所有 Controller 返回 CommonResult"
        status: ✅
      - check: "Feign 接口返回 CommonResult"
        status: ✅
```

### 3. 服务覆盖检查

验证 `feature_definition.services` 中所有服务都已生成代码：

| 服务 | 分层 | 代码生成状态 | 缺失文件 |
|------|------|--------------|----------|
| mall-admin | facade | ✅ | - |
| mall-agent-employee-service | application | ✅ | - |

### 4. 数据库表覆盖检查

验证 `feature_definition.tables` 中所有表都有对应代码：

| 表名 | Entity | Mapper | SQL | 状态 |
|------|--------|--------|-----|------|
| aim_agent_job_type | ✅ | ✅ | ✅ | 完整 |

### 5. 接口一致性检查

验证各层接口参数一致：

| 接口 | Facade Request | Feign ApiRequest | 字段一致性 |
|------|----------------|------------------|------------|
| create | JobTypeCreateRequest | JobTypeCreateApiRequest | ✅ |
| update | JobTypeUpdateRequest | JobTypeUpdateApiRequest | ✅ |

## 完整性报告格式

```yaml
completeness_check:
  summary:
    total_criteria: 4
    passed: 4
    failed: 0
    coverage: 100%
    
  functional_coverage:
    status: passed
    operations:
      - operation: create
        facade: ✅
        application: ✅
        feign: ✅
      - operation: update
        facade: ✅
        application: ✅
        feign: ✅
      - operation: delete
        facade: ✅
        application: ✅
        feign: ✅
      - operation: getById
        facade: ✅
        application: ✅
        feign: ✅
      - operation: page
        facade: ✅
        application: ✅
        feign: ✅
        
  acceptance_criteria:
    - criteria: "支持岗位CRUD操作"
      status: passed
      evidence:
        - "JobTypeAdminController 包含 create/update/delete/getById/page 方法"
        - "JobTypeInnerController 包含对应方法"
        
    - criteria: "返回该岗位下关联员工数"
      status: passed
      evidence:
        - "JobTypeApiResponse.employeeCount 字段存在"
        - "JobTypeApplicationServiceImpl.convertToApiResponse() 中填充 employeeCount"
        
    - criteria: "启用/禁用状态正确联动"
      status: passed
      evidence:
        - "updateStatus 接口存在"
        - "状态变更时更新关联数据"
        
    - criteria: "接口返回符合CommonResult规范"
      status: passed
      evidence:
        - "所有 Controller 方法返回类型为 CommonResult"
        - "所有 Feign 接口方法返回类型为 CommonResult"
        
  service_coverage:
    status: passed
    services:
      - name: mall-admin
        layer: facade
        files_generated: 6
        status: complete
      - name: mall-agent-employee-service
        layer: application
        files_generated: 12
        status: complete
        
  database_coverage:
    status: passed
    tables:
      - name: aim_agent_job_type
        entity: ✅
        mapper: ✅
        sql: ✅
```

## 不完整的处理

当发现功能不完整时：

1. **记录缺失项**
   - 列出未实现的功能点
   - 说明影响范围

2. **生成补充任务**
   - 创建补充代码生成任务
   - 添加到生成计划中

3. **更新状态**
   - 标记 Program 状态为 "incomplete"
   - 记录需要补充的内容
