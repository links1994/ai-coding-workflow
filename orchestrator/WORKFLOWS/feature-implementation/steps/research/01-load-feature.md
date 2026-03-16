# Step: 加载 Feature 定义

## 目的
从 decomposition.md 中提取指定 Feature ID 的完整定义，作为代码生成的输入可信源。

## 输入
- `feature_id`: Feature 标识符（如 F-001）
- `decomposition_report`: decomposition.md 文件路径

## 输出
- `feature_definition`: Feature 定义对象

## 执行步骤

1. **读取 decomposition.md**
   - 解析 Markdown 中的 YAML 代码块
   - 定位 `features` 列表

2. **提取 Feature 定义**
   - 根据 `feature_id` 匹配 `id` 字段
   - 提取完整的 Feature 定义：
     - id, name, domain, module
     - type, priority, dependencies
     - description, acceptance_criteria
     - services, tables

3. **验证 Feature 定义完整性**
   - 检查必填字段是否存在
   - 验证 services 列表非空
   - 确认 module 与 services 对应关系

## 输出格式

```yaml
feature_definition:
  id: F-001
  name: 岗位类型管理
  domain: 配置管理域
  module: mall-agent-employee-service
  type: functional
  priority: P0
  dependencies: []
  description: 运营人员管理智能员工岗位类型...
  acceptance_criteria:
    - 支持岗位CRUD操作
    - 返回该岗位下关联员工数
  services:
    - name: mall-admin
      layer: facade
      interfaces: 4
    - name: mall-agent-employee-service
      layer: application
  tables:
    - aim_agent_job_type
```

## 错误处理

- 如果 Feature ID 不存在，报错并列出所有可用 Feature ID
- 如果 Feature 定义不完整，列出缺失字段
- 如果 services 列表为空，提示需要至少一个服务
