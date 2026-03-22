# Step: 澄清数据需求

## 目的
明确需要存储和处理的数据实体、字段、关联关系及生命周期。

## 输入
- `requirement_analysis`: 需求分析报告
- `functional_scope_answers`: 功能范围澄清结果

## 输出
- `data_requirements_answers`: 数据需求澄清结果

## 执行步骤

### 1. 核心数据实体确认

基于功能范围，识别需要存储的数据实体：
- 主实体是什么？（如：岗位、商品、订单）
- 是否有从实体？（如：岗位脚本、订单商品明细）
- 各实体的主要属性有哪些？

逐一确认主实体的核心字段：
- 名称类字段（名称、标题、编码）
- 描述类字段（描述、备注）
- 状态字段（启用/禁用、状态流转）
- 关联字段（外键，关联哪个实体的 ID）
- 数值类字段（数量、金额、排序）
- 时间类字段（生效时间、过期时间）

### 2. 数据关联关系

确认实体间的关联：
1. 与现有哪些表/服务有关联？（如：关联员工表、商品表）
2. 关联类型是什么？（一对一/一对多/多对多）
3. 关联字段存哪里？（外键存在哪个表）

### 3. 数据生命周期

确认数据的状态和流转：
1. 有没有状态字段？状态有哪些值？（如：1=启用, 0=禁用）
2. 状态之间如何流转？哪些操作会触发状态变更？
3. 数据删除方式：软删除（标记 is_deleted）还是物理删除？

### 4. 唯一性与约束

确认数据约束：
1. 哪些字段需要唯一性约束？（如：名称不允许重复、编码唯一）
2. 是否有数量限制？（如：每个商家最多创建 10 个）
3. 字段长度或格式约束？

### 5. 阶段确认

> 数据模型如下：[汇总]。是否还有其他字段或约束需要补充？

## 输出格式

```yaml
data_requirements_answers:
  entities:
    - name: "主实体名"
      table_hint: "aim_{module}_{name}"
      key_fields:
        - {name: name, type: String, required: true, unique: false}
        - {name: status, type: Integer, values: [0, 1], default: 1}
        - {name: sort_order, type: Integer}
      relations:
        - target: "关联实体名"
          type: many_to_one
          fk_field: "xxx_id"
  lifecycle:
    has_status: true
    status_transitions:
      - from: 1
        to: 0
        trigger: "禁用操作"
    delete_strategy: soft_delete
  constraints:
    unique_fields: [name]
    max_count_per_tenant: null
```
