---
trigger: always_on
description: 代码模板规范 - 定义代码生成时的结构模板和占位符规范
globs: [ "**/*.java", "**/*.xml", "**/*.sql" ]
---

# 代码模板规范

> **适用范围**：代码生成阶段，定义各层代码的结构模板和占位符替换规则
>
> **关联规范**：
> - [门面服务规范](./01-facade-service.md)
> - [应用服务规范](./02-inner-service.md)
> - [Feign 接口规范](./03-feign-interface.md)
> - [DoD 检查卡](./10-dod-cards.md)

---

## 1. 占位符规范

### 1.1 命名占位符

| 占位符 | 说明 | 示例 | 替换值 |
|--------|------|------|--------|
| `{Name}` | 业务实体名称（大驼峰） | `JobType` | 岗位类型 |
| `{name}` | 业务实体名称（小驼峰） | `jobType` | jobType |
| `{NAME}` | 业务实体名称（全大写） | `JOB_TYPE` | JOB_TYPE |
| `{domain}` | 领域名称（小写） | `agent` | agent |
| `{Domain}` | 领域名称（大驼峰） | `Agent` | Agent |
| `{module}` | 模块名称（小写下划线） | `agent_employee` | agent_employee |
| `{Module}` | 模块名称（大驼峰） | `AgentEmployee` | AgentEmployee |
| `{path}` | URL 路径（小写中划线） | `job-type` | job-type |
| `{service}` | 服务名称（小写） | `agent-employee` | agent-employee |

### 1.2 技术占位符

| 占位符 | 说明 | 示例 |
|--------|------|------|
| `{table_name}` | 数据库表名 | `aim_agent_job_type` |
| `{package}` | 包路径 | `com.aim.mall.admin` |
| `{base_package}` | 基础包路径 | `com.aim.mall` |
| `{author}` | 作者 | `code-generator` |
| `{date}` | 生成日期 | `2026-03-16` |
| `{time}` | 生成时间 | `14:30:00` |

---

## 2. 代码结构模板

### 2.1 门面 Controller 模板

**文件**: `{Name}AdminController.java`

```java
package {package}.controller.{domain};

import {package}.dto.request.{domain}.{Name}CreateRequest;
import {package}.dto.request.{domain}.{Name}UpdateRequest;
import {package}.dto.request.{domain}.{Name}ListRequest;
import {package}.dto.response.{domain}.{Name}Response;
import {package}.dto.response.{domain}.{Name}DetailVO;
import {package}.service.{Name}ApplicationService;
import com.aim.mall.common.core.result.CommonResult;
import com.aim.mall.common.core.util.UserInfoUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * {Name}管理控制器
 *
 * @author {author}
 * @date {date}
 */
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

### 2.2 内部 Controller 模板

**文件**: `{Name}InnerController.java`

```java
package {package}.controller.inner;

import {package}.dto.request.{Name}CreateApiRequest;
import {package}.dto.request.{Name}UpdateApiRequest;
import {package}.dto.request.{Name}PageApiRequest;
import {package}.dto.response.{Name}ApiResponse;
import {package}.service.{Name}QueryService;
import {package}.service.{Name}ManageService;
import com.aim.mall.common.core.result.CommonResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * {Name}内部接口控制器
 *
 * @author {author}
 * @date {date}
 */
@RestController
@RequestMapping("/inner/api/v1/{path}")
@RequiredArgsConstructor
public class {Name}InnerController {

    private final {Name}QueryService queryService;
    private final {Name}ManageService manageService;

    @PostMapping("/create")
    public CommonResult<Long> create(@RequestBody {Name}CreateApiRequest request) {
        validateCreateRequest(request);
        Long id = manageService.create(request);
        return CommonResult.success(id);
    }

    @PostMapping("/update")
    public CommonResult<Void> update(@RequestBody {Name}UpdateApiRequest request) {
        validateUpdateRequest(request);
        manageService.update(request);
        return CommonResult.success();
    }

    @PostMapping("/delete")
    public CommonResult<Void> delete(@RequestParam Long id, @RequestParam Long operatorId) {
        validateDeleteRequest(id, operatorId);
        manageService.delete(id, operatorId);
        return CommonResult.success();
    }

