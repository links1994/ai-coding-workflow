# 代码质量报告: {{feature_id}}

> **生成时间**: {{timestamp}}
> **Program ID**: {{program_id}}
> **功能名称**: {{feature_name}}
> **审查范围**: {{file_count}} 个源文件

---

## 摘要

| 类别 | 严重 | 警告 | 信息 |
|------|------|------|------|
| 命名规范 | {{naming_severe}} | {{naming_warning}} | {{naming_info}} |
| 架构合规 | {{arch_severe}} | {{arch_warning}} | {{arch_info}} |
| 编码规范 | {{code_severe}} | {{code_warning}} | {{code_info}} |
| 操作人ID规范 | {{operator_severe}} | {{operator_warning}} | {{operator_info}} |
| CommonResult规范 | {{result_severe}} | {{result_warning}} | {{result_info}} |
| 已知陷阱 | {{pitfall_severe}} | {{pitfall_warning}} | {{pitfall_info}} |
| 代码异味 | {{smell_severe}} | {{smell_warning}} | {{smell_info}} |
| **合计** | **{{total_severe}}** | **{{total_warning}}** | **{{total_info}}** |

{{#if has_severe_issues}}
> ⚠️ **存在 {{total_severe}} 个严重问题，必须全部修复后方可进入下一阶段**
{{/if}}

---

## 详细问题

### 🔴 严重问题（必须修复）

{{#each severe_issues}}
---

#### [严重-{{@index}}] 【{{category}}】{{title}}

- **文件**: `{{file_path}}`
- **问题描述**: {{description}}
- **违反规范**: {{violation}}
- **影响**: {{impact}}
- **修复方案**:
  {{#each fix_steps}}
  {{@index}}. {{this}}
  {{/each}}

{{/each}}

{{#unless severe_issues}}
> 无严重问题
{{/unless}}

---

### 🟡 警告问题（建议修复）

{{#each warning_issues}}
---

#### [警告-{{@index}}] 【{{category}}】{{title}}

- **文件**: `{{file_path}}`
- **问题描述**: {{description}}
- **修复建议**: {{suggestion}}

{{/each}}

{{#unless warning_issues}}
> 无警告问题
{{/unless}}

---

### 🔵 信息/建议

{{#each info_issues}}

#### [信息-{{@index}}] 【{{category}}】{{title}}

- **文件**: `{{file_path}}`
- **说明**: {{description}}
- **建议**: {{suggestion}}

{{/each}}

---

## DoD 检查结果

### 门面 Controller DoD

| 检查项 | 状态 | 备注 |
|--------|------|------|
| Controller 只注入 ApplicationService | {{facade_controller_inject_only_app_service}} | {{facade_controller_inject_only_app_service_note}} |
| 不存在 try-catch 块 | {{facade_no_try_catch}} | {{facade_no_try_catch_note}} |
| 不存在业务逻辑代码 | {{facade_no_business_logic}} | {{facade_no_business_logic_note}} |
| 包含 @Tag 注解（二级分组格式） | {{facade_has_tag_annotation}} | {{facade_has_tag_annotation_note}} |
| 写操作包含 user Header 参数 | {{facade_has_user_header}} | {{facade_has_user_header_note}} |
| LocalDateTime 字段有 @JsonFormat | {{facade_json_format}} | {{facade_json_format_note}} |

### 内部 Controller DoD

| 检查项 | 状态 | 备注 |
|--------|------|------|
| Controller 只注入 ApplicationService | {{inner_controller_inject_only_app_service}} | {{inner_controller_inject_only_app_service_note}} |
| 禁止解析 @RequestHeader | {{inner_no_request_header}} | {{inner_no_request_header_note}} |
| 使用 XxxApiRequest 结尾 | {{inner_use_api_request}} | {{inner_use_api_request_note}} |
| 禁止使用 @Valid | {{inner_no_valid_annotation}} | {{inner_no_valid_annotation_note}} |
| 包含手动参数校验方法 | {{inner_has_validate_method}} | {{inner_has_validate_method_note}} |

### QueryService DoD

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 禁止使用 MyBatis-Plus 查询 API | {{query_no_mp_api}} | {{query_no_mp_api_note}} |
| 所有查询通过 XML Mapper 实现 | {{query_use_xml_mapper}} | {{query_use_xml_mapper_note}} |
| 禁止 SELECT * | {{query_no_select_star}} | {{query_no_select_star_note}} |
| 包含删除过滤条件 | {{query_has_delete_filter}} | {{query_has_delete_filter_note}} |

### ManageService DoD

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 使用 MyBatis-Plus IService 方法 | {{manage_use_mp_service}} | {{manage_use_mp_service_note}} |
| 写操作标注 @Transactional | {{manage_has_transactional}} | {{manage_has_transactional_note}} |
| 禁止在 ManageService 中查询逻辑 | {{manage_no_query_logic}} | {{manage_no_query_logic_note}} |

### DO 实体 DoD

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 类名遵循 Aim{Name}DO 格式 | {{do_naming_correct}} | {{do_naming_correct_note}} |
| 禁止标注 @JsonFormat | {{do_no_json_format}} | {{do_no_json_format_note}} |
| 包含基础通用字段 | {{do_has_base_fields}} | {{do_has_base_fields_note}} |
| 删除字段按策略选择 | {{do_delete_field_correct}} | {{do_delete_field_correct_note}} |

### Feign 接口 DoD

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 使用 @FeignClient 注解 | {{feign_has_annotation}} | {{feign_has_annotation_note}} |
| 方法签名与 InnerController 一致 | {{feign_signature_match}} | {{feign_signature_match_note}} |
| 返回类型为 CommonResult<T> | {{feign_return_common_result}} | {{feign_return_common_result_note}} |
| 写操作包含 operatorId 字段 | {{feign_has_operator_id}} | {{feign_has_operator_id_note}} |

---

## 审查文件列表

| 层 | 文件 | 状态 |
|----|------|------|
{{#each reviewed_files}}
| {{layer}} | `{{file}}` | {{status}} |
{{/each}}

---

## 退出 Checklist

- [x] quality-report.md 已生成
- [x] 已知陷阱全部检查（对照 DoD 检查卡）
- [ ] **无「严重」级别问题**（当前 {{total_severe}} 个严重问题）

### 退出结论：{{conclusion}}

{{#if has_severe_issues}}
存在 **{{total_severe}} 个严重问题**，必须修复后重新检查：

| # | 问题 | 影响 |
|---|------|------|
{{#each severe_issues}}
| {{@index}} | {{title}} | {{impact}} |
{{/each}}

**建议修复优先级**：{{fix_priority}}
{{/if}}

---

*报告生成时间：{{timestamp}}*
