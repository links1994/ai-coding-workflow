# Step: 澄清功能范围

## 目的
明确需要实现哪些具体操作和页面，确定功能边界。

## 输入
- `requirement_analysis`: 需求分析报告
- `business_goal_answers`: 业务目标澄清结果

## 输出
- `functional_scope_answers`: 功能范围澄清结果

## 执行步骤

### 1. 操作清单确认

基于已知的用户角色，逐角色确认需要哪些操作：

**管理端（如有）：**
- [ ] 列表查询（分页）
- [ ] 新增
- [ ] 编辑/修改
- [ ] 删除（软删除还是物理删除？）
- [ ] 查看详情
- [ ] 状态操作（启用/禁用/审核/发布等）
- [ ] 批量操作（批量启用/禁用/删除）

**用户端（如有）：**
- [ ] 查看列表
- [ ] 查看详情
- [ ] 提交/购买/收藏等业务动作

### 2. 查询与过滤

针对列表查询，确认：
1. 需要哪些筛选条件？（状态、时间范围、关键词、分类等）
2. 默认排序规则是什么？（创建时间倒序、名称排序、自定义排序？）
3. 是否支持关键词搜索？搜索哪些字段？

### 3. 边界功能（按需追问）

根据业务特征，按需确认：
- 是否需要导入/导出功能？
- 是否需要数据统计/汇总？
- 是否有特殊的业务动作（不是普通的 CRUD）？

### 4. 阶段确认

汇总功能清单，询问用户：
> 功能范围如下：[列表展示]。是否有遗漏的操作或页面？

## 输出格式

```yaml
functional_scope_answers:
  admin_operations:
    - list_page: true
    - create: true
    - update: true
    - delete: {type: soft}
    - detail: true
    - status_toggle: true
    - batch_ops: false
  user_operations:
    - view_list: false
    - view_detail: false
  query_filters:
    - field: status
      type: enum
    - field: keyword
      type: search
      target_fields: [name]
  sort_rule: "创建时间倒序"
  extra_features: []
```
