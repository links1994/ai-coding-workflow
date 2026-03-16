# Controller 模板（应用服务 - InnerController）

## 约束清单（DoD）

- [ ] 只注入并调用 `ApplicationService`，**禁止**注入 `QueryService`、`ManageService`、`Mapper`
- [ ] 不存在任何 `try-catch` 块
- [ ] 不存在业务逻辑代码，只做参数接收和响应包装
- [ ] **禁止**解析 `@RequestHeader`，操作人 ID 通过 `XxxApiRequest.operatorId` 接收
- [ ] 请求入参使用 `XxxApiRequest`（以 `ApiRequest` 结尾），**禁止**使用 `XxxRequest`
- [ ] 响应出参使用 `XxxApiResponse`（以 `ApiResponse` 结尾）
- [ ] 参数 ≤ 2 个且为基础类型：使用 `@RequestParam`；其他情况：**一律使用 `@RequestBody`**
- [ ] **禁止**使用 `@Valid` / `jakarta.validation`，改用手动 `validateXxx()` 方法
- [ ] **禁止**使用 `@PathVariable` 路径参数
- [ ] HTTP 方法仅使用 GET / POST，**禁止** PUT / DELETE
- [ ] 所有写操作的 `XxxApiRequest` 包含 `operatorId` 字段（Long 类型）
- [ ] `XxxApiResponse` 实现 `Serializable`，`serialVersionUID = -1L`
- [ ] `XxxApiResponse` 中的 `LocalDateTime` 字段标注 `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")`
- [ ] 路径前缀为 `/inner/api/v1/`
- [ ] 每个 Controller 方法包含手动参数校验方法 `validateXxx(request)`
- [ ] `validateXxx()` 中校验必填字段不为 null/blank，`operatorId` 不为 null

## 代码模板

```java
package com.aim.mall.{service}.controller.inner;

import com.aim.mall.{service}.domain.dto.{Name}CreateApiRequest;
import com.aim.mall.{service}.domain.dto.{Name}UpdateApiRequest;
import com.aim.mall.{service}.domain.dto.{Name}ListApiRequest;
import com.aim.mall.{service}.domain.dto.{Name}ApiResponse;
import com.aim.mall.{service}.service.{Name}ApplicationService;
import com.aim.mall.common.core.result.CommonResult;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/inner/api/v1/{path}")
@RequiredArgsConstructor
@Tag(name = "{Name}-内部接口")
public class {Name}InnerController {

    private final {Name}ApplicationService applicationService;

    @Operation(summary = "创建{Name}")
    @PostMapping("/create")
    public CommonResult<Long> create(@RequestBody {Name}CreateApiRequest request) {
        validateCreateRequest(request);
        Long id = applicationService.create(request);
        return CommonResult.success(id);
    }

    @Operation(summary = "更新{Name}")
    @PostMapping("/update")
    public CommonResult<Void> update(@RequestBody {Name}UpdateApiRequest request) {
        validateUpdateRequest(request);
        applicationService.update(request);
        return CommonResult.success();
    }

    @Operation(summary = "删除{Name}")
    @PostMapping("/delete")
    public CommonResult<Void> delete(@RequestParam Long id, @RequestParam Long operatorId) {
        if (id == null) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "ID不能为空");
        }
        if (operatorId == null) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "操作人ID不能为空");
        }
        applicationService.delete(id, operatorId);
        return CommonResult.success();
    }

    @Operation(summary = "查询{Name}详情")
    @PostMapping("/detail")
    public CommonResult<{Name}ApiResponse> getDetail(@RequestParam Long id) {
        if (id == null) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "ID不能为空");
        }
        {Name}ApiResponse response = applicationService.getDetail(id);
        return CommonResult.success(response);
    }

    @Operation(summary = "分页查询{Name}列表")
    @PostMapping("/page")
    public CommonResult<CommonResult.PageData<{Name}ApiResponse>> page(@RequestBody {Name}ListApiRequest request) {
        validatePageRequest(request);
        CommonResult.PageData<{Name}ApiResponse> result = applicationService.page(request);
        return CommonResult.success(result);
    }

    private void validateCreateRequest({Name}CreateApiRequest request) {
        if (request == null) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "请求参数不能为空");
        }
        if (StringUtils.isBlank(request.getName())) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "名称不能为空");
        }
        if (request.getOperatorId() == null) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "操作人ID不能为空");
        }
    }

    private void validateUpdateRequest({Name}UpdateApiRequest request) {
        if (request == null) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "请求参数不能为空");
        }
        if (request.getId() == null) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "ID不能为空");
        }
        if (StringUtils.isBlank(request.getName())) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "名称不能为空");
        }
        if (request.getOperatorId() == null) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "操作人ID不能为空");
        }
    }

    private void validatePageRequest({Name}ListApiRequest request) {
        if (request == null) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "请求参数不能为空");
        }
        if (request.getPageNum() == null || request.getPageNum() < 1) {
            request.setPageNum(1);
        }
        if (request.getPageSize() == null || request.getPageSize() < 1) {
            request.setPageSize(10);
        }
    }
}
```

## 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 类名 | `{Name}InnerController` | `JobTypeInnerController` |
| 包路径 | `controller/inner/`（不建子域目录）| `controller/inner/` |
| 路径前缀 | `/inner/api/v1/{path}` | `/inner/api/v1/job-type` |
| Tag | `@Tag(name = "...")` 单一描述 | `@Tag(name = "岗位类型-内部接口")` |
