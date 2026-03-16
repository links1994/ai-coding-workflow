# ApplicationService 代码示例

> **规范参考**：[服务层规范](../../../../.qoder/rules/code-generation/08-service-layer-standards.md)
> **DoD检查**：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md#7-applicationservice-dod-检查)
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#28-applicationservice-模板门面层)

## 代码结构示例

```java
package {base_package}.admin.service;

import {base_package}.admin.dto.request.{Name}CreateRequest;
import {base_package}.admin.dto.request.{Name}UpdateRequest;
import {base_package}.admin.dto.request.{Name}ListRequest;
import {base_package}.admin.dto.response.{Name}Response;
import {base_package}.admin.dto.response.{Name}DetailVO;
import {base_package}.{service}.api.dto.request.{Name}CreateApiRequest;
import {base_package}.{service}.api.dto.request.{Name}UpdateApiRequest;
import {base_package}.{service}.api.dto.request.{Name}ListApiRequest;
import {base_package}.{service}.api.dto.response.{Name}ApiResponse;
import {base_package}.{service}.api.feign.{Name}RemoteService;
import {base_package}.common.core.result.CommonResult;
import {base_package}.common.core.exception.RemoteApiCallException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class {Name}ApplicationServiceImpl implements {Name}ApplicationService {

    private final {Name}RemoteService {name}RemoteService;

    @Override
    public Long create({Name}CreateRequest request) {
        log.info("[创建{Name}] request={}", request);
        
        {Name}CreateApiRequest apiRequest = convertToCreateApiRequest(request);
        CommonResult<Long> result = {name}RemoteService.create(apiRequest);
        
        if (!result.isSuccess()) {
            log.warn("[创建{Name}] 远程调用失败: code={}, message={}", result.getCode(), result.getMessage());
            return CommonResult.failed(result.getCode(), result.getMessage()).getData();
        }
        
        log.info("[创建{Name}] 成功, id={}", result.getData());
        return result.getData();
    }

    @Override
    public void update({Name}UpdateRequest request) {
        log.info("[更新{Name}] request={}", request);
        
        {Name}UpdateApiRequest apiRequest = convertToUpdateApiRequest(request);
        CommonResult<Void> result = {name}RemoteService.update(apiRequest);
        
        if (!result.isSuccess()) {
            log.warn("[更新{Name}] 远程调用失败: code={}, message={}", result.getCode(), result.getMessage());
            CommonResult.failed(result.getCode(), result.getMessage());
            return;
        }
        
        log.info("[更新{Name}] 成功");
    }

    @Override
    public void delete(Long id, Long operatorId) {
        log.info("[删除{Name}] id={}, operatorId={}", id, operatorId);
        
        CommonResult<Void> result = {name}RemoteService.delete(id, operatorId);
        
        if (!result.isSuccess()) {
            log.warn("[删除{Name}] 远程调用失败: code={}, message={}", result.getCode(), result.getMessage());
            CommonResult.failed(result.getCode(), result.getMessage());
            return;
        }
        
        log.info("[删除{Name}] 成功");
    }

    @Override
    public {Name}DetailVO getDetail(Long id) {
        log.info("[查询{Name}详情] id={}", id);
        
        CommonResult<{Name}ApiResponse> result = {name}RemoteService.getDetail(id);
        
        if (!result.isSuccess()) {
            log.warn("[查询{Name}详情] 远程调用失败: code={}, message={}", result.getCode(), result.getMessage());
            return null;
        }
        
        {Name}DetailVO vo = convertToDetailVO(result.getData());
        log.info("[查询{Name}详情] 成功");
        return vo;
    }

    @Override
    public CommonResult.PageData<{Name}Response> page({Name}ListRequest request) {
        log.info("[分页查询{Name}] request={}", request);
        
        {Name}ListApiRequest apiRequest = convertToListApiRequest(request);
        CommonResult<CommonResult.PageData<{Name}ApiResponse>> result = {name}RemoteService.page(apiRequest);
        
        if (!result.isSuccess()) {
            log.warn("[分页查询{Name}] 远程调用失败: code={}, message={}", result.getCode(), result.getMessage());
            return CommonResult.failed(result.getCode(), result.getMessage()).getData();
        }
        
        List<{Name}Response> list = result.getData().getItems().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
        
        CommonResult.PageData<{Name}Response> pageData = new CommonResult.PageData<>();
        pageData.setItems(list);
        pageData.setTotalCount(result.getData().getTotalCount());
        
        log.info("[分页查询{Name}] 成功, total={}", pageData.getTotalCount());
        return pageData;
    }

    // 转换方法
    private {Name}CreateApiRequest convertToCreateApiRequest({Name}CreateRequest request) {
        {Name}CreateApiRequest apiRequest = new {Name}CreateApiRequest();
        apiRequest.setName(request.getName());
        apiRequest.setDescription(request.getDescription());
        apiRequest.setSortOrder(request.getSortOrder());
        apiRequest.setOperatorId(request.getOperatorId());
        return apiRequest;
    }

    private {Name}UpdateApiRequest convertToUpdateApiRequest({Name}UpdateRequest request) {
        {Name}UpdateApiRequest apiRequest = new {Name}UpdateApiRequest();
        apiRequest.setId(request.getId());
        apiRequest.setName(request.getName());
        apiRequest.setDescription(request.getDescription());
        apiRequest.setSortOrder(request.getSortOrder());
        apiRequest.setStatus(request.getStatus());
        apiRequest.setOperatorId(request.getOperatorId());
        return apiRequest;
    }

    private {Name}ListApiRequest convertToListApiRequest({Name}ListRequest request) {
        {Name}ListApiRequest apiRequest = new {Name}ListApiRequest();
        apiRequest.setKeyword(request.getKeyword());
        apiRequest.setStatus(request.getStatus());
        apiRequest.setPageNum(request.getPageNum());
        apiRequest.setPageSize(request.getPageSize());
        return apiRequest;
    }

    private {Name}Response convertToResponse({Name}ApiResponse apiResponse) {
        {Name}Response response = new {Name}Response();
        response.setId(apiResponse.getId());
        response.setName(apiResponse.getName());
        response.setDescription(apiResponse.getDescription());
        response.setSortOrder(apiResponse.getSortOrder());
        response.setStatus(apiResponse.getStatus());
        response.setCreateTime(apiResponse.getCreateTime());
        response.setUpdateTime(apiResponse.getUpdateTime());
        return response;
    }

    private {Name}DetailVO convertToDetailVO({Name}ApiResponse apiResponse) {
        {Name}DetailVO vo = new {Name}DetailVO();
        vo.setId(apiResponse.getId());
        vo.setName(apiResponse.getName());
        vo.setDescription(apiResponse.getDescription());
        vo.setSortOrder(apiResponse.getSortOrder());
        vo.setStatus(apiResponse.getStatus());
        vo.setCreateTime(apiResponse.getCreateTime());
        vo.setUpdateTime(apiResponse.getUpdateTime());
        return vo;
    }
}
```

## 命名规则

| 元素 | 命名规范 | 说明 |
|------|---------|------|
| 接口名 | `{Name}ApplicationService` | 业务实体名 + `ApplicationService` |
| 实现名 | `{Name}ApplicationServiceImpl` | 接口名 + `Impl` |
| 包路径 | `service/` | 统一放在 service 包下 |
