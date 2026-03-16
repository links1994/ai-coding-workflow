---
name: http-test-generator
description: 基于 tech-spec 生成 HTTP 接口自动化测试用例和测试计划。支持正常场景、异常场景、边界值测试用例生成。
---

# HTTP 测试生成 Skill

基于技术规格书生成标准化的 HTTP API 测试用例。

---

## 触发条件

- 用户指令："生成测试用例"、"创建 API 测试"
- 进入 http-api-testing 流程的 decision 阶段
- 前置条件：tech-spec.md 已确认

---

## 输入

| 输入项 | 类型 | 说明 |
|--------|------|------|
| tech_spec | file | 技术规格书路径（tech-spec.md，Markdown 格式） |
| test_strategy | object | 测试策略（正常/异常/边界） |
| environment_config | object | 环境配置（Nacos/数据库） |

---

## 输出

| 输出项 | 路径 | 说明 |
|--------|------|------|
| test_cases | `workspace/outputs/testing/test-cases.yml` | 测试用例文件 |
| test_plan | `workspace/outputs/testing/test-plan.yml` | 测试执行计划 |

---

## 测试用例生成规则

### 正常场景（P0）

每个接口至少生成：
- 完整参数请求
- 最小参数请求
- 成功响应断言

### 异常场景（P1）

- 缺少必填参数
- 参数类型错误
- 参数值越界
- 重复创建（唯一性冲突）
- 不存在的数据查询

### 边界值测试（P2）

- 字符串最大/最小长度
- 数值最大/最小值
- 空数组/空字符串处理

---

## 工作流程

1. 解析 tech-spec 接口定义
2. 按接口生成测试场景
3. 生成请求参数（含动态数据）
4. 定义响应断言规则
5. 标注测试优先级
6. 生成测试执行计划

---

## 返回格式

```
状态：已完成
测试用例数：N
P0 用例：X 个
P1 用例：Y 个
P2 用例：Z 个

输出：
- workspace/outputs/testing/test-cases.yml
- workspace/outputs/testing/test-plan.yml
```
