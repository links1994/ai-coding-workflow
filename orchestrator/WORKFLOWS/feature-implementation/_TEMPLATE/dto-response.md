# DTO Response 代码示例

> **规范参考**：[命名规范](../../../../.qoder/rules/code-generation/04-naming-standards.md)
> **DoD检查**：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md)
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#210-dto-模板)

## 门面服务 Response 示例（JobTypeResponse）

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
