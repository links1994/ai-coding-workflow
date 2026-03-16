# Step: 修复问题

## 目的
修复发现的问题。

## 输入
- `failure_analysis`: 失败分析

## 输出
- `fix_result`: 修复结果

## 修复策略

### 1. 代码缺陷

- 返回 feature-implementation 流程修复
- 更新代码后重新测试

### 2. 环境问题

- 调整环境配置
- 重启服务
- 清理缓存

### 3. 用例问题

- 更新测试用例
- 调整断言条件
- 修正测试数据

## 输出格式

```yaml
fix_result:
  fixed:
    - case_id: TC005
      fix_type: code
      description: "添加空值检查"
  pending:
    - case_id: TC008
      reason: "需要架构调整"
      owner: "开发团队"
```
