# Controller 代码示例（门面服务 - AdminController）

> **规范参考**：[门面服务规范](../../../../.qoder/rules/code-generation/01-facade-service.md)
> **DoD检查**：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md#1-门面-controller-dod-检查)
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#21-门面-controller-模板)

## 代码结构示例

```java
package com.aim.mall.admin.controller.{domain};

import com.aim.mall.admin.dto.request.{domain}.{Name}CreateRequest;
import com.aim.mall.admin.dto.request.{domain}.{Name}UpdateRequest;
import com.aim.mall.admin.dto.request.{domain}.{Name}ListRequest;
import com.aim.mall.admin.dto.response.{domain}.{Name}Response;
import com.aim.mall.admin.dto.response.{domain}.{Name}DetailVO;
import com.aim.mall.admin.service.{Name}ApplicationService;
import com.aim.mall.common.core.result.CommonResult;
import com.aim.mall.common.core.util.UserInfoUtil;
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

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 类名 | `{Name}AdminController` | `JobTypeAdminController` |
| 包路径 | `controller/{domain}/` | `controller/agent/` |
| 路径前缀 | `/admin/api/v1/{path}` | `/admin/api/v1/job-type` |
| Tag | `@Tag(name = "一级/二级")` | `@Tag(name = "智能员工/岗位类型")` |
