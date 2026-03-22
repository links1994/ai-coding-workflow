---
name: http-test-generator
description: 基于 tech-spec 生成完整的 HTTP 接口自动化测试用例和测试计划。支持正常场景、异常场景、边界值测试用例生成。与 java-code-generation 生成的开发自测用例区分，本 Skill 生成的是用于自动化测试流程的完整测试套件。
version: 1.0.0
workflow: http-api-testing
dependencies:
  - tech-spec-generation
---

# HTTP 测试生成 Skill

基于技术规格书生成完整的 HTTP API 自动化测试用例和测试计划。

> **职责边界说明**：
> - `java-code-generation` 生成基础 HTTP 测试骨架（开发自测用）
> - `http-test-generator` 生成完整测试套件（自动化测试流程用），包含正常/异常/边界场景

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
| http_file | `outputs/data/http/{module}-api.http` | IntelliJ HTTP Client 测试文件 |
| curl_script | `outputs/data/http/{module}-api-curl.sh` | curl 命令脚本（可直接在终端执行） |

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
7. 生成 IntelliJ HTTP Client 文件（`.http`）
8. 生成 curl 命令脚本（`.sh`）

---

## curl 脚本规范

生成 `{module}-api-curl.sh` 时遵循以下规则：

- **头部**：包含 `#!/bin/bash`、功能说明注释、使用方式说明
- **环境变量**：使用 `BASE_URL` 和 `USER_TOKEN`，默认值指向 dev 环境
- **每条用例**：前加注释行 `# TC00X: 用例名称`，再加 `echo "[TC00X] 用例名称"` 输出提示
- **POST/PUT**：使用 `-d '...'` 传递 JSON 请求体
- **GET**：URL 拼接查询参数
- **变量传递**：链式依赖时用 shell 变量保存上一步返回的 ID（通过 `grep -o` 提取）
- **输出格式化**：追加 `| python3 -m json.tool 2>/dev/null || echo "${RESPONSE}"` 美化 JSON 输出

---

## 返回格式

执行完成后返回以下格式：

```
状态：已完成

测试用例统计：
  - 总用例数：N
  - P0 用例（阻塞性）：X 个
  - P1 用例（重要）：Y 个
  - P2 用例（可选）：Z 个

测试场景覆盖：
  - 正常场景：N 个
  - 异常场景：N 个
  - 边界值测试：N 个

产出：
  - 测试用例：workspace/outputs/testing/test-cases.yml
  - 测试计划：workspace/outputs/testing/test-plan.yml
  - HTTP 测试文件：outputs/data/http/{module}-api.http
  - curl 脚本：outputs/data/http/{module}-api-curl.sh

下一步：进入 execute 阶段执行测试
```

---

## 相关文档

- 流程定义：`orchestrator/WORKFLOWS/http-api-testing/workflow.yml`
- 测试执行 Skill：`.qoder/skills/http-test-executor/SKILL.md`
