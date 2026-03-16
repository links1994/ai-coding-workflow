# QueryService 模板

## 约束清单（DoD）

- [ ] **禁止**使用任何 MyBatis-Plus 查询 API：`getById()`、`list()`、`page()`、`lambdaQuery()`、`QueryWrapper`、`LambdaQueryWrapper`
- [ ] 所有查询必须通过 XML Mapper 的原生 SQL 实现
- [ ] 同一实现类中**禁止同时注入** `AimXxxService` 和 `AimXxxMapper`，必须二选一
- [ ] 注入 `AimXxxService` 接口，**禁止**注入 `AimXxxServiceImpl`（实现类）
- [ ] **禁止**调用 `aimXxxService.getBaseMapper()`
- [ ] `QueryService` 不被 `ApplicationService` 以外的组件调用
- [ ] **禁止**在 `QueryService` 中发起 Feign 远程调用
- [ ] 不标注 `@Transactional`（查询层无需事务）
- [ ] 方法入参使用 `XxxQuery` / `XxxPageQuery`（不接受 `XxxRequest` / `XxxApiRequest`）
- [ ] 返回 `XxxApiResponse` 或 DTO，不直接返回 DO

## 代码模板

```java
package com.aim.mall.{service}.service;

import com.aim.mall.{service}.domain.dto.{Name}ApiResponse;
import com.aim.mall.{service}.domain.dto.{Name}PageQuery;
import com.aim.mall.{service}.domain.entity.Aim{Name}DO;
import com.aim.mall.{service}.mapper.Aim{Name}Mapper;
import com.aim.mall.{service}.service.mp.Aim{Name}Service;
import com.aim.mall.common.core.result.CommonResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class {Name}QueryServiceImpl implements {Name}QueryService {

    // 模式 A：注入 AimXxxService 接口
    private final Aim{Name}Service aim{Name}Service;
    
    // 模式 B：直接注入 AimXxxMapper（二选一）
    // private final Aim{Name}Mapper aim{Name}Mapper;

    @Override
    public {Name}ApiResponse getById(Long id) {
        log.info("[查询{Name}详情] id={}", id);
        
        // 模式 A：通过 baseMapper 调用原生 SQL
        Aim{Name}DO entity = ((Aim{Name}ServiceImpl) aim{Name}Service).getBaseMapper().selectById(id);
        
        // 模式 B：直接使用 Mapper
        // Aim{Name}DO entity = aim{Name}Mapper.selectById(id);
        
        if (entity == null) {
            log.warn("[查询{Name}详情] 记录不存在, id={}", id);
            return null;
        }
        
        {Name}ApiResponse response = convertToApiResponse(entity);
        log.info("[查询{Name}详情] 成功");
        return response;
    }

    @Override
    public List<{Name}ApiResponse> listByCondition({Name}Query query) {
        log.info("[查询{Name}列表] query={}", query);
        
        List<Aim{Name}DO> list = ((Aim{Name}ServiceImpl) aim{Name}Service).getBaseMapper().selectByCondition(query);
        
        List<{Name}ApiResponse> result = list.stream()
                .map(this::convertToApiResponse)
                .collect(Collectors.toList());
        
        log.info("[查询{Name}列表] 成功, size={}", result.size());
        return result;
    }

    @Override
    public CommonResult.PageData<{Name}ApiResponse> page({Name}PageQuery query) {
        log.info("[分页查询{Name}] query={}", query);
        
        // 查询总数
        long total = ((Aim{Name}ServiceImpl) aim{Name}Service).getBaseMapper().countByCondition(query);
        
        if (total == 0) {
            return CommonResult.PageData.empty();
        }
        
        // 查询列表
        List<Aim{Name}DO> list = ((Aim{Name}ServiceImpl) aim{Name}Service).getBaseMapper().selectPage(query);
        
        List<{Name}ApiResponse> items = list.stream()
                .map(this::convertToApiResponse)
                .collect(Collectors.toList());
        
        CommonResult.PageData<{Name}ApiResponse> pageData = new CommonResult.PageData<>();
        pageData.setItems(items);
        pageData.setTotalCount(total);
        
        log.info("[分页查询{Name}] 成功, total={}", total);
        return pageData;
    }

    @Override
    public boolean existsByName(String name) {
        log.info("[检查{Name}名称是否存在] name={}", name);
        
        Long count = ((Aim{Name}ServiceImpl) aim{Name}Service).getBaseMapper().countByName(name);
        return count != null && count > 0;
    }

    // 转换方法
    private {Name}ApiResponse convertToApiResponse(Aim{Name}DO entity) {
        {Name}ApiResponse response = new {Name}ApiResponse();
        response.setId(entity.getId());
        response.setName(entity.getName());
        response.setDescription(entity.getDescription());
        response.setSortOrder(entity.getSortOrder());
        response.setStatus(entity.getStatus());
        response.setCreateTime(entity.getCreateTime());
        response.setUpdateTime(entity.getUpdateTime());
        return response;
    }
}
```

## 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 接口 | `{Name}QueryService` | `JobTypeQueryService` |
| 实现 | `{Name}QueryServiceImpl` | `JobTypeQueryServiceImpl` |
| 包路径 | `service/`（直接平铺）| `service/JobTypeQueryService.java` |
| 入参 | `XxxQuery` / `XxxPageQuery` | `JobTypePageQuery` |
