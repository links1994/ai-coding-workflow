# Step: 构建需求树

## 目的
构建层次化的需求树结构。

## 输入
- `domain_mapping`: 域映射关系
- `split_dimensions`: 拆分维度

## 输出
- `requirements_tree`: 需求树（可信源）

## 树的结构

```yaml
requirements_tree:
  version: "1.0"
  root:
    id: ROOT
    name: "产品需求"
    children:
      - id: D001
        name: "{Domain}"
        type: domain
        children:
          - id: F001
            name: "{Name}管理"
            type: feature
            priority: P0
            services:
              - {facade-service}
              - {app-service}
            tables:
              - {table_name}
            acceptance_criteria:
              - "支持CRUD操作"
              - "返回关联数据"
```

## 拆分规则

1. **最大深度**：5 层
2. **最大节点数**：100 个
3. **叶子节点**：必须是可独立交付的 Feature
