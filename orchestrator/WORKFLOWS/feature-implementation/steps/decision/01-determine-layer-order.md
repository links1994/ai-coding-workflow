# Step: 确定分层实现顺序

## 目的
根据 Feature 涉及的服务分层，确定代码生成的先后顺序，确保依赖关系正确。

## 输入
- `feature_definition`: Feature 定义
- `service_analysis`: 服务分层分析结果

## 输出
- `layer_implementation_order`: 分层实现顺序数组

## 决策逻辑

### 分层依赖关系

```
data 层（基础数据服务）
    ↓
application 层（应用服务）
    ↓
facade 层（门面服务）
```

### 决策规则

1. **Data 层优先**
   - 如果 Feature 涉及 data 层服务（mall-product, mall-client 等）
   - 先生成 data 层代码，提供基础数据能力

2. **Application 层其次**
   - 必须等待 Feign 接口定义完成
   - 生成 InnerController、ApplicationService、Query/ManageService

3. **Facade 层最后**
   - 依赖 mall-inner-api 中的 Feign 接口
   - 生成 AdminController/AppController、ApplicationService、DTO

### 特殊情况处理

| 场景 | 处理策略 |
|------|----------|
| 仅 facade 层 | 检查依赖的 application 层接口是否已存在 |
| 仅 application 层 | 先生成 Feign 接口，再生成应用服务代码 |
| 多层同时 | 按 data → application → facade 顺序串行生成 |
| 跨服务依赖 | 识别依赖的 Feature，确保前置 Feature 已完成 |

## 输出格式

```yaml
layer_implementation_order:
  - layer: data
    services:
      - mall-product
      - mall-client
    reason: 提供基础数据支持
    
  - layer: application
    services:
      - mall-agent-employee-service
    reason: 实现业务逻辑，暴露 Feign 接口
    dependencies:
      - data_layer_complete
      
  - layer: facade
    services:
      - mall-admin
    reason: 对外提供 HTTP 接口，编排业务逻辑
    dependencies:
      - feign_interfaces_ready
```

## 决策记录

需要记录的关键决策：
1. 为什么选择特定的实现顺序
2. 跨层依赖如何处理
3. 与现有代码的集成策略
