# Step: 分析测试范围

## 目的
从 tech-spec 和实现报告中提取需要测试的接口列表。

## 输入
- `tech_spec`: 技术规格书
- `implementation_report`: 实现报告

## 输出
- `test_scope`: 测试范围定义

## 执行步骤

### 1. 解析接口定义

从 tech-spec 中提取：
- 门面服务接口（Admin/App/Merchant）
- 内部服务接口（Inner）
- 接口路径、方法、参数

### 2. 识别测试重点

根据接口类型确定测试重点：
- **写操作**：创建、更新、删除
- **读操作**：查询详情、分页查询
- **特殊逻辑**：状态变更、批量操作

### 3. 输出测试范围

```yaml
test_scope:
  interfaces:
    - id: IF001
      name: 创建{Name}
      path: /admin/api/v1/{path}/create
      method: POST
      type: write
      priority: P0
    - id: IF002
      name: 分页查询{Name}
      path: /admin/api/v1/{path}/page
      method: POST
      type: read
      priority: P0
```