    @GetMapping("/detail")
    public CommonResult<{Name}ApiResponse> getDetail(@RequestParam Long id) {
        {Name}ApiResponse detail = queryService.getDetail(id);
        return CommonResult.success(detail);
    }

    @PostMapping("/page")
    public CommonResult<CommonResult.PageData<{Name}ApiResponse>> page(@RequestBody {Name}PageApiRequest request) {
        validatePageRequest(request);
        CommonResult.PageData<{Name}ApiResponse> result = queryService.page(request);
        return CommonResult.success(result);
    }

    @GetMapping("/list")
    public CommonResult<List<{Name}ApiResponse>> list(@RequestParam(required = false) Integer status) {
        List<{Name}ApiResponse> list = queryService.list(status);
        return CommonResult.success(list);
    }

    // ============ 参数校验方法 ============

    private void validateCreateRequest({Name}CreateApiRequest request) {
        // 校验逻辑
    }

    private void validateUpdateRequest({Name}UpdateApiRequest request) {
        // 校验逻辑
    }

    private void validateDeleteRequest(Long id, Long operatorId) {
        // 校验逻辑
    }

    private void validatePageRequest({Name}PageApiRequest request) {
        // 校验逻辑
    }
}
```

### 2.3 DO 实体模板

**文件**: `Aim{Name}DO.java`

```java
package {package}.domain.entity;

import com.aim.mall.common.core.entity.BaseDO;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * {Name}实体
 *
 * @author {author}
 * @date {date}
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("{table_name}")
public class Aim{Name}DO extends BaseDO {

    private static final long serialVersionUID = 1L;

    /** 名称 */
    @TableField("name")
    private String name;

    /** 描述 */
    @TableField("description")
    private String description;

    /** 排序值 */
    @TableField("sort_order")
    private Integer sortOrder;

    /** 状态：0-禁用 1-启用 */
    @TableField("status")
    private Integer status;

    /** 逻辑删除：0-未删除 1-已删除 */
    @TableField("is_deleted")
    private Integer isDeleted;

    /** 创建人ID */
    @TableField("creator_id")
    private Long creatorId;

    /** 更新人ID */
    @TableField("updater_id")
    private Long updaterId;
}
```

### 2.4 Mapper 接口模板

**文件**: `Aim{Name}Mapper.java`

```java
package {package}.mapper;

import {package}.domain.entity.Aim{Name}DO;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * {Name}Mapper接口
 *
 * @author {author}
 * @date {date}
 */
@Mapper
public interface Aim{Name}Mapper extends BaseMapper<Aim{Name}DO> {

    /**
     * 根据ID查询详情
     */
    Aim{Name}DO selectDetailById(@Param("id") Long id);

    /**
     * 分页查询列表
     */
    List<Aim{Name}DO> selectPageList(@Param("offset") Integer offset, 
                                      @Param("limit") Integer limit,
                                      @Param("status") Integer status);

    /**
     * 查询总数
     */
    Long selectCount(@Param("status") Integer status);
}
```

### 2.5 Mapper XML 模板

**文件**: `Aim{Name}Mapper.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="{package}.mapper.Aim{Name}Mapper">

    <resultMap id="BaseResultMap" type="{package}.domain.entity.Aim{Name}DO">
        <id column="id" property="id"/>
        <result column="name" property="name"/>
        <result column="description" property="description"/>
        <result column="sort_order" property="sortOrder"/>
        <result column="status" property="status"/>
        <result column="is_deleted" property="isDeleted"/>
        <result column="create_time" property="createTime"/>
        <result column="update_time" property="updateTime"/>
        <result column="creator_id" property="creatorId"/>
        <result column="updater_id" property="updaterId"/>
    </resultMap>

    <sql id="Base_Column_List">
        id, name, description, sort_order, status, is_deleted,
        create_time, update_time, creator_id, updater_id
    </sql>

    <select id="selectDetailById" resultMap="BaseResultMap">
        SELECT <include refid="Base_Column_List"/>
        FROM {table_name}
        WHERE id = #{id}
          AND is_deleted = 0
    </select>

    <select id="selectPageList" resultMap="BaseResultMap">
        SELECT <include refid="Base_Column_List"/>
        FROM {table_name}
        WHERE is_deleted = 0
        <if test="status != null">
            AND status = #{status}
        </if>
        ORDER BY sort_order ASC, create_time DESC
        LIMIT #{offset}, #{limit}
    </select>

    <select id="selectCount" resultType="java.lang.Long">
        SELECT COUNT(*)
        FROM {table_name}
        WHERE is_deleted = 0
        <if test="status != null">
            AND status = #{status}
        </if>
    </select>

