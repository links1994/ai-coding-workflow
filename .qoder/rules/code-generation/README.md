---
trigger: always_on
---
# 代码生成规范索引

> **适用范围**：Feature 实现流程中的代码生成阶段

本目录包含代码生成所需的全部规范文件，确保生成的代码符合项目标准。

---

## 规范文件清单

| 序号 | 文件 | 说明 | 适用场景 |
|------|------|------|----------|
| 01 | `01-facade-service.md` | 门面服务规范 | 生成 AdminController、ApplicationService、Request/Response/VO |
| 02 | `02-inner-service.md` | 应用服务规范 | 生成 InnerController、QueryService、ManageService |
| 03 | `03-feign-interface.md` | Feign 接口规范 | 生成 RemoteService、ApiRequest/ApiResponse、Fallback |
| 04 | `04-naming-standards.md` | 命名规范 | 所有 Java 类、方法、字段命名 |
| 05 | `05-database-standards.md` | 数据库规范 | 表设计、DO 实体、建表 SQL |
| 06 | `06-error-code-standards.md` | 错误码规范 | 错误码枚举定义 |
| 07 | `07-data-access-standards.md` | 数据访问规范 | MyBatis-Plus 使用、Mapper XML |
| 08 | `08-service-layer-standards.md` | 服务层规范 | 异常处理、参数注解、日志、操作人 ID |
| 09 | `09-directory-structure.md` | 目录结构规范 | 包路径、目录结构、文件命名 |
| 10 | `10-dod-cards.md` | DoD 检查卡 | 代码生成后质量检查 |
| 11 | `11-architecture-design.md` | 架构设计规范 | 项目整体架构、服务分层、调用关系、技术栈 |
| 12 | `12-spec-generation-constraints.md` | 规格生成约束 | tech-spec 生成阶段的 DoD 约束 |
| 13 | `13-code-templates.md` | 代码模板规范 | 代码生成时的结构模板和占位符规则 |

---

## 规范分类

### 按生成对象分类

| 生成对象 | 主要规范文件 |
|----------|--------------|
| Controller | 01-facade-service.md、02-inner-service.md、08-service-layer-standards.md |
| Service | 02-inner-service.md、07-data-access-standards.md、08-service-layer-standards.md |
| Feign | 03-feign-interface.md、11-architecture-design.md |
| DO/Entity | 05-database-standards.md、04-naming-standards.md |
| Mapper/XML | 07-data-access-standards.md、05-database-standards.md |
| DTO | 04-naming-standards.md、08-service-layer-standards.md |
| 数据库脚本 | 05-database-standards.md |

### 按规范类型分类

| 规范类型 | 文件 |
|----------|------|
| 命名规范 | 04-naming-standards.md、09-directory-structure.md |
| 架构规范 | 11-architecture-design.md、01-facade-service.md、02-inner-service.md |
| 编码规范 | 08-service-layer-standards.md、07-data-access-standards.md |
| 数据规范 | 05-database-standards.md、06-error-code-standards.md |
| 质量规范 | 10-dod-cards.md |

---

## 使用方式

### 1. 代码生成前

1. 读取所有规范文件（按序号顺序）
2. 理解项目架构约束和编码标准
3. 确认目标服务的目录结构（存量适配）

### 2. 代码生成时

1. 根据生成对象选择对应的规范文件
2. 严格遵循命名规范和目录结构
3. 确保符合架构约束（服务调用关系、分层结构）

### 3. 代码生成后

1. 使用 DoD 检查卡（10-dod-cards.md）逐项检查
2. 确保所有强制规则都已满足
3. 处理所有警告项

---

## 规范优先级

当规范之间存在冲突时，按以下优先级处理：

1. **DoD 检查卡**（10-dod-cards.md）- 最高优先级
2. **架构设计规范**（11-architecture-design.md）
3. **具体层规范**（01-03）
4. **基础规范**（04-09）

---

## 维护指南

- **新增规范**：按序号创建文件，更新本索引
- **修改规范**：直接修改对应文件，Skill 引用自动生效
- **废弃规范**：在文件顶部添加 `deprecated: true` 标记
- **避免重复**：规范内容单一，跨规范通过引用关联

---

## 相关文档

- **Skill**: `.qoder/skills/java-code-generation/SKILL.md`
- **Agent**: `.qoder/agents/code-generator.md`
- **流程**: `orchestrator/WORKFLOWS/feature-implementation/workflow.yml`
- **代码示例**: `orchestrator/WORKFLOWS/feature-implementation/_TEMPLATE/`
