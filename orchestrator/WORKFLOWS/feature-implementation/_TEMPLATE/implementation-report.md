# Feature 实现报告: {{program.name}}

> Feature ID: {{inputs.feature_id}}
> 生成时间: {{timestamp}}
> 基于流程: {{workflow.name}} v{{workflow.version}}

## 1. Feature 定义摘要

```yaml
{{feature_definition}}
```

## 2. 服务分层分析

| 服务名称 | 分层 | 职责 | 生成内容 |
|----------|------|------|----------|
{{#each target_services}}
| {{name}} | {{layer}} | {{description}} | {{generated_content}} |
{{/each}}

## 3. 生成文件清单

### 3.1 Feign 接口（mall-inner-api）

| 文件路径 | 类型 | 说明 |
|----------|------|------|
{{#each feign_interfaces}}
| {{file_path}} | {{file_type}} | {{description}} |
{{/each}}

### 3.2 应用服务层

| 文件路径 | 类型 | 服务 | 说明 |
|----------|------|------|------|
{{#each application_layer_code}}
| {{file_path}} | {{file_type}} | {{service}} | {{description}} |
{{/each}}

### 3.3 门面服务层

| 文件路径 | 类型 | 服务 | 说明 |
|----------|------|------|------|
{{#each facade_layer_code}}
| {{file_path}} | {{file_type}} | {{service}} | {{description}} |
{{/each}}

### 3.4 数据库结构

{{#if database_schema}}
```sql
{{database_schema}}
```
{{else}}
> 本 Feature 无需新建数据库表
{{/if}}

## 4. 接口定义文档

{{interface_documentation}}

## 5. HTTP 测试文件

| 文件路径 | 测试 Controller | 接口数量 |
|----------|-----------------|----------|
{{#each test_files}}
| {{file_path}} | {{controller}} | {{endpoint_count}} |
{{/each}}

## 6. 代码审查结果

### 6.1 质量检查

{{code_quality_report}}

### 6.2 接口一致性检查

{{interface_consistency_report}}

## 7. 验收标准验证

| 验收标准 | 状态 | 验证方式 |
|----------|------|----------|
{{#each acceptance_criteria}}
| {{criteria}} | {{status}} | {{validation_method}} |
{{/each}}

## 8. 关键决策记录

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 分层实现顺序 | {{layer_implementation_order}} | {{reason}} |
| 接口定义顺序 | {{interface_definition_order}} | {{reason}} |
| 代码生成策略 | {{code_generation_strategy}} | {{reason}} |
