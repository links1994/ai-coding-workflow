---
name: code-review
description: 审查生成代码的质量，检查是否符合项目规范和 DoD 要求。在代码生成后、进入 review 阶段前调用，识别代码缺陷、规范违规和与 tech-spec 的不一致。
version: 1.0.0
workflow: feature-implementation
dependencies:
  - java-code-generation
---

# 代码审查 Skill

审查生成代码的质量，确保符合项目规范和 DoD（Definition of Done）要求。

---

## 触发条件

- 用户指令："审查代码"、"检查代码质量"、"代码评审"
- 进入 feature-implementation 流程的 feedback 阶段
- 前置条件：代码生成已完成

---

## 前置依赖（必须读取）

| 文件 | 路径 | 说明 |
|------|------|------|
| 技术规格书 | `workspace/outputs/tech-spec.md` | 代码生成的唯一可信源 |
| DoD 检查卡 | `.qoder/rules/code-generation/10-dod-cards.md` | 代码生成后质量检查清单 |
| 门面服务规范 | `.qoder/rules/code-generation/01-facade-service.md` | Controller、ApplicationService 规范 |
| 应用服务规范 | `.qoder/rules/code-generation/02-inner-service.md` | InnerController、Service 规范 |
| 命名规范 | `.qoder/rules/code-generation/04-naming-standards.md` | 命名规范检查 |
| 服务层规范 | `.qoder/rules/code-generation/08-service-layer-standards.md` | 异常处理、日志规范 |

---

## 输入

| 输入项 | 类型 | 说明 |
|--------|------|------|
| tech_spec | file | 技术规格书路径 |
| generated_code | directory | 生成的代码目录 |
| code_generation_standards | object | 代码生成规范集合 |

---

## 输出

| 输出项 | 路径 | 说明 |
|--------|------|------|
| code_quality_report | `workspace/outputs/review/code-quality-report.md` | 代码质量审查报告 |
| dod_checklist | `workspace/outputs/review/dod-checklist.yml` | DoD 检查清单结果 |

---

## 审查维度

### 1. 命名规范检查

| 检查项 | 通过标准 | 问题等级 |
|--------|----------|----------|
| Controller 命名 | 符合 `{Name}AdminController` / `{Name}InnerController` | 阻塞 |
| Service 命名 | 符合 `{Name}QueryService` / `{Name}ManageService` / `{Name}ApplicationService` | 阻塞 |
| DO 命名 | 符合 `Aim{Name}DO` | 阻塞 |
| Mapper 命名 | 符合 `Aim{Name}Mapper` | 阻塞 |
| DTO 命名 | 符合 `{Name}Request` / `{Name}Response` / `{Name}ApiRequest` / `{Name}ApiResponse` | 阻塞 |
| 方法命名 | 符合驼峰命名规范，语义清晰 | 警告 |
| 字段命名 | 符合驼峰命名规范 | 警告 |

### 2. 分层架构检查

| 检查项 | 通过标准 | 问题等级 |
|--------|----------|----------|
| Controller 依赖 | 只注入 ApplicationService，禁止直接注入 Mapper/RemoteService | 阻塞 |
| ApplicationService 依赖 | 门面层只调用 RemoteService，应用层只调用 Query/ManageService | 阻塞 |
| QueryService 约束 | 只读查询，使用原生 SQL，禁止 Feign 调用 | 阻塞 |
| ManageService 约束 | 增删改操作，使用 MP，标注 @Transactional | 阻塞 |
| Service 注入规范 | 禁止同时注入 Aim{Name}Service 和 Aim{Name}Mapper | 阻塞 |

### 3. 接口规范检查

**门面 Controller 检查：**

| 检查项 | 通过标准 | 问题等级 |
|--------|----------|----------|
| 路径前缀 | `/admin/api/v1/` / `/app/api/v1/` / `/merchant/api/v1/` | 阻塞 |
| @Tag 注解 | 包含 `@Tag(name = "一级/二级")` | 警告 |
| 参数校验 | POST/PUT/DELETE 使用 `@Valid` | 阻塞 |
| operatorId 处理 | 从 Header 解析并设置到 Request | 阻塞 |
| 异常处理 | 无 try-catch，由 GlobalExceptionHandler 处理 | 阻塞 |

**内部 Controller 检查：**

| 检查项 | 通过标准 | 问题等级 |
|--------|----------|----------|
| 路径前缀 | `/inner/api/v1/` | 阻塞 |
| 参数校验 | 手动编写 validateXxx() 方法，禁止 @Valid | 阻塞 |
| 参数传递 | 使用 @RequestParam，禁止 @PathVariable | 阻塞 |
| HTTP 方法 | 仅使用 GET/POST，禁止 PUT/DELETE | 阻塞 |
| operatorId | 从 ApiRequest 接收，不解析 Header | 阻塞 |

### 4. DoD 检查卡逐项验证

