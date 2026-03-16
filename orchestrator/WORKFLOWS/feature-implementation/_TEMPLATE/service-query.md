# QueryService 代码示例

> **规范参考**：[数据访问规范](../../../../.qoder/rules/code-generation/07-data-access-standards.md)
> **DoD检查**：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md#3-queryservice-dod-检查)
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#26-queryservice-模板)

## 代码结构示例

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
