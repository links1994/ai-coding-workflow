# Step: 澄清业务规则

## 目的
明确业务约束、校验规则、权限控制和特殊处理逻辑。

## 输入
- `functional_scope_answers`: 功能范围澄清结果
- `data_requirements_answers`: 数据需求澄清结果

## 输出
- `business_rules_answers`: 业务规则澄清结果

## 执行步骤

### 1. 校验规则确认

针对每个写操作逐一确认：

**创建时：**
- 哪些字段是必填的？
- 哪些字段有格式限制？（长度、正则、枚举值）
- 创建前需要做哪些业务校验？（如：名称不能与现有记录重复）

**更新时：**
- 哪些字段允许修改？
- 哪些状态下不允许编辑？（如：已审核的记录不能修改）
- 更新是否触发其他联动逻辑？

**删除时：**
- 删除前是否需要检查依赖关系？（如：被引用的记录不能删除）
- 哪些状态下不允许删除？

### 2. 权限控制

确认权限规则：
1. 所有管理员都能操作，还是有角色区分？
2. 是否有数据权限？（如：商家只能看到自己的数据）
3. 是否有操作权限？（如：只有超级管理员才能删除）

### 3. 特殊业务规则（按需追问）

根据业务特征追问：
- 是否有配额/上限限制？
- 是否需要审核流程？（提交 → 审核 → 生效）
- 是否有通知需求？（操作后是否发消息/邮件）
- 是否有联动逻辑？（A 改变时 B 自动变化）

### 4. 阶段确认

> 业务规则如下：[汇总]。是否还有其他约束或特殊处理？

## 输出格式

```yaml
business_rules_answers:
  validation_rules:
    create:
      required_fields: [name, status]
      format_rules:
        - field: name
          max_length: 100
      business_checks:
        - "名称在同一商家下不能重复"
    update:
      restricted_in_status: []
      locked_fields_when_status: {}
    delete:
      dependency_checks:
        - "被引用时不允许删除"
      restricted_in_status: []
  permission_rules:
    data_scope: "商家只能操作自己的数据"
    operation_roles: {}
  special_rules:
    quota_limit: null
    approval_flow: false
    notifications: []
    cascade_effects: []
```
