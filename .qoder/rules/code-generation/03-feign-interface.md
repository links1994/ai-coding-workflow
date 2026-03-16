---
trigger: model_decision
description: Feign接口代码生成规范 - 生成mall-inner-api Feign接口时适用
globs: [ "**/*.java" ]
---

# Feign 接口代码生成规范

> **适用模块**：mall-inner-api 及其子模块

---

## 1. 命名规范

| 元素 | 命名规则 | 示例 |
|-------------|----------------------|--------------------------------------------|
| Feign 客户端接口 | `{模块名}RemoteService` | `AgentRemoteService`、`ClientRemoteService` |
| 远程请求参数 | `Xxx + ApiRequest` | `AgentCreateApiRequest` |
| 远程响应参数 | `Xxx + ApiResponse` | `AgentApiResponse` |

---

## 2. Feign 客户端拆分规范

根据业务域差异程度，选择以下两种策略之一：

### 2.1 策略 A：单文件聚合（默认）

**适用场景**：同一目标服务内各接口**业务域相近**，调用方通常一起引入。

- `feign/` 目录下只有一个 `XxxRemoteService.java`
- 新增接口直接在文件末尾追加方法
- 可通过注释分区（如 `//====== 业务模块 A ======`）组织不同业务域
- `@FeignClient` 无需强制声明 `contextId`

```java
// ✅ 策略 A 示例
@FeignClient("mall-agent-employee-service")
public interface AgentEmployeeRemoteService {
    // ====== Agent 基础信息 ======
    @GetMapping("/inner/api/v1/agent/detail")
    CommonResult<AgentApiResponse> getAgentById(@RequestParam Long agentId);

    // ====== Agent 配额 ======
    @GetMapping("/inner/api/v1/agent/quota/detail")
    CommonResult<QuotaApiResponse> getQuota(@RequestParam Long agentId);
}
```

### 2.2 策略 B：多文件拆分 + contextId（按业务域）

**适用场景**：同一目标服务内存在**业务域差异较大**的接口组，且**被不同调用方单独引入**时。

- 允许在 `feign/` 目录下创建多个 `@FeignClient` 接口文件，每个文件对应一个业务域
- **每个 `@FeignClient` 必须声明 `contextId`**，值与接口类名（首字母小写驼峰）一致，防止 Spring Bean 注册冲突
- 典型案例：`mall-basic-api` 中 SystemConfig 与 IdGen 属于两个独立业务域，分别由不同调用方引入

```java
// ✅ 策略 B 示例 - 文件1：BasicRemoteService.java
@FeignClient(name = "mall-basic-service", contextId = "basicRemoteService")
public interface BasicRemoteService {
    @GetMapping("/inner/system/config/querySystemConfigValue")
    String querySystemConfigValue(@RequestParam String appName, @RequestParam String configKey);
}

// ✅ 策略 B 示例 - 文件2：IdGenRemoteService.java
@FeignClient(name = "mall-basic-service", contextId = "idGenRemoteService")
public interface IdGenRemoteService {
    @PostMapping("/inner/api/v1/idgen/generate")
    CommonResult<IdGenApiResponse> generate(@RequestBody IdGenApiRequest request);
}
```

**contextId 命名规则**：接口类名首字母小写驼峰，如 `BasicRemoteService` → `basicRemoteService`

**常见错误（❌ 必须避免）**：

- ❌ 多个 `@FeignClient` 指向同一服务但未声明 `contextId`（导致 Bean 注册冲突）
- ❌ 业务域相近时过度拆分文件（优先使用策略 A）
- ❌ `contextId` 值与接口类名不一致（命名混乱）

---

## 3. 接口定义规范

```java
// ✅ 正确：查询类使用 @RequestParam，禁止路径参数
@GetMapping("/inner/api/v1/agent/detail")
CommonResult<AgentApiResponse> getAgentById(@RequestParam("agentId") Long agentId);

// ✅ 正确：操作类或多参数使用 @RequestBody
@PostMapping("/inner/api/v1/agent/list")
CommonResult<CommonResult.PageData<AgentApiResponse>> pageAgent(
        @RequestBody AgentListApiRequest request);

// ❌ 错误：禁止路径参数
@GetMapping("/inner/api/v1/agent/{agentId}")
CommonResult<AgentApiResponse> getAgentById(@PathVariable("agentId") Long agentId);
```

---

## 4. 门面服务与应用服务对象命名区分

当门面服务调用远程服务时，通过命名后缀区分本地对象与远程对象：

| 对象类型 | 门面服务（本地使用） | mall-inner-api（远程定义） |
|------|---------------|----------------------|
| 请求参数 | `XxxRequest` | `XxxApiRequest` |
| 响应参数 | `XxxResponse` | `XxxApiResponse` |
