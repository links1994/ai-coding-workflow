# Step: 业务域划分

## 目的
将需求映射到业务域和服务模块。

## 输入
- `requirement_list`: 需求列表
- `architecture_constraints`: 架构约束

## 输出
- `domain_mapping`: 域映射关系

## 映射规则

### 1. 业务域映射

根据需求内容识别业务域：
- {DomainA}相关 → {DomainA}
- {DomainB}相关 → {DomainB}
- {DomainC}相关 → {DomainC}

### 2. 服务模块映射

根据业务域映射到服务：
- {DomainA} → {app-service-a}
- {Domain} → {app-service}

## 输出格式

```yaml
domain_mapping:
  domains:
    - id: D001
      name: "{Domain}"
      requirements: [R001, R002]
      services:
        - {facade-service}
        - {app-service}
```
