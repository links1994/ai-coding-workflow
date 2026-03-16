# DTO Request 代码示例

> **规范参考**：[命名规范](../../../../.qoder/rules/code-generation/04-naming-standards.md)
> **DoD检查**：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md)
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#210-dto-模板)

## 门面服务 Request 示例（JobTypeCreateRequest）

```java
package com.aim.mall.admin.dto.request.{domain};

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.io.Serializable;

@Data
@Schema(description = "创建{Name}请求")
public class {Name}CreateRequest implements Serializable {

    private static final long serialVersionUID = -1L;

    @Schema(description = "名称", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "名称不能为空")
    private String name;

    @Schema(description = "描述")
    private String description;

    @Schema(description = "排序值", example = "0")
    private Integer sortOrder;

    // 操作人ID，由Controller从Header解析后注入
    private Long operatorId;
}
```

```java
package com.aim.mall.admin.dto.request.{domain};

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.io.Serializable;

@Data
@Schema(description = "更新{Name}请求")
public class {Name}UpdateRequest implements Serializable {

    private static final long serialVersionUID = -1L;

    @Schema(description = "ID", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull(message = "ID不能为空")
    private Long id;

    @Schema(description = "名称", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "名称不能为空")
    private String name;

    @Schema(description = "描述")
    private String description;

    @Schema(description = "排序值", example = "0")
    private Integer sortOrder;

    @Schema(description = "状态：0-禁用 1-启用", example = "1")
    private Integer status;

    // 操作人ID，由Controller从Header解析后注入
    private Long operatorId;
}
```

```java
package com.aim.mall.admin.dto.request.{domain};

import com.aim.mall.common.core.dto.PageQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;

@Data
@EqualsAndHashCode(callSuper = true)
@Schema(description = "查询{Name}列表请求")
public class {Name}ListRequest extends PageQuery implements Serializable {

    private static final long serialVersionUID = -1L;

    @Schema(description = "关键字（名称模糊查询）")
    private String keyword;

    @Schema(description = "状态：0-禁用 1-启用")
    private Integer status;
}
```

## 应用服务 ApiRequest 模板

```java
package com.aim.mall.{service}.domain.dto;

import lombok.Data;

import java.io.Serializable;

@Data
public class {Name}CreateApiRequest implements Serializable {

    private static final long serialVersionUID = -1L;

    private String name;

    private String description;

    private Integer sortOrder;

    // 写操作必须包含 operatorId
    private Long operatorId;
}
```

```java
package com.aim.mall.{service}.domain.dto;

import lombok.Data;

import java.io.Serializable;

@Data
public class {Name}UpdateApiRequest implements Serializable {

    private static final long serialVersionUID = -1L;

    private Long id;

    private String name;

    private String description;

    private Integer sortOrder;

    private Integer status;

    // 写操作必须包含 operatorId
    private Long operatorId;
}
```

```java
package com.aim.mall.{service}.domain.dto;

import lombok.Data;

import java.io.Serializable;

@Data
public class {Name}ListApiRequest implements Serializable {

    private static final long serialVersionUID = -1L;

    private String keyword;

    private Integer status;

    private Integer pageNum = 1;

    private Integer pageSize = 10;
}
```

```java
package com.aim.mall.{service}.domain.dto;

import lombok.Data;

@Data
public class {Name}PageQuery implements Serializable {

    private static final long serialVersionUID = -1L;

    private String keyword;

    private Integer status;

    private Integer pageNum = 1;

    private Integer pageSize = 10;

    // 计算偏移量
    public Integer getOffset() {
        return (pageNum - 1) * pageSize;
    }
}
```

```java
package com.aim.mall.{service}.domain.dto;

import lombok.Data;

@Data
public class {Name}Query implements Serializable {

    private static final long serialVersionUID = -1L;

    private String name;

    private Integer status;
}
```

## 命名规则

| 类型 | 命名规范 | 示例 |
|------|---------|------|
| 创建请求（门面） | `{Name}CreateRequest` | `JobTypeCreateRequest` |
| 更新请求（门面） | `{Name}UpdateRequest` | `JobTypeUpdateRequest` |
| 列表请求（门面） | `{Name}ListRequest` | `JobTypeListRequest` |
| 创建请求（应用） | `{Name}CreateApiRequest` | `JobTypeCreateApiRequest` |
| 更新请求（应用） | `{Name}UpdateApiRequest` | `JobTypeUpdateApiRequest` |
| 列表请求（应用） | `{Name}ListApiRequest` | `JobTypeListApiRequest` |
| 分页查询 | `{Name}PageQuery` | `JobTypePageQuery` |
| 普通查询 | `{Name}Query` | `JobTypeQuery` |
