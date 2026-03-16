# Program: F-009 Prompt管理与生成

## 基本信息

| 属性 | 值 |
|------|-----|
| Program ID | P-2026-001-F-009 |
| 名称 | F-009 Prompt管理与生成 |
| 类型 | implementation |
| 工作流 | feature-implementation |
| Feature ID | F-009 |
| 状态 | in_progress |

## 目标

实现 F-009 Prompt管理与生成功能，包含：
- **应用层**（mall-agent-employee-service）：Prompt模板管理、动态生成、编辑保存
- **门面层**（mall-admin）：运营端Prompt编辑、预览、模板选择
- **门面层**（mall-toc-service）：用户端沙盒对话体验

## 功能需求

### 核心功能

1. **Prompt动态生成**
   - 根据员工岗位/风格/商品信息自动选择模板并完成变量替换
   - 变量包含：员工名称、风格、商品名称、价格、特点、知识库片段、对话历史

2. **Prompt编辑**
   - 运营可直接编辑最终Prompt，用户不可见
   - Prompt编辑页提供「选择模板」下拉
   - 审核详情页展示Prompt预览

3. **沙盒对话**
   - 沙盒模式下申请者可体验对话
   - 使用生成的Prompt进行模拟对话

## 服务分层

```
mall-admin（门面层）
    PromptAdminController（3接口）
    └── AgentEmployeeRemoteService（Feign）
            │
            ↓
mall-agent-employee-service（应用层）
    PromptInnerController（内部接口）
    └── PromptApplicationService
        ├── PromptQueryService（模板查询）
        └── PromptManageService（生成/编辑）
            │
            ↓
mall-toc-service（门面层）
    AiEmployeeAppController扩展（1接口）
    └── AgentEmployeeRemoteService（Feign）
```

## 依赖关系

| 依赖 | 类型 | 说明 |
|------|------|------|
| F-006 | 强依赖 | 智能员工申请与审核（员工主表） |
| F-002 | 强依赖 | 人设风格管理（风格配置表） |

## 输出产物

| 产物 | 路径 |
|------|------|
| 技术规格书 | `workspace/outputs/tech-spec.md` | 代码生成的唯一可信源（Markdown 格式，内嵌时序图）|
| 实现报告 | `workspace/outputs/implementation-report.md` |
| 质量报告 | `workspace/outputs/quality-report.md` |

## 验收标准

- [ ] 根据员工配置自动生成Prompt
- [ ] 运营端支持Prompt编辑和模板选择
- [ ] 审核详情页展示Prompt预览
- [ ] 沙盒模式支持对话体验
- [ ] 接口返回符合CommonResult规范

## 当前阶段

**feedback** - 代码质量审查阶段

### 进度
- ✅ generate_database - 生成数据库结构
- ✅ generate_feign_interfaces - 生成 Feign 接口
- ✅ generate_application_layer - 生成应用服务层
- ✅ generate_facade_layer - 生成门面服务层
- ✅ generate_tests - 生成测试文件
- ⏳ invoke_swagger_skill - 调用 Swagger 文档生成 Skill

### 已生成代码清单

**mall-inner-api (Feign 接口层)**
- `PromptRemoteService.java`
- `PromptRemoteServiceFallback.java`
- 相关 ApiRequest/ApiResponse

**mall-agent-employee-service (应用服务层)**
- `AimAgentPromptVarsDO.java`
- `AimAgentPromptVarsMapper.java` + XML
- `AimAgentPromptVarsService.java`
- `PromptVarQueryService.java`
- `PromptVarManageService.java`
- `PromptApplicationService.java`
- `PromptInnerController.java`
- 数据库脚本 `schema.sql` / `test-data.sql`

**mall-admin (门面服务层)**
- `PromptAdminController.java`
- `PromptVarApplicationService.java`
- 相关 Request/Response DTO

### 下一步
1. 代码质量审查（DoD 检查）
2. 修复发现的问题
3. 进入 review 阶段生成实现报告
