# Feign 接口代码示例

> **规范参�?*：[Feign 接口规范](../../../../.qoder/rules/code-generation/03-feign-interface.md)
> **DoD检�?*：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md#6-feign-接口-dod-检�?
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#29-feign-接口模板)

## 代码结构示例

```java
package {base_package}.{service}.api.feign;

import {base_package}.common.core.result.CommonResult;
import {base_package}.{service}.api.dto.request.{Name}CreateApiRequest;
import {base_package}.{service}.api.dto.request.{Name}UpdateApiRequest;
import {base_package}.{service}.api.dto.request.{Name}ListApiRequest;
import {base_package}.{service}.api.dto.response.{Name}ApiResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(
    name = "{service-name}",
    fallback = {Name}RemoteServiceFallback.class
)
public interface {Name}RemoteService {

    /**
     * 创建{Name}
     */
    @PostMapping("/inner/api/v1/{path}/create")
    CommonResult<Long> create(@RequestBody {Name}CreateApiRequest request);

    /**
     * 更新{Name}
     */
    @PostMapping("/inner/api/v1/{path}/update")
    CommonResult<Void> update(@RequestBody {Name}UpdateApiRequest request);

    /**
     * 删除{Name}
     */
    @PostMapping("/inner/api/v1/{path}/delete")
    CommonResult<Void> delete(@RequestParam("id") Long id, 
                              @RequestParam("operatorId") Long operatorId);

    /**
     * 查询{Name}详情
     */
    @PostMapping("/inner/api/v1/{path}/detail")
    CommonResult<{Name}ApiResponse> getDetail(@RequestParam("id") Long id);

    /**
     * 分页查询{Name}列表
     */
    @PostMapping("/inner/api/v1/{path}/page")
    CommonResult<CommonResult.PageData<{Name}ApiResponse>> page(@RequestBody {Name}ListApiRequest request);
}
```

## Fallback 降级类模�?

```java
package {base_package}.{service}.api.feign;

import {base_package}.common.core.result.CommonResult;
import {base_package}.{service}.api.dto.request.{Name}CreateApiRequest;
import {base_package}.{service}.api.dto.request.{Name}UpdateApiRequest;
import {base_package}.{service}.api.dto.request.{Name}ListApiRequest;
import {base_package}.{service}.api.dto.response.{Name}ApiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class {Name}RemoteServiceFallback implements {Name}RemoteService {

    @Override
    public CommonResult<Long> create({Name}CreateApiRequest request) {
        log.error("[创建{Name}] 服务降级, request={}", request);
        return CommonResult.failed("服务暂时不可用，请稍后重�?);
    }

    @Override
    public CommonResult<Void> update({Name}UpdateApiRequest request) {
        log.error("[更新{Name}] 服务降级, request={}", request);
        return CommonResult.failed("服务暂时不可用，请稍后重�?);
    }

    @Override
    public CommonResult<Void> delete(Long id, Long operatorId) {
        log.error("[删除{Name}] 服务降级, id={}", id);
        return CommonResult.failed("服务暂时不可用，请稍后重�?);
    }

    @Override
    public CommonResult<{Name}ApiResponse> getDetail(Long id) {
        log.error("[查询{Name}详情] 服务降级, id={}", id);
        return CommonResult.failed("服务暂时不可用，请稍后重�?);
    }

    @Override
    public CommonResult<CommonResult.PageData<{Name}ApiResponse>> page({Name}ListApiRequest request) {
        log.error("[分页查询{Name}] 服务降级");
        return CommonResult.failed("服务暂时不可用，请稍后重�?);
    }
}
```

## 命名规则

| 元素 | 命名规范 | 说明 |
|------|---------|------|
| Feign 接口 | `{Name}RemoteService` | 以业务实体名开头，`RemoteService` 结尾 |
| Fallback �?| `{Name}RemoteServiceFallback` | Feign接口�?+ `Fallback` |
| 包路�?| `feign/` | 统一放在 feign 包下 |
| ApiRequest | `{Name}{Action}ApiRequest` | 业务实体�?+ 动作 + `ApiRequest` |
| ApiResponse | `{Name}ApiResponse` | 业务实体�?+ `ApiResponse` |
