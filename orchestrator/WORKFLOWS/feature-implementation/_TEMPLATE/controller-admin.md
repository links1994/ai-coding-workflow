# Controller 代码示例（门面服�?- AdminController�?

> **规范参�?*：[门面服务规范](../../../../.qoder/rules/code-generation/01-facade-service.md)
> **DoD检�?*：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md#1-门面-controller-dod-检�?
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#21-门面-controller-模板)

## 代码结构示例

```java
package {base_package}.admin.controller.{domain};

import {base_package}.admin.dto.request.{domain}.{Name}CreateRequest;
import {base_package}.admin.dto.request.{domain}.{Name}UpdateRequest;
import {base_package}.admin.dto.request.{domain}.{Name}ListRequest;
import {base_package}.admin.dto.response.{domain}.{Name}Response;
import {base_package}.admin.dto.response.{domain}.{Name}DetailVO;
import {base_package}.admin.service.{Name}ApplicationService;
import {base_package}.common.core.result.CommonResult;
import {base_package}.common.core.util.UserInfoUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin/api/v1/{path}")
@RequiredArgsConstructor
@Validated
@Tag(name = "{一级标题}/{二级标题}")
public class {Name}AdminController {

    private final {Name}ApplicationService applicationService;

    @Operation(summary = "创建{Name}")
    @PostMapping("/create")
    public CommonResult<Long> create(
            @RequestBody @Valid {Name}CreateRequest request,
            @RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user) {
        Long operatorId = UserInfoUtil.getUserInfo(user).getId();
        request.setOperatorId(operatorId);
        Long id = applicationService.create(request);
        return CommonResult.success(id);
    }

    @Operation(summary = "更新{Name}")
    @PostMapping("/update")
    public CommonResult<Void> update(
            @RequestBody @Valid {Name}UpdateRequest request,
            @RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user) {
        Long operatorId = UserInfoUtil.getUserInfo(user).getId();
        request.setOperatorId(operatorId);
        applicationService.update(request);
        return CommonResult.success();
    }

    @Operation(summary = "删除{Name}")
    @PostMapping("/delete/{id}")
    public CommonResult<Void> delete(
            @PathVariable Long id,
            @RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user) {
        Long operatorId = UserInfoUtil.getUserInfo(user).getId();
        applicationService.delete(id, operatorId);
        return CommonResult.success();
    }

    @Operation(summary = "查询{Name}详情")
    @GetMapping("/detail/{id}")
    public CommonResult<{Name}DetailVO> getDetail(@PathVariable Long id) {
        {Name}DetailVO detail = applicationService.getDetail(id);
        return CommonResult.success(detail);
    }

    @Operation(summary = "分页查询{Name}列表")
    @PostMapping("/page")
    public CommonResult<CommonResult.PageData<{Name}Response>> page(
            @RequestBody @Valid {Name}ListRequest request) {
        CommonResult.PageData<{Name}Response> result = applicationService.page(request);
        return CommonResult.success(result);
    }
}
```

## 命名规则

| 元素 | 命名规范 | 说明 |
|------|---------|------|
| 类名 | `{Name}AdminController` | 业务实体�?+ `AdminController` |
| 包路�?| `controller/{domain}/` | 统一放在 controller/{domain} 包下 |
| 路径前缀 | `/admin/api/v1/{path}` | 管理端统一前缀 + 业务路径 |
| Tag | `@Tag(name = "一�?二级")` | 使用 `/` 分隔的一级和二级菜单名称 |