</mapper>
```

### 2.6 QueryService 模板

**文件**: `{Name}QueryService.java` / `{Name}QueryServiceImpl.java`

```java
package {package}.service;

import {package}.domain.entity.Aim{Name}DO;
import {package}.dto.response.{Name}ApiResponse;
import com.aim.mall.common.core.result.CommonResult;

import java.util.List;

/**
 * {Name}查询服务接口
 */
public interface {Name}QueryService {

    /**
     * 查询详情
     */
    {Name}ApiResponse getDetail(Long id);

    /**
     * 分页查询
     */
    CommonResult.PageData<{Name}ApiResponse> page(Integer pageNum, Integer pageSize, Integer status);

    /**
     * 列表查询
     */
    List<{Name}ApiResponse> list(Integer status);
}
```

```java
package {package}.service.impl;

import {package}.domain.entity.Aim{Name}DO;
import {package}.dto.response.{Name}ApiResponse;
import {package}.mapper.Aim{Name}Mapper;
import {package}.service.Aim{Name}Service;
import {package}.service.{Name}QueryService;
import com.aim.mall.common.core.result.CommonResult;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * {Name}查询服务实现
 */
@Service
@RequiredArgsConstructor
public class {Name}QueryServiceImpl implements {Name}QueryService {

    private final Aim{Name}Mapper aim{Name}Mapper;

    @Override
    public {Name}ApiResponse getDetail(Long id) {
        Aim{Name}DO entity = aim{Name}Mapper.selectDetailById(id);
        return convertToApiResponse(entity);
    }

    @Override
    public CommonResult.PageData<{Name}ApiResponse> page(Integer pageNum, Integer pageSize, Integer status) {
        int offset = (pageNum - 1) * pageSize;
        List<Aim{Name}DO> list = aim{Name}Mapper.selectPageList(offset, pageSize, status);
        Long total = aim{Name}Mapper.selectCount(status);
        
        List<{Name}ApiResponse> items = list.stream()
                .map(this::convertToApiResponse)
                .collect(Collectors.toList());
        
        CommonResult.PageData<{Name}ApiResponse> pageData = new CommonResult.PageData<>();
        pageData.setTotalCount(total);
        pageData.setItems(items);
        return pageData;
    }

    @Override
    public List<{Name}ApiResponse> list(Integer status) {
        // 实现列表查询
        return null;
    }

    private {Name}ApiResponse convertToApiResponse(Aim{Name}DO entity) {
        // 转换逻辑
        return null;
    }
}
```

### 2.7 ManageService 模板

**文件**: `{Name}ManageService.java` / `{Name}ManageServiceImpl.java`

```java
package {package}.service;

import {package}.dto.request.{Name}CreateApiRequest;
import {package}.dto.request.{Name}UpdateApiRequest;

/**
 * {Name}管理服务接口
 */
public interface {Name}ManageService {

    /**
     * 创建
     */
    Long create({Name}CreateApiRequest request);

    /**
     * 更新
     */
    void update({Name}UpdateApiRequest request);

    /**
     * 删除
     */
    void delete(Long id, Long operatorId);
}
```

```java
package {package}.service.impl;

