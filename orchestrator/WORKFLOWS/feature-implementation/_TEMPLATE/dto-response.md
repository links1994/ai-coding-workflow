# DTO Response 模板

## 约束清单（DoD）

- [ ] 门面服务 Response 以 `Response` 结尾，如 `JobTypeResponse`
- [ ] 应用服务 ApiResponse 以 `ApiResponse` 结尾，如 `JobTypeApiResponse`
- [ ] 必须实现 `Serializable`，`serialVersionUID = -1L`
- [ ] `LocalDateTime` 字段必须标注 `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")`
- [ ] VO（视图对象）仅用于门面服务，用于聚合多个 Response
- [ ] 禁止在 Response 中暴露敏感字段（如密码、密钥等）

## 门面服务 Response 模板

```java
package com.aim.mall.admin.dto.response.{domain};

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@Schema(description = "{Name}响应")
public class {Name}Response implements Serializable {

    private static final long serialVersionUID = -1L;

    @Schema(description = "ID")
    private Long id;

    @Schema(description = "名称")
    private String name;

    @Schema(description = "描述")
    private String description;

    @Schema(description = "排序值")
    private Integer sortOrder;

    @Schema(description = "状态：0-禁用 1-启用")
    private Integer status;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;
}
```

```java
package com.aim.mall.admin.dto.response.{domain};

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Schema(description = "{Name}详情VO")
public class {Name}DetailVO implements Serializable {

    private static final long serialVersionUID = -1L;

    @Schema(description = "ID")
    private Long id;

    @Schema(description = "名称")
    private String name;

    @Schema(description = "描述")
    private String description;

    @Schema(description = "排序值")
    private Integer sortOrder;

    @Schema(description = "状态：0-禁用 1-启用")
    private Integer status;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;

    @Schema(description = "更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;

    // 可以包含关联对象
    @Schema(description = "关联列表")
    private List<{Name}RelationVO> relations;
}
```

```java
package com.aim.mall.admin.dto.response.{domain};

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;

@Data
@Schema(description = "{Name}关联VO")
public class {Name}RelationVO implements Serializable {

    private static final long serialVersionUID = -1L;

    @Schema(description = "关联ID")
    private Long id;

    @Schema(description = "关联名称")
    private String name;
}
```

## 应用服务 ApiResponse 模板

```java
package com.aim.mall.{service}.domain.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
public class {Name}ApiResponse implements Serializable {

    private static final long serialVersionUID = -1L;

    private Long id;

    private String name;

    private String description;

    private Integer sortOrder;

    private Integer status;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime updateTime;
}
```

## 命名规则

| 类型 | 命名规范 | 示例 |
|------|---------|------|
| 列表响应（门面） | `{Name}Response` | `JobTypeResponse` |
| 详情VO（门面） | `{Name}DetailVO` | `JobTypeDetailVO` |
| 关联VO（门面） | `{Name}RelationVO` | `JobTypeRelationVO` |
| 响应（应用） | `{Name}ApiResponse` | `JobTypeApiResponse` |
