---
trigger: model_decision
description: 服务层规范 - 异常处理类型定义、日志规范
globs: [ "**/*.java" ]
---

# 服务层规范

> **适用范围**：Controller、ApplicationService、Feign 接口
>
> **通用约束**（异常处理、远端透传、CommonResult、日志、operatorId）详见 `00-common-constraints.md`

---

## 1. 异常处理规范

> 详见 `00-common-constraints.md §1`

### 1.1 三种标准异常类型（快速参考）

| 异常类型 | 使用场景 |
|----------|----------|
| `MethodArgumentValidationException` | 参数校验失败 |
| `RemoteApiCallException` | 远程服务调用失败（网络超时、服务不可用） |
| `BusinessException` | 业务规则违反 |

### 1.2 Controller 层不捕获异常

项目配置了 `GlobalExceptionHandler`，Controller 层**直接抛出**，由全局处理器统一处理。

### 1.3 远程调用结果处理规范

> 完整规则详见 `00-common-constraints.md §2`

核心原则：
- 调用 Feign 接口后必须校验 `CommonResult.isSuccess()`
- 远端业务失败：直接返回 `CommonResult.failed(result.getCode(), result.getMessage())`
- 远端失败透传方法的**返回类型必须为 `CommonResult<T>`**，禁止降维为基础类型
- 禁止将远端业务失败包装为 `BusinessException`

---

## 2. 参数注解规范

> 门面服务参数规则详见 `01-facade-service.md §2`
> 应用服务参数规则详见 `02-inner-service.md §2`

### 参数校验方式速查

| 层级 | 校验方式 |
|------|----------|
| 门面服务 Controller | `@Valid` + `jakarta.validation` 注解 |
| 应用服务 / 基础数据服务 Controller | 手动编写 `validate{Name}()` 方法，**禁止 `@Valid`** |

---

## 3. 日志规范

> 详见 `00-common-constraints.md §5`

### 日志级别速查

| 级别 | 使用场景 |
|------|----------|
| ERROR | 系统异常、需要立即处理的错误 |
| WARN | 业务异常、可预期的异常情况 |
| INFO | 业务流程关键节点、外部调用入参出参 |
| DEBUG | 详细调试信息、SQL 语句、方法入参 |

---

## 4. 操作人 ID 规范

> 详见 `00-common-constraints.md §6`

### operatorId 来源速查

| 层级 | 来源 |
|------|------|
| 门面服务 Controller | 解析 Header → `UserInfoUtil.getUserInfo(user).getId()` |
| 应用服务 Controller | 从 `ApiRequest.operatorId` 获取，**禁止**解析 Header |

---

## 5. CommonResult 使用规范

> 详见 `00-common-constraints.md §3`

### 快速参考

```java
return CommonResult.success(data);                                     // 成功
return CommonResult.failed(ErrorCodeEnum.PARAM_ERROR);                 // 本地业务失败
return CommonResult.failed(result.getCode(), result.getMessage());     // 远端透传
return CommonResult.failed("{detail message}");                        // 无枚举时兜底
```