import {package}.domain.entity.Aim{Name}DO;
import {package}.dto.request.{Name}CreateApiRequest;
import {package}.dto.request.{Name}UpdateApiRequest;
import {package}.service.Aim{Name}Service;
import {package}.service.{Name}ManageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * {Name}管理服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class {Name}ManageServiceImpl implements {Name}ManageService {

    private final Aim{Name}Service aim{Name}Service;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long create({Name}CreateApiRequest request) {
        log.info("[创建{Name}] request={}", request);
        
        Aim{Name}DO entity = convertToEntity(request);
        aim{Name}Service.save(entity);
        
        log.info("[创建{Name}成功] id={}", entity.getId());
        return entity.getId();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void update({Name}UpdateApiRequest request) {
        log.info("[更新{Name}] request={}", request);
        
        Aim{Name}DO entity = convertToEntity(request);
        entity.setUpdaterId(request.getOperatorId());
        aim{Name}Service.updateById(entity);
        
        log.info("[更新{Name}成功] id={}", request.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id, Long operatorId) {
        log.info("[删除{Name}] id={}, operatorId={}", id, operatorId);
        
        aim{Name}Service.removeById(id);
        
        log.info("[删除{Name}成功] id={}", id);
    }

    private Aim{Name}DO convertToEntity({Name}CreateApiRequest request) {
        // 转换逻辑
        return null;
    }

    private Aim{Name}DO convertToEntity({Name}UpdateApiRequest request) {
        // 转换逻辑
        return null;
    }
}
```

### 2.8 ApplicationService 模板（门面层）

**文件**: `{Name}ApplicationService.java` / `{Name}ApplicationServiceImpl.java`

```java
package {package}.service;

import {package}.dto.request.{Name}CreateRequest;
import {package}.dto.request.{Name}UpdateRequest;
import {package}.dto.request.{Name}ListRequest;
import {package}.dto.response.{Name}Response;
import {package}.dto.response.{Name}DetailVO;
import com.aim.mall.common.core.result.CommonResult;

/**
 * {Name}应用服务接口
 */
public interface {Name}ApplicationService {

    Long create({Name}CreateRequest request);

    void update({Name}UpdateRequest request);

    void delete(Long id, Long operatorId);

    {Name}DetailVO getDetail(Long id);

    CommonResult.PageData<{Name}Response> page({Name}ListRequest request);
}
```

```java
package {package}.service.impl;

import {package}.dto.request.{Name}CreateRequest;
import {package}.dto.request.{Name}UpdateRequest;
import {package}.dto.request.{Name}ListRequest;
import {package}.dto.response.{Name}Response;
import {package}.dto.response.{Name}DetailVO;
import {package}.feign.{Name}RemoteService;
import {package}.service.{Name}ApplicationService;
import com.aim.mall.common.core.result.CommonResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * {Name}应用服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class {Name}ApplicationServiceImpl implements {Name}ApplicationService {

    private final {Name}RemoteService {name}RemoteService;

    @Override
    public Long create({Name}CreateRequest request) {
        log.info("[创建{Name}] request={}", request);
        
        // 转换为 ApiRequest
        // {Name}CreateApiRequest apiRequest = convertToApiRequest(request);
        // CommonResult<Long> result = {name}RemoteService.create(apiRequest);
        // return result.getData();
        
        return null;
    }

    @Override
    public void update({Name}UpdateRequest request) {
        log.info("[更新{Name}] request={}", request);
        // 调用 RemoteService
    }

    @Override
    public void delete(Long id, Long operatorId) {
        log.info("[删除{Name}] id={}, operatorId={}", id, operatorId);
        // 调用 RemoteService
    }

    @Override
    public {Name}DetailVO getDetail(Long id) {
        // 调用 RemoteService
        return null;
    }

    @Override
    public CommonResult.PageData<{Name}Response> page({Name}ListRequest request) {
        // 调用 RemoteService
        return null;
    }
}
```

### 2.9 Feign 接口模板

**文件**: `{Name}RemoteService.java`

```java
package {package}.feign;

import {package}.dto.request.{Name}CreateApiRequest;
import {package}.dto.request.{Name}UpdateApiRequest;
import {package}.dto.request.{Name}PageApiRequest;
import {package}.dto.response.{Name}ApiResponse;
import com.aim.mall.common.core.result.CommonResult;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * {Name}Feign接口
 */
@FeignClient(name = "{service}", fallback = {Name}RemoteServiceFallback.class)
public interface {Name}RemoteService {

    @PostMapping("/inner/api/v1/{path}/create")
    CommonResult<Long> create(@RequestBody {Name}CreateApiRequest request);

    @PostMapping("/inner/api/v1/{path}/update")
    CommonResult<Void> update(@RequestBody {Name}UpdateApiRequest request);

    @PostMapping("/inner/api/v1/{path}/delete")
    CommonResult<Void> delete(@RequestParam Long id, @RequestParam Long operatorId);

    @GetMapping("/inner/api/v1/{path}/detail")
    CommonResult<{Name}ApiResponse> getDetail(@RequestParam Long id);

    @PostMapping("/inner/api/v1/{path}/page")
    CommonResult<CommonResult.PageData<{Name}ApiResponse>> page(@RequestBody {Name}PageApiRequest request);

    @GetMapping("/inner/api/v1/{path}/list")
    CommonResult<List<{Name}ApiResponse>> list(@RequestParam(required = false) Integer status);
}
```

### 2.10 DTO 模板

**Request（门面层）**:
```java
package {package}.dto.request.{domain};

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.io.Serializable;

/**
 * 创建{Name}请求
 */
@Data
public class {Name}CreateRequest implements Serializable {

    private static final long serialVersionUID = -1L;

    /** 名称 */
    @NotBlank(message = "名称不能为空")
    private String name;

    /** 描述 */
    private String description;

    /** 排序值 */
    private Integer sortOrder;

    /** 操作人ID（从Header解析后设置） */
    private Long operatorId;
}
```

**ApiRequest（内部接口层）**:
```java
package {package}.dto.request;

import lombok.Data;

import java.io.Serializable;

/**
 * 创建{Name}API请求
 */
@Data
public class {Name}CreateApiRequest implements Serializable {

    private static final long serialVersionUID = -1L;

    /** 名称 */
    private String name;

    /** 描述 */
    private String description;

    /** 排序值 */
    private Integer sortOrder;

    /** 操作人ID */
    private Long operatorId;
}
```

**Response/ApiResponse**:
```java
package {package}.dto.response.{domain};

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * {Name}响应
 */
@Data
public class {Name}Response implements Serializable {

    private static final long serialVersionUID = -1L;

    /** ID */
    private Long id;

    /** 名称 */
    private String name;

    /** 描述 */
    private String description;

    /** 排序值 */
    private Integer sortOrder;

    /** 状态 */
    private Integer status;

    /** 创建时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;

    /** 更新时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;
}
```

---

## 3. 生成规则

### 3.1 文件生成顺序

1. **Feign 接口**（mall-inner-api）
   - `{Name}RemoteService.java`
   - `{Name}CreateApiRequest.java`
   - `{Name}UpdateApiRequest.java`
   - `{Name}PageApiRequest.java`
   - `{Name}ApiResponse.java`

2. **应用服务层**（mall-agent-employee-service）
   - `Aim{Name}DO.java`
   - `Aim{Name}Mapper.java` / `.xml`
   - `{Name}QueryService.java` / `Impl.java`
   - `{Name}ManageService.java` / `Impl.java`
   - `{Name}InnerController.java`

3. **门面服务层**（mall-admin / mall-toc-service）
   - `{Name}CreateRequest.java`
   - `{Name}UpdateRequest.java`
   - `{Name}ListRequest.java`
   - `{Name}Response.java`
   - `{Name}DetailVO.java`
   - `{Name}ApplicationService.java` / `Impl.java`
   - `{Name}AdminController.java` / `{Name}AppController.java`

### 3.2 命名替换规则

| 原始占位符 | 替换示例（JobType） |
|------------|---------------------|
| `{Name}` | `JobType` |
| `{name}` | `jobType` |
| `{NAME}` | `JOB_TYPE` |
| `{domain}` | `agent` |
| `{Domain}` | `Agent` |
| `{path}` | `job-type` |
| `{table_name}` | `aim_agent_job_type` |

---

## 4. 使用说明

### 4.1 Skill 如何使用本规范

1. 读取本规范文件，理解占位符规则
2. 根据 tech-spec 中的接口定义，确定需要生成的文件列表
3. 按顺序读取对应模板，替换占位符
4. 生成最终代码文件

### 4.2 与 DoD 检查卡的关系

- **本规范**：定义"代码长什么样"（结构、占位符）
- **DoD 检查卡**：定义"代码是否符合规范"（约束、检查项）

生成代码后，必须使用 DoD 检查卡验证代码质量。
