---
name: http-test-executor
description: 执行 HTTP 接口自动化测试，支持环境检查、测试执行、结果收集和报告生成。验证 Nacos 和数据库连接，按测试计划执行用例。
version: 1.0.0
workflow: http-api-testing
dependencies:
  - http-test-generator
  - env-check
---

# HTTP 测试执行 Skill

执行 HTTP 接口自动化测试，包括环境验证、测试执行和报告生成。

---

## 触发条件

- 用户指令："执行测试"、"运行 API 测试"
- 进入 http-api-testing 流程的 execute 阶段
- 前置条件：测试用例和测试计划已生成

---

## 输入

| 输入项 | 类型 | 说明 |
|--------|------|------|
| test_plan | file | 测试执行计划 |
| test_cases | file | 测试用例文件 |
| nacos_config | object | Nacos 配置 |
| database_config | object | 数据库配置 |
| target_services | array | 目标服务列表 |

---

## 输出

| 输出项 | 路径 | 说明 |
|--------|------|------|
| test_results | `workspace/outputs/testing/test-results.json` | 测试结果详情 |
| test_report | `workspace/outputs/testing/test-report.md` | 测试报告 |
| validation_result | `workspace/outputs/testing/validation-result.yml` | 验证结果 |

---

## 环境检查

**使用 `env-check` skill 执行（详见 `.qoder/skills/env-check/SKILL.md`）**

1. 从 `orchestrator/ALWAYS/RESOURCE-MAP.yml` 读取目标环境配置
2. 生成并执行 `check_services.py` 脚本
3. 检查完成后自动清理临时文件

### 检查项清单
- [ ] Nacos 可访问
- [ ] 目标服务 `/actuator/health` 返回 UP
- [ ] 全部服务就绪后执行测试

---

## 测试执行

### 执行顺序
1. P0 用例（阻塞性，必须全部通过）
2. P1 用例（重要，允许少量失败）
3. P2 用例（可选，失败不阻塞）

### 执行规则
- 支持串行/并行执行
- 失败用例自动重试（最多 3 次）
- 记录请求/响应详情
- 数据库状态回滚

---

## 结果验证

### 通过标准
- P0 用例通过率 = 100%
- P1 用例通过率 >= 90%
- 无阻塞性缺陷

### 结果分类
- **通过**：断言全部成功
- **失败**：断言失败（记录实际/预期值）
- **跳过**：依赖未满足或配置排除
- **错误**：执行异常（网络超时等）

---

## 返回格式

执行完成后返回以下格式：

```
状态：通过 / 不通过 / 部分通过

执行统计：
  - 总用例数：N
  - 通过：X
  - 失败：Y
  - 跳过：Z

通过率：
  - P0 用例：100%（必须全部通过）
  - P1 用例：95%（>= 90% 为通过）
  - P2 用例：N%（不阻塞）

产出：
  - 测试结果详情：workspace/outputs/testing/test-results.json
  - 测试报告：workspace/outputs/testing/test-report.md
  - 验证结果：workspace/outputs/testing/validation-result.yml

下一步：
  - 状态=通过：测试流程完成，可归档
  - 状态=不通过/部分通过：进入 feedback 阶段分析问题
```

---

## 相关文档

- 流程定义：`orchestrator/WORKFLOWS/http-api-testing/workflow.yml`
- 环境配置：`orchestrator/ALWAYS/RESOURCE-MAP.yml`
- 环境检查 Skill：`.qoder/skills/env-check/SKILL.md`
- 测试生成 Skill：`.qoder/skills/http-test-generator/SKILL.md`
