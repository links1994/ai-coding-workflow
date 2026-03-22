# Step: 加载架构上下文

## 目的
加载服务分层规范和架构约束，为后续确定需求落地到哪些服务提供基础。

## 输入
- `architecture_rules`: 服务分层架构规则

## 输出
- `architecture_constraints`: 架构约束对象

## 执行步骤

### 1. 加载服务分层规范

读取以下规则文件：
- `.qoder/rules/req-decomposition/02-service-layering.md`：服务分层定义（facade/application/data）
- `.qoder/rules/req-decomposition/01-feature-definition.md`：Feature 定义规范

### 2. 提取关键约束

从规则文件中提取：
- 各服务层的职责边界
- 服务间调用关系（禁止哪些调用方向）
- 现有服务清单（mall-admin、mall-toc-service、mall-agent-employee-service 等）
- DTO 归属原则（ApiRequest/ApiResponse 放在 inner-api）

### 3. 输出约束摘要

```yaml
architecture_constraints:
  service_layers:
    - name: facade
      examples: [mall-admin, mall-toc-service]
      responsibility: 对外暴露接口，调用 application 层
    - name: application
      examples: [mall-agent-employee-service, mall-product]
      responsibility: 业务逻辑，调用 data 层
    - name: inner_api
      examples: [mall-inner-api/mall-agent-api]
      responsibility: Feign 接口定义和 DTO
  call_rules:
    - "facade 只能调用 application 层（通过 Feign）"
    - "application 层不能反向调用 facade 层"
    - "ApiRequest/ApiResponse 必须定义在 inner-api 模块"
```
