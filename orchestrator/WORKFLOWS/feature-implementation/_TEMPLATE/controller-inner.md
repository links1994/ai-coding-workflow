# Controller 代码示例（应用服务 - InnerController）

> **规范参考**：[应用服务规范](../../../../.qoder/rules/code-generation/02-inner-service.md)
> **DoD检查**：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md#2-内部应用基础数据服务-controller-dod-检查)
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#22-内部-controller-模板)

## 代码结构示例

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
