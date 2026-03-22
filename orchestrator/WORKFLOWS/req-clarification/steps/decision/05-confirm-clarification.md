# Step: 确认澄清完成

## 目的
汇总所有澄清结果，让用户做最终确认，确保无遗漏后进入 plan 阶段生成需求文档。

## 输入
- `business_goal_answers`: 业务目标澄清结果
- `functional_scope_answers`: 功能范围澄清结果
- `data_requirements_answers`: 数据需求澄清结果
- `business_rules_answers`: 业务规则澄清结果

## 输出
- `clarification_confirmed`: 澄清完成确认标记

## 执行步骤

### 1. 汇总展示

将所有澄清结果整理成结构化摘要，展示给用户：

---

**业务目标**
- 解决的问题：XXX
- 用户角色：XXX（管理员/商家/买家）
- 典型流程：XXX

**功能范围**
- 管理端：列表查询、新增、编辑、删除、XXX
- 用户端：无 / XXX
- 查询筛选：状态、关键词搜索、XXX

**数据模型**
- 主实体：XXX，核心字段：XXX
- 关联：关联 XXX 表（XXX_id）
- 删除方式：软删除

**业务规则**
- 必填字段：XXX
- 约束：名称不重复
- 权限：XXX

---

### 2. 确认清单

逐项确认：
- [ ] 业务目标清晰，无歧义
- [ ] 功能范围已确定，无遗漏
- [ ] 核心数据字段已明确
- [ ] 关键业务规则已说明
- [ ] 没有阻塞性的未解决问题

### 3. 询问用户

> 以上是需求澄清的完整汇总，信息是否准确完整？确认后将生成需求文档。

**如果用户提出修改：**
- 记录修改点，直接更新对应的 answers 对象
- 重新展示修改后的汇总，再次确认

**如果用户确认无误：**
- 进入 plan 阶段生成需求文档

## 输出格式

```yaml
clarification_confirmed: true
summary:
  business_goal: "解决 XXX 问题，管理员通过后台管理 XXX"
  functional_scope: "管理端 CRUD + 启用禁用，支持按状态/关键词筛选"
  data_model: "aim_{module}_{name} 表，主要字段：name/status/sort_order，关联 XXX"
  business_rules: "名称不重复，被引用时不允许删除"
```
