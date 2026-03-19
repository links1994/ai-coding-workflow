# 技术规格生成约束规范

> **适用范围**：tech-spec-generation Skill 生成规格时自动应用的约束
> **目的**：将 DoD（Definition of Done）检查前置到规格生成阶段，确保生成的技术规格本身符合代码生成规范，减少代码生成后的返工

---

## 规范引用索引

本文件是 **tech-spec-generation Skill 的自动化约束应用描述**，各规范详情请查阅权威规范文件：

| 约束领域 | 权威规范文件 |
|----------|--------------|
| 门面接口（Controller 命名/路径/参数/分层） | `01-facade-service.md` |
| 内部接口（InnerController 命名/路径/参数） | `02-inner-service.md` |
| DTO 命名（Request/Response vs ApiRequest/ApiResponse） | `04-naming-standards.md` |
| Service 分层（ApplicationService/QueryService/ManageService） | `02-inner-service.md §6`、`07-data-access-standards.md §2` |
| 数据模型（DO/Mapper/XML/数据库表） | `05-database-standards.md` |
| Feign 接口（RemoteService/Fallback/路径） | `03-feign-interface.md` |
| 通用约束（CommonResult/远端透传/operatorId/异常处理） | `00-common-constraints.md` |

---

## 6. 应用约束到 Tech Spec 生成

在生成 tech-spec.yml 时，必须应用以上约束：

1. **接口定义阶段**：
   - 自动根据服务分层确定路径前缀
   - 自动根据命名规范生成 Controller 类名
   - 自动确定参数校验方式（@Valid vs 手动校验）

2. **DTO 定义阶段**：
   - 自动根据分层确定 DTO 后缀（Request/Response vs ApiRequest/ApiResponse）
   - 自动添加 `operatorId` 字段到写操作的 ApiRequest

3. **Service 定义阶段**：
   - 自动根据操作类型确定 Service 类型（Query vs Manage）
   - 自动确定 ApplicationService 的分层归属

4. **数据模型阶段**：
   - 自动根据表名生成 DO 类名
   - 自动添加基础字段（id, createTime, updateTime）
   - 自动根据删除策略确定删除字段

5. **生成后自检**：
   - 检查所有接口定义是否符合约束
   - 检查所有 DTO 命名是否符合约束
   - 检查所有 Service 分层是否符合约束
   - 检查数据模型是否符合约束