**门面 Controller DoD：**
- [ ] 命名符合规范
- [ ] 使用 @Valid 进行参数校验
- [ ] 从 Header 解析 operatorId
- [ ] 只调用 ApplicationService
- [ ] 返回门面层自定义的 Response DTO

**内部 Controller DoD：**
- [ ] 命名符合规范
- [ ] 手动编写 validateXxx() 方法
- [ ] 使用 @RequestParam
- [ ] 只调用 QueryService / ManageService
- [ ] 返回 CommonResult 包装

**ApplicationService DoD：**
- [ ] 命名符合规范
- [ ] String 参数统一去空格
- [ ] DTO 转换完整

**QueryService DoD：**
- [ ] 只读查询操作
- [ ] 复杂查询使用原生 SQL（XML）
- [ ] 返回 DO 或基础类型

**ManageService DoD：**
- [ ] 增删改操作
- [ ] 使用 MyBatis-Plus 方法
- [ ] 标注 @Transactional

**DO 实体 DoD：**
- [ ] 命名符合 AimXxxDO
- [ ] 继承 BaseDO
- [ ] 字段与数据库表对应

**Mapper DoD：**
- [ ] 命名符合 XxxMapper
- [ ] 继承 BaseMapper
- [ ] XML 包含 Base_Column_List

**Feign 接口 DoD：**
- [ ] 命名符合 XxxRemoteService
- [ ] @FeignClient 配置正确
- [ ] 使用 @RequestParam

### 5. 与 Tech Spec 一致性检查

| 检查项 | 通过标准 | 问题等级 |
|--------|----------|----------|
| 接口路径 | 与 tech-spec 定义的接口路径一致 | 阻塞 |
| 方法签名 | 参数类型、顺序与 tech-spec 一致 | 阻塞 |
| 字段映射 | DTO 字段与 tech-spec 定义一致 | 阻塞 |
| 调用链 | 代码实现与 tech-spec 时序图一致 | 警告 |

---

## 工作流程

### 步骤 1：读取输入

1. 读取 tech-spec.md
2. 读取生成的代码文件
3. 读取代码生成规范

### 步骤 2：执行命名规范检查

- 检查所有类名是否符合命名规范
- 检查方法名和字段名

### 步骤 3：执行分层架构检查

- 检查依赖注入是否正确
- 检查调用链是否符合规范

### 步骤 4：执行接口规范检查

- 检查 Controller 注解和参数
- 检查路径和方法

### 步骤 5：执行 DoD 检查卡

- 逐项验证 DoD 检查卡
- 标记通过/失败项

### 步骤 6：执行一致性检查

- 对比代码与 tech-spec
- 识别不一致项

### 步骤 7：生成审查报告

按以下结构生成报告：

```markdown
# 代码质量审查报告

## 基本信息

- Feature ID: {F-XXX}
- 审查时间: {YYYY-MM-DD}
- 审查结果: 通过 / 有条件通过 / 不通过

## 问题汇总

| 级别 | 数量 | 说明 |
|------|------|------|
| 阻塞 | N | 必须修复 |
| 警告 | N | 建议修复 |
| 提示 | N | 可选优化 |

## 阻塞问题（必须修复）

### 问题 1: [问题描述]

**位置**: {文件路径}
**违反规则**: {规则名称}
**问题描述**: {详细描述}
**修复建议**: {建议}

## 警告问题（建议修复）

...

## DoD 检查卡结果

### 门面 Controller DoD

- [x] 命名符合规范
- [ ] 使用 @Valid 进行参数校验 → {问题说明}
...

## 与 Tech Spec 一致性

- [x] 接口路径一致
- [x] 方法签名一致
- [ ] 字段映射一致 → {问题说明}

## 结论

**审查结果**: 有条件通过

存在 N 个阻塞问题，修复后可进入 review 阶段。
```

---

## 返回格式

执行完成后返回以下格式：

```
状态：通过 / 有条件通过 / 不通过

问题统计：
  - 阻塞问题：N 个（必须修复）
  - 警告问题：N 个（建议修复）
  - 提示建议：N 个（可选优化）

DoD 检查：
  - 门面 Controller：X/Y 项通过
  - 内部 Controller：X/Y 项通过
  - ApplicationService：X/Y 项通过
  - QueryService：X/Y 项通过
  - ManageService：X/Y 项通过
  - DO 实体：X/Y 项通过
  - Mapper：X/Y 项通过
  - Feign 接口：X/Y 项通过

产出：
  - 审查报告：workspace/outputs/review/code-quality-report.md
  - DoD 清单：workspace/outputs/review/dod-checklist.yml

下一步：
  - 状态=通过：进入 review 阶段
  - 状态=有条件通过/不通过：进入 fix 阶段修复问题
```

---

## 相关文档

- 流程定义：`orchestrator/WORKFLOWS/feature-implementation/workflow.yml`
- DoD 检查卡：`.qoder/rules/code-generation/10-dod-cards.md`
- 代码生成规范：`.qoder/rules/code-generation/`
