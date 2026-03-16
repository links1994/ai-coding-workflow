# Step: 定义拆分维度

## 目的
定义具体的拆分维度。

## 输入
- `split_strategy`: 拆分策略

## 输出
- `split_dimensions`: 拆分维度定义

## 维度定义

### 1. 业务域维度

```yaml
business_domains:
  - id: BD001
    name: "{DomainA}"
    services: [{app-service-a}]
  - id: BD002
    name: "{DomainB}"
    services: [{app-service-b}]
```

### 2. 功能类型维度

```yaml
function_types:
  - id: FT001
    name: "{FunctionType}"
    characteristics: [CRUD, 低频变更]
  - id: FT002
    name: "{FunctionTypeB}"
    characteristics: [状态流转, 高频访问]
```

### 3. 优先级维度

```yaml
priorities:
  - level: P0
    criteria: "核心功能，阻塞其他需求"
  - level: P1
    criteria: "重要功能，可并行开发"
```
