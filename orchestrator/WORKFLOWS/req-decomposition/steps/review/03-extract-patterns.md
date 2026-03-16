# Step: 提炼拆分模式

## 目的
从本次拆分中提炼可复用模式。

## 输入
- `decomposition_report`: 拆分报告
- `split_strategy`: 拆分策略

## 输出
- `new_patterns`: 新提炼的模式

## 模式类型

### 1. 业务域模式

```yaml
pattern:
  type: domain
  name: "{Domain}拆分"
  description: "{Domain}功能统一归属{Domain}"
  conditions:
    - "涉及基础数据"
    - "CRUD 操作为主"
```

### 2. 服务映射模式

```yaml
pattern:
  type: service_mapping
  name: "门面+应用服务映射"
  description: "{Domain}功能映射到 facade + app-service"
  services:
    facade: [{facade-service}]
    application: [{app-service}]
```

## 模式沉淀

新模式将保存到：
`repowiki/patterns/requirement-splitting/`
