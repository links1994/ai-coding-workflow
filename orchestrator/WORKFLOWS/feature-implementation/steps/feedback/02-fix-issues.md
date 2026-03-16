# Step: 修复代码问题

## 目的
根据代码质量审查报告，修复发现的问题。

## 输入
- `tech_spec`: 技术规格书
- `code_quality_report`: 代码质量审查报告

## 输出
- `fixed_code`: 修复后的代码

## 执行步骤

### 1. 解析审查报告

从 code_quality_report 中提取：
- 错误列表（必须修复）
- 警告列表（建议修复）
- 提示列表（可选修复）
- 自动修复建议

### 2. 分类处理问题

**命名规范问题**：
- 类名不符合规范
- 方法名不符合规范
- 字段名不符合规范

**分层规范问题**：
- Controller 直接调用 RemoteService
- String 参数未去空格
- 缺少参数校验

**接口规范问题**：
- 使用了 @PathVariable
- 返回类型未包装
- 缺少 @JsonFormat

### 3. 自动修复

对于可自动修复的问题：

**命名修复**：
```java
// 修复前
public class {Name}Controller {}

// 修复后
public class {Name}AdminController {}
```

**去空格修复**：
```java
// 修复前
public void create(String name) {
    // 直接使用 name
}

// 修复后
public void create(String name) {
    String trimmedName = StringUtils.trim(name);
    // 使用 trimmedName
}
```

**校验方法修复**：
```java
// 添加校验方法
private void validateCreateRequest(CreateRequest request) {
    if (request == null) {
        throw new BusinessException(ErrorCode.PARAM_ERROR, "请求参数不能为空");
    }
    if (StringUtils.isBlank(request.getName())) {
        throw new BusinessException(ErrorCode.PARAM_ERROR, "名称不能为空");
    }
}
```

### 4. 人工确认

对于无法自动修复的问题：
- 列出需要人工处理的问题
- 提供修复建议
- 等待用户确认

## 修复优先级

1. **P0 - 错误**：必须修复，阻塞代码生成
2. **P1 - 警告**：建议修复，影响代码质量
3. **P2 - 提示**：可选修复，优化建议

## 输出格式

```yaml
fix_result:
  summary:
    total_issues: 10
    auto_fixed: 8
    manual_fix_required: 2
    
  fixed_files:
    - file_path: "{facade-service}/controller/{Name}AdminController.java"
      issues_fixed:
        - type: "naming"
          description: "类名添加 Admin 后缀"
        - type: "validation"
          description: "添加 @Valid 注解"
          
  manual_fixes:
    - file_path: "{app-service}/service/{Name}ApplicationService.java"
      issue: "业务逻辑过于复杂，建议拆分"
      suggestion: "提取独立的业务规则校验类"
```

## 修复后验证

修复完成后，重新运行代码质量审查：
1. 检查修复是否生效
2. 确认无新的问题引入
3. 更新代码质量报告
