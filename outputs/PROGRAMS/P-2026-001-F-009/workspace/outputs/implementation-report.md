# F-009 Prompt管理与生成 - 实现报告

## 1. 实现概述

| 项目 | 内容 |
|------|------|
| Feature ID | F-009 |
| Feature 名称 | Prompt管理与生成 |
| 实现日期 | 2026-03-16 |
| 状态 | 已完成 |

## 2. 功能范围

### 2.1 核心功能

1. **Prompt 动态生成**
   - 根据员工岗位类型自动选择硬编码模板
   - 变量替换（员工名称、风格名称、系统变量等）
   - 保存到员工表 `prompt` 字段

2. **Prompt 编辑**
   - 运营端支持直接编辑最终 Prompt
   - 更新后覆盖原内容

3. **变量管理**
   - 系统变量配置（PLATFORM_NAME、DEFAULT_GREETING 等）
   - 变量值更新

4. **变量提取与渲染预览**
   - 从模板提取变量占位符
   - 后端渲染预览

### 2.2 排除范围

- 沙盒调试功能（由 mall-ai 服务提供）
- 模板编辑功能（采用硬编码策略）

## 3. 技术实现

### 3.1 数据模型

| 表名 | 类型 | 说明 |
|------|------|------|
| `aim_agent_prompt_vars` | 新增 | Prompt 变量配置表 |
| `aim_agent_employee.prompt` | 预留 | 最终生成的 Prompt 内容 |

### 3.2 服务分层

```
mall-admin（门面层）
├── PromptAdminController
└── PromptVarApplicationService
        │
        ↓ Feign
mall-agent-employee-service（应用层）
├── PromptInnerController
├── PromptApplicationService
├── PromptVarQueryService
└── PromptVarManageService
```

### 3.3 关键设计决策

1. **Prompt 模板采用硬编码策略**
   - 原因：当前版本不支持模板编辑
   - 实现：在 `PromptApplicationServiceImpl` 中定义岗位类型与模板映射

2. **变量语法支持默认值**
   - 格式：`{{varName}}` 或 `{{varName:defaultValue}}`
   - 正则：`\{\{([a-zA-Z_][a-zA-Z0-9_]*)(?::([^}]*))?\}\}`

## 4. 生成的代码文件

### 4.1 mall-inner-api（Feign 接口层）

| 文件 | 说明 |
|------|------|
| `PromptRemoteService.java` | Feign 接口定义 |
| `PromptRemoteServiceFallback.java` | Feign 降级实现 |
| `GeneratePromptApiRequest.java` | 生成 Prompt 请求 |
| `UpdatePromptApiRequest.java` | 更新 Prompt 请求 |
| `UpdatePromptVarApiRequest.java` | 更新变量请求 |
| `ExtractVarsApiRequest.java` | 提取变量请求 |
| `RenderPreviewApiRequest.java` | 渲染预览请求 |
| `EmployeePromptApiResponse.java` | 员工 Prompt 响应 |
| `PromptVarApiResponse.java` | 变量响应 |
| `RenderPreviewApiResponse.java` | 渲染预览响应 |
| `VarExtractResult.java` | 变量提取结果 |

### 4.2 mall-agent-employee-service（应用服务层）

| 文件 | 说明 |
|------|------|
| `AimAgentPromptVarsDO.java` | 变量实体 |
| `AimAgentPromptVarsMapper.java` | Mapper 接口 |
| `AimAgentPromptVarsMapper.xml` | Mapper XML |
| `AimAgentPromptVarsService.java` | MP Service 接口 |
| `AimAgentPromptVarsServiceImpl.java` | MP Service 实现 |
| `PromptVarQueryService.java` | 变量查询服务 |
| `PromptVarQueryServiceImpl.java` | 变量查询服务实现 |
| `PromptVarManageService.java` | 变量管理服务 |
| `PromptVarManageServiceImpl.java` | 变量管理服务实现 |
| `PromptApplicationService.java` | Prompt 应用服务 |
| `PromptApplicationServiceImpl.java` | Prompt 应用服务实现 |
| `PromptInnerController.java` | Prompt 内部控制器 |
| `schema.sql` | 建表脚本 |
| `test-data.sql` | 测试数据 |

### 4.3 mall-admin（门面服务层）

| 文件 | 说明 |
|------|------|
| `PromptAdminController.java` | Prompt 管理控制器 |
| `PromptVarApplicationService.java` | Prompt 应用服务 |
| `UpdatePromptRequest.java` | 更新 Prompt 请求 |
| `UpdatePromptVarRequest.java` | 更新变量请求 |
| `ExtractVarsRequest.java` | 提取变量请求 |
| `RenderPreviewRequest.java` | 渲染预览请求 |
| `PromptResponse.java` | Prompt 响应 |
| `PromptVarResponse.java` | 变量响应 |
| `RenderPreviewResponse.java` | 渲染预览响应 |

### 4.4 mall-common（公共模块）

| 文件 | 说明 |
|------|------|
| `CommonResult.java` | 新增 `failed(long, String)` 方法 |

## 5. 代码质量检查

### 5.1 DoD 检查结果

| 检查项 | 状态 |
|--------|------|
| 门面 Controller DoD | ✅ 通过 |
| 内部 Controller DoD | ✅ 通过 |
| ApplicationService DoD | ✅ 通过 |
| QueryService DoD | ✅ 通过 |
| ManageService DoD | ✅ 通过 |
| DO 实体 DoD | ✅ 通过 |
| Feign 接口 DoD | ✅ 通过 |
| Mapper XML DoD | ✅ 通过 |
| 数据库脚本 DoD | ✅ 通过 |

### 5.2 修复的问题

1. `PromptAdminController.java` - 修复变量名错误（`id` → `varId`）
2. `PromptVarApplicationService.java` - 修复 package 声明、方法签名、代码语法
3. `UpdatePromptRequest.java` - 添加 `operatorId` 字段
4. `RenderPreviewRequest.java` - 添加 `Map` import
5. `RenderPreviewResponse.java` - 创建缺失的响应类
6. `CommonResult.java` - 添加 `failed(long, String)` 方法

## 6. 验收标准

| 验收项 | 状态 |
|--------|------|
| 根据员工配置自动生成 Prompt | ✅ |
| 运营端支持 Prompt 编辑 | ✅ |
| 变量管理支持增删改查 | ✅ |
| 接口返回符合 CommonResult 规范 | ✅ |
| 支持从模板提取变量占位符 | ✅ |
| 后端渲染预览 | ✅ |

## 7. 后续工作

1. **Swagger 文档生成** - 调用 `swagger-doc-generation` Skill
2. **归档到知识库** - 更新 `knowledge/apis/` 和 `knowledge/features/`

---

*报告生成时间: 2026-03-16*
