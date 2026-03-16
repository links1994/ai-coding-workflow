# Step: 调用 Swagger 文档生成 Skill

## 步骤信息

| 属性 | 值 |
|------|-----|
| 阶段 | execute |
| 序号 | 04 |
| 名称 | invoke-swagger-skill |
| 触发条件 | HTTP 测试文件生成完成后 |

## 描述

本步骤为占位说明，实际 Swagger 文档生成由独立的 `swagger-doc-generation` Skill 在 review 阶段后执行。

在 execute 阶段，本步骤仅做标记，不实际执行文档生成。

## 实际执行时机

Swagger 文档生成在以下时机执行：

1. **review 阶段后**：作为独立 Skill 调用
2. **用户指令**：用户主动要求 "生成 Swagger 文档" / "更新 API 文档"
3. **Phase 8 退出卡标注**：当 Phase 8 功能归档的退出卡中标注"需进入 Phase 9"时

## 独立 Skill 信息

| 属性 | 值 |
|------|-----|
| Skill 名称 | swagger-doc-generation |
| Skill 路径 | `.qoder/skills/swagger-doc-generation/SKILL.md` |
| 触发条件 | Phase 8 功能归档已完成，且涉及门面服务 Controller 变更 |
| 跳过条件 | 应用服务或基础数据服务（标记为 skipped） |

## 输入（传递给 Skill）

| 名称 | 类型 | 来源 | 说明 |
|------|------|------|------|
| tech_spec | file | plan 阶段 | 技术规格书 |
| facade_layer_code | directory | 03-generate-facade-layer | 门面服务层代码 |
| application_layer_code | directory | 02-generate-application-layer | 应用服务层代码 |
| program_id | string | Program 元数据 | 用于 Frontmatter updated_by 字段 |

## 输出（由 Skill 生成）

| 名称 | 类型 | 路径 | 说明 |
|------|------|------|------|
| swagger_docs | directory | outputs/swagger/{service-name}/{ControllerName}/ | Swagger API 文档 |

### 输出文件结构

```
outputs/swagger/
├── {facade-service}/
│   └── {Name}Admin/
│       └── 岗位类型管理-{Name}AdminApi.md
├── {facade-service-2}/
│   └── EmployeeApp/
│       └── 智能员工信息-EmployeeAppApi.md
└── {app-service}/
    └── ActivationInner/
        └── 激活解锁-ActivationInnerApi.md
```

### 文档格式

- **Frontmatter**：service, controller, module, title, version, updated_at, updated_by
- **命名规则**：`{中文功能描述}-{ControllerName}Api.md`
- **中文描述提取**：优先 @Tag 最后一段 → tech-spec 功能名 → Controller 名兜底
- **更新模式**：增量更新（保留未变更接口内容）

## 参考模板

模板文件位置：`outputs/swagger/_TEMPLATE/岗位类型管理-{Name}AdminApi.md`

## 相关文档

- **Swagger Skill**：`.qoder/skills/swagger-doc-generation/SKILL.md`
- **开发流程**：`orchestrator/ALWAYS/DEV-FLOW.md` §2.5、§2.6
- **核心工作协议**：`orchestrator/ALWAYS/CORE.md` §2.2 Phase 9
