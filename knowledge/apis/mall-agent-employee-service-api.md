# API: mall-agent-employee-service

## 服务信息

| 属性 | 值 |
|------|-----|
| 服务名 | mall-agent-employee-service |
| 中文名 | 智能体员工应用服务 |
| 层级 | application |
| 路径前缀 | /inner/api/v1 |

## 接口清单

### 岗位类型管理 (JobType)

| 方法 | 路径 | 请求 | 响应 | 说明 |
|------|------|------|------|------|
| POST | /job-types/list | JobTypePageApiRequest | PageData<JobTypeApiResponse> | 分页列表 |
| POST | /job-types/create | JobTypeCreateApiRequest | Long | 创建 |
| PUT | /job-types/update | JobTypeUpdateApiRequest | Boolean | 更新 |
| PUT | /job-types/status | JobTypeStatusApiRequest | Boolean | 状态变更 |
| DELETE | /job-types/delete | Long id | Boolean | 删除 |

## Feign 接口

```java
@FeignClient(name = "mall-agent-employee-service", contextId = "jobTypeRemoteService")
public interface JobTypeRemoteService {
    
    @PostMapping("/inner/api/v1/job-types/list")
    CommonResult<CommonResult.PageData<JobTypeApiResponse>> list(
            @RequestBody JobTypePageApiRequest request);
    
    @PostMapping("/inner/api/v1/job-types/create")
    CommonResult<Long> create(@RequestBody JobTypeCreateApiRequest request);
    
    @PutMapping("/inner/api/v1/job-types/update")
    CommonResult<Boolean> update(@RequestBody JobTypeUpdateApiRequest request);
    
    @PutMapping("/inner/api/v1/job-types/status")
    CommonResult<Boolean> updateStatus(@RequestBody JobTypeStatusApiRequest request);
    
    @DeleteMapping("/inner/api/v1/job-types/delete")
    CommonResult<Boolean> delete(@RequestParam("id") Long id);
}
```

## 错误码

| 错误码 | 描述 |
|--------|------|
| 10091001 | 参数错误 |
| 10091002 | 岗位类型名称不能为空 |
| 10092001 | 岗位类型已存在 |
| 10092002 | 岗位类型不存在 |
| 10092004 | 岗位类型有关联员工，无法删除 |
| 10095002 | 生成编码失败 |

## 变更历史

| 版本 | 日期 | Program | 变更说明 |
|------|------|---------|----------|
| 1.0 | 2026-03-08 | P-2026-001-F-001 | 初始版本，岗位类型管理接口 |
