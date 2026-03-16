# Skill 索引

本目录包含项目所有的 Skill 模块，提供可复用的标准化流程和专业知识。

---

## 按流程分类

### req-decomposition 流程（需求拆分）

| Skill | 描述 | 触发词 |
|-------|------|--------|
| [prd-decomposition](./prd-decomposition/SKILL.md) | 将 PRD 分解为可实现的子需求 | "分解 PRD"、"拆分需求" |

### feature-implementation 流程（功能实现）

| Skill | 描述 | 触发词 | 依赖 Skill |
|-------|------|--------|-----------|
| [tech-spec-generation](./tech-spec-generation/SKILL.md) | 生成技术规格书 | "生成技术规格书"、"设计 SPEC" | - |
| [tech-spec-analyzer](./tech-spec-analyzer/SKILL.md) | 分析规格完整性和可实现性 | "分析 tech-spec"、"检查规格书" | tech-spec-generation |
| [java-code-generation](./java-code-generation/SKILL.md) | 生成 Java 微服务代码 | "生成代码"、"开始代码生成" | tech-spec-generation |
| [code-review](./code-review/SKILL.md) | 代码质量审查 | "审查代码"、"检查代码质量" | java-code-generation |
| [swagger-doc-generation](./swagger-doc-generation/SKILL.md) | 生成 Swagger API 文档 | "生成 Swagger 文档"、"更新 API 文档" | java-code-generation |
| [database-migration](./database-migration/SKILL.md) | 生成数据库迁移脚本 | "生成迁移脚本"、"数据库变更" | - |

### http-api-testing 流程（接口测试）

| Skill | 描述 | 触发词 | 依赖 Skill |
|-------|------|--------|-----------|
| [http-test-generator](./http-test-generator/SKILL.md) | 生成 HTTP 测试用例 | "生成测试用例"、"创建 API 测试" | tech-spec-generation |
| [http-test-executor](./http-test-executor/SKILL.md) | 执行 HTTP 接口测试 | "执行测试"、"运行 API 测试" | http-test-generator |

### 通用工具 Skill

| Skill | 描述 | 触发词 |
|-------|------|--------|
| [troubleshooting](./troubleshooting/SKILL.md) | 故障排查和问题解决 | "排查问题"、"诊断错误" |

---

## Skill 依赖关系图

```
prd-decomposition
       ↓
tech-spec-generation
       ↓
┌──────┴──────┬──────────────┐
↓             ↓              ↓
tech-spec-analyzer  java-code-generation  http-test-generator
       ↓             ↓              ↓
       └──────┬──────┘              ↓
              ↓                     ↓
         code-review          http-test-executor
              ↓
       swagger-doc-generation
```

---

## Skill 设计原则

1. **单一职责**：每个 Skill 专注于一个明确的任务
2. **输入输出明确**：清晰的输入定义和输出产物
3. **可复用性**：可在不同流程和 Agent 中复用
4. **规范驱动**：依赖 Rules 文件定义规范
5. **可追溯性**：生成产物包含来源和版本信息

---

## 新增 Skill 指南

参考 [Skill 创建指南](../../repowiki/guides/skill-creation-guide.md) 创建新的 Skill。

基本步骤：
1. 识别可复用流程
2. 定义 Skill 边界（输入/输出/触发词）
3. 创建 SKILL.md 文件
4. 更新本索引文档

---

## 相关文档

- [Skill 创建指南](../../repowiki/guides/skill-creation-guide.md)
- [Agent 创建指南](../../repowiki/guides/agent-creation-guide.md)
- [Rule 创建指南](../../repowiki/guides/rule-creation-guide.md)
- [工作流架构设计](../../repowiki/architecture/workflow-command-agent-skill.md)
