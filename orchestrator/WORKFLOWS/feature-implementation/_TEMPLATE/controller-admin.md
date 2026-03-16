# Controller 模板（门面服务 - AdminController）

## 约束清单（DoD）

- [ ] 只注入并调用 `ApplicationService`，**禁止**直接注入 `RemoteService`、`Mapper`
- [ ] 不存在任何 `try-catch` 块（由 `GlobalExceptionHandler` 统一处理）
- [ ] 不存在业务逻辑代码，只做参数接收和响应包装
- [ ] 包含 `@Tag(name = "一级标题/二级标题")` 注解，使用 `/` 分隔符
- [ ] 每个写操作方法包含 `@RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user` 参数
- [ ] 从 Header 解析操作人 ID：`UserInfoUtil.getUserInfo(user).getId()`
- [ ] 将 `operatorId` 写入 `XxxApiRequest`，通过 Feign 传递给应用服务
- [ ] 请求入参使用 `XxxRequest`（以 `Request` 结尾）
- [ ] 响应出参使用 `XxxResponse` 或 `XxxVO`，**禁止**直接暴露 `XxxApiResponse` 给前端
- [ ] POST/PUT/DELETE 使用 `@RequestBody` + `@Valid`；GET 多参数使用 `@RequestParam`
- [ ] `XxxResponse` / `XxxVO` 中的 `LocalDateTime` 字段标注 `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")`
- [ ] `XxxRequest` 实现 `Serializable`，`serialVersionUID = -1L`
- [ ] 路径前缀：`/admin/api/v1/`
- [ ] 路径参数（`@PathVariable`）最多 1 个，且必须放在 URL 最后
- [ ] HTTP 方法语义完整（GET / POST / PUT / DELETE）

## 代码模板

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
