# Step: 加载架构规则

## 目的
加载服务分层架构规范。

## 输入
- `architecture_rules`: 架构规则文件路径

## 输出
- `architecture_constraints`: 架构约束

## 规则内容

### 1. 服务分层

```yaml
layers:
  facade:
    services: [{facade-service}, {facade-service-2}, {facade-service-3}]
    responsibilities: [对外接口, 参数校验, 结果包装]
  application:
    services: [{app-service}, {another-app-service}]
    responsibilities: [业务编排, 事务管理, 领域服务]
  data:
    services: [{data-service}, {data-service-2}]
    responsibilities: [基础数据, 数据访问]
```

### 2. 调用关系

```yaml
call_rules:
  - facade 可调用 application
  - facade 可调用 data
  - application 可调用 data
  - data 不可调用其他层
```
