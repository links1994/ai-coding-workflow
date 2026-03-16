# Step: 准备测试数据

## 目的
准备测试所需数据。

## 输入
- `test_plan`: 测试计划
- `database_schema`: 数据库表结构
- `test_data_sql`: 测试数据 SQL

## 输出
- `prepared_test_data`: 准备好的测试数据

## 执行步骤

### 1. 初始化数据库

```sql
-- 执行建表 SQL
SOURCE {database_schema}

-- 执行测试数据 SQL
SOURCE {test_data_sql}
```

### 2. 准备 Nacos 配置

- 检查配置项是否存在
- 更新测试环境配置
- 确认配置生效

### 3. 清理历史数据

- 清理上一轮测试数据
- 重置自增 ID
- 清理日志文件

## 数据隔离

- 使用测试专用数据库
- 测试数据标记 test_ 前缀
- 测试完成后清理数据
