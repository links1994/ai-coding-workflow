# Step: 确定测试策略

## 目的
基于接口类型确定测试策略。

## 输入
- `test_scope`: 测试范围
- `environment_status`: 环境状态

## 输出
- `test_strategy`: 测试策略

## 策略维度

### 1. 测试场景类型

**正常场景**：
- 必填参数测试
- 完整参数测试
- 默认参数测试

**异常场景**：
- 参数缺失测试
- 参数非法值测试
- 边界值测试
- 权限测试

### 2. 测试优先级

- **P0**: 核心功能，必须 100% 通过
- **P1**: 重要功能，通过率 >= 90%
- **P2**: 一般功能，记录问题

### 3. 依赖测试

识别接口依赖链：
- 创建 → 查询 → 更新 → 删除
- 批量操作依赖单条操作

## 输出格式

```yaml
test_strategy:
  scenarios:
    - type: normal
      coverage: 100%
    - type: exception
      coverage: 80%
  priorities:
    P0: [创建, 更新, 查询, 删除]
    P1: [分页, 列表]
    P2: [导出, 统计]
  dependencies:
    - chain: [create, getById, update, delete]
```
