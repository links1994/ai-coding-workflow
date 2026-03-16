# ApplicationService 模板

## 约束清单（DoD）

**门面服务 ApplicationService**：
- [ ] 只调用 `RemoteService`（Feign 接口），**禁止**直接注入 `Mapper` 或 `AimXxxService`
- [ ] 调用 Feign 接口后必须校验 `CommonResult.isSuccess()`
- [ ] 远端业务失败使用 `CommonResult.failed(code, message)` 透传，**禁止**包装为 `BusinessException`
- [ ] 远程通信异常（网络超时等）抛出 `RemoteApiCallException`
- [ ] 负责将 `XxxApiResponse` 转换为 `XxxResponse`，即使字段完全相同，转换也**不得省略**
- [ ] 不涉及写操作的方法不标注 `@Transactional`

**应用服务 ApplicationService**：
- [ ] 只调用 `QueryService` 和 `ManageService`，**禁止**直接注入 `Mapper` 或 `AimXxxService`
- [ ] **禁止**在 ApplicationService 中编写 SQL 或查询逻辑
- [ ] 涉及多个写操作的方法标注 `@Transactional(rollbackFor = Exception.class)`
- [ ] 业务编排和协调，不直接操作数据

## 门面服务代码模板

```java
package com.aim.mall.admin.service;

import com.aim.mall.admin.dto.request.{Name}CreateRequest;
import com.aim.mall.admin.dto.request.{Name}UpdateRequest;
import com.aim.mall.admin.dto.request.{Name}ListRequest;
import com.aim.mall.admin.dto.response.{Name}Response;
import com.aim.mall.admin.dto.response.{Name}DetailVO;
import com.aim.mall.agent.employee.api.dto.request.{Name}CreateApiRequest;
import com.aim.mall.agent.employee.api.dto.request.{Name}UpdateApiRequest;
import com.aim.mall.agent.employee.api.dto.request.{Name}ListApiRequest;
import com.aim.mall.agent.employee.api.dto.response.{Name}ApiResponse;
import com.aim.mall.agent.employee.api.feign.{Name}RemoteService;
import com.aim.mall.common.core.result.CommonResult;
import com.aim.mall.common.core.exception.RemoteApiCallException;
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

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 接口名 | `{Name}ApplicationService` | `JobTypeApplicationService` |
| 实现名 | `{Name}ApplicationServiceImpl` | `JobTypeApplicationServiceImpl` |
| 包路径 | `service/` | `service/JobTypeApplicationService.java` |
