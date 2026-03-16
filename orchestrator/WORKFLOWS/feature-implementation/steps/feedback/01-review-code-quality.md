# Step: 代码质量审查

## 目的
检查生成的代码是否符合代码生成规范和架构约束。

## 输入
- `application_layer_code`: 应用服务层代码
- `facade_layer_code`: 门面服务层代码

## 输出
- `code_quality_report`: 代码质量审查报告

## 审查维度

### 1. 命名规范检查

| 检查项 | 规范 | 严重程度 |
|--------|------|----------|
| Controller 命名 | AdminController/AppController/InnerController | 错误 |
| Service 命名 | XxxApplicationService/QueryService/ManageService | 错误 |
| DTO 命名 | Request/Response/ApiRequest/ApiResponse | 错误 |
| Mapper 命名 | AimXxxMapper | 错误 |
| Entity 命名 | AimXxxDO | 错误 |

### 2. 分层规范检查

**门面服务层**：
- [ ] Controller 只调用 ApplicationService
- [ ] 禁止直接注入 RemoteService
- [ ] 禁止在门面服务中创建 feign 目录
- [ ] String 参数在 ApplicationService 层去空格

**应用服务层**：
- [ ] 禁止在 Controller 使用 `@Valid`
- [ ] 必须手动编写 `validateXxx()` 方法
- [ ] 禁止在 Controller 解析 Header
- [ ] InnerController 仅支持 GET/POST

### 3. 参数校验检查

| 层级 | 校验方式 | 检查结果 |
|------|----------|----------|
| Facade Controller | 使用 `@Valid` | ✅/❌ |
| Application Controller | 手动 `validateXxx()` | ✅/❌ |
| 请求对象 | 包含必要校验注解 | ✅/❌ |

### 4. 接口规范检查

- [ ] 使用 `@RequestParam` 而非 `@PathVariable`
- [ ] 返回类型统一包装为 `CommonResult`
- [ ] 时间字段使用 `@JsonFormat`
- [ ] Feign 接口路径符合规范（/inner/api/v1/）

### 5. 代码重复检查

- [ ] 不存在重复的 DTO 定义
- [ ] 不存在重复的业务逻辑
- [ ] 可复用的转换逻辑已提取

## 审查报告格式

```yaml
code_quality_report:
  summary:
    total_files: 20
    passed: 18
    warnings: 2
    errors: 0
    
  by_category:
    naming:
      status: passed
      details: []
      
    layering:
      status: warning
      details:
        - file: "mall-admin/service/JobTypeApplicationServiceImpl.java"
          issue: "String 参数未在入口处统一去空格"
          severity: warning
          suggestion: "在方法入口处添加 StringUtils.trim() 处理"
          
    validation:
      status: passed
      details: []
      
    interface:
      status: passed
      details: []
      
  files:
    - file_path: "mall-admin/controller/admin/JobTypeAdminController.java"
      status: passed
      checks:
        naming: ✅
        layering: ✅
        validation: ✅
        interface: ✅
        
    - file_path: "mall-agent-employee-service/controller/inner/JobTypeInnerController.java"
      status: warning
      checks:
        naming: ✅
        layering: ⚠️
        validation: ✅
        interface: ✅
      issues:
        - "缺少 validateUpdateRequest() 方法的空值检查"
```

## 自动修复建议

对于常见问题，提供自动修复建议：

1. **缺少去空格处理**
   ```java
   // 建议添加
   String trimmedName = StringUtils.trim(name);
   ```

2. **缺少校验方法**
   ```java
   // 建议添加
   private void validateXxxRequest(XxxRequest request) {
       if (request == null) {
           throw new BusinessException(ErrorCode.PARAM_ERROR, "请求参数不能为空");
       }
   }
   ```

3. **命名不规范**
   - 提供正确的命名建议
   - 说明命名规范依据
