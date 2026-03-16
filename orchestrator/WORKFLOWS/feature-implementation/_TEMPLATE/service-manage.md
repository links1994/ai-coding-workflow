# ManageService 模板

## 约束清单（DoD）

- [ ] 增删改操作使用 MyBatis-Plus IService 方法：`save()`、`updateById()`、`removeById()`
- [ ] **禁止**在 ManageService 中编写业务查询逻辑（查询应放在 QueryService）
- [ ] 写操作方法必须标注 `@Transactional(rollbackFor = Exception.class)`
- [ ] `AimXxxService` / `AimXxxServiceImpl` **严禁标注 `@Transactional`**
- [ ] 同一实现类中**禁止同时注入** `AimXxxService` 和 `AimXxxMapper`，必须二选一
- [ ] 注入 `AimXxxService` 接口，**禁止**注入 `AimXxxServiceImpl`（实现类）
- [ ] `ManageService` 不被 `ApplicationService` 以外的组件调用
- [ ] **禁止**在 `ManageService` 中发起 Feign 远程调用
- [ ] 方法入参使用 `XxxApiRequest`（写操作必须包含 `operatorId`）
- [ ] 返回值为实体 ID（Long）或 void

## 代码模板

```java
package com.aim.mall.{service}.service;

import com.aim.mall.{service}.domain.dto.{Name}CreateApiRequest;
import com.aim.mall.{service}.domain.dto.{Name}UpdateApiRequest;
import com.aim.mall.{service}.domain.entity.Aim{Name}DO;
import com.aim.mall.{service}.mapper.Aim{Name}Mapper;
import com.aim.mall.{service}.service.mp.Aim{Name}Service;
import com.aim.mall.common.core.enums.DeleteStatusEnum;
import com.aim.mall.common.core.enums.StatusEnum;
import com.aim.mall.common.core.exception.BusinessException;
import com.aim.mall.{service}.enums.{Service}ErrorCodeEnum;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Service
@RequiredArgsConstructor
public class {Name}ManageServiceImpl implements {Name}ManageService {

    // 模式 A：注入 AimXxxService 接口
    private final Aim{Name}Service aim{Name}Service;
    
    // 模式 B：直接注入 AimXxxMapper（二选一）
    // private final Aim{Name}Mapper aim{Name}Mapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long create({Name}CreateApiRequest request) {
        log.info("[创建{Name}] request={}", request);
        
        // 校验名称是否已存在
        checkNameDuplicate(request.getName(), null);
        
        Aim{Name}DO entity = convertToDO(request);
        entity.setStatus(StatusEnum.ENABLED.getCode());
        entity.setIsDeleted(DeleteStatusEnum.NOT_DELETED.getCode());
        entity.setCreateTime(LocalDateTime.now());
        entity.setUpdateTime(LocalDateTime.now());
        entity.setCreatorId(request.getOperatorId());
        entity.setUpdaterId(request.getOperatorId());
        
        aim{Name}Service.save(entity);
        
        log.info("[创建{Name}] 成功, id={}", entity.getId());
        return entity.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void update({Name}UpdateApiRequest request) {
        log.info("[更新{Name}] request={}", request);
        
        // 校验记录是否存在
        Aim{Name}DO exist = aim{Name}Service.getById(request.getId());
        if (exist == null || DeleteStatusEnum.isDeleted(exist.getIsDeleted())) {
            throw new BusinessException({Service}ErrorCodeEnum.{NAME}_NOT_FOUND);
        }
        
        // 校验名称是否已存在（排除当前记录）
        checkNameDuplicate(request.getName(), request.getId());
        
        Aim{Name}DO entity = convertToDO(request);
        entity.setUpdateTime(LocalDateTime.now());
        entity.setUpdaterId(request.getOperatorId());
        
        aim{Name}Service.updateById(entity);
        
        log.info("[更新{Name}] 成功, id={}", request.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id, Long operatorId) {
        log.info("[删除{Name}] id={}, operatorId={}", id, operatorId);
        
        // 校验记录是否存在
        Aim{Name}DO exist = aim{Name}Service.getById(id);
        if (exist == null || DeleteStatusEnum.isDeleted(exist.getIsDeleted())) {
            throw new BusinessException({Service}ErrorCodeEnum.{NAME}_NOT_FOUND);
        }
        
        // 软删除
        Aim{Name}DO update = new Aim{Name}DO();
        update.setId(id);
        update.setIsDeleted(DeleteStatusEnum.DELETED.getCode());
        update.setUpdateTime(LocalDateTime.now());
        update.setUpdaterId(operatorId);
        
        aim{Name}Service.updateById(update);
        
        log.info("[删除{Name}] 成功, id={}", id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateStatus(Long id, Integer status, Long operatorId) {
        log.info("[更新{Name}状态] id={}, status={}, operatorId={}", id, status, operatorId);
        
        // 校验记录是否存在
        Aim{Name}DO exist = aim{Name}Service.getById(id);
        if (exist == null || DeleteStatusEnum.isDeleted(exist.getIsDeleted())) {
            throw new BusinessException({Service}ErrorCodeEnum.{NAME}_NOT_FOUND);
        }
        
        // 校验状态是否有效
        if (!StatusEnum.isValid(status)) {
            throw new BusinessException({Service}ErrorCodeEnum.PARAM_ERROR, "状态值无效");
        }
        
        Aim{Name}DO update = new Aim{Name}DO();
        update.setId(id);
        update.setStatus(status);
        update.setUpdateTime(LocalDateTime.now());
        update.setUpdaterId(operatorId);
        
        aim{Name}Service.updateById(update);
        
        log.info("[更新{Name}状态] 成功, id={}", id);
    }

    // 辅助方法
    private void checkNameDuplicate(String name, Long excludeId) {
        // 通过 QueryService 或 Mapper 检查名称是否已存在
        // 具体实现根据业务需求
    }

    private Aim{Name}DO convertToDO({Name}CreateApiRequest request) {
        Aim{Name}DO entity = new Aim{Name}DO();
        entity.setName(request.getName());
        entity.setDescription(request.getDescription());
        entity.setSortOrder(request.getSortOrder());
        return entity;
    }

    private Aim{Name}DO convertToDO({Name}UpdateApiRequest request) {
        Aim{Name}DO entity = new Aim{Name}DO();
        entity.setId(request.getId());
        entity.setName(request.getName());
        entity.setDescription(request.getDescription());
        entity.setSortOrder(request.getSortOrder());
        entity.setStatus(request.getStatus());
        return entity;
    }
}
```

## 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 接口 | `{Name}ManageService` | `JobTypeManageService` |
| 实现 | `{Name}ManageServiceImpl` | `JobTypeManageServiceImpl` |
| 包路径 | `service/`（直接平铺）| `service/JobTypeManageService.java` |
