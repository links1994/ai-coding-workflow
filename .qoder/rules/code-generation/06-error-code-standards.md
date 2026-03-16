---
trigger: model_decision
description: 错误码规范 - 生成错误码枚举时适用
globs: [ "**/*.java" ]
---

# 错误码规范

> **适用范围**：错误码枚举定义、异常处理

---

## 1. 错误码格式

错误码采用 **8位数字** 格式：`SSMMTNNN`

| 位置 | 含义 | 说明 |
|------|------|------|
| SS | 系统代码 | 标识所属系统/服务 |
| MM | 模块代码 | 标识所属业务模块 |
| T | 错误类型 | 标识错误分类 |
| NNN | 错误序号 | 具体错误编号 |

---

## 2. 系统代码（SS）

| 代码 | 系统/服务 |
|------|-----------|
| 10 | mall-admin |
| 11 | mall-toc-service |
| 12 | mall-tob-service |
| 13 | mall-ai |
| 20 | mall-agent-employee-service |
| 21 | mall-product |
| 22 | mall-merchant |
| 23 | mall-client |
| 30 | mall-common |
| 99 | 系统级通用 |

---

## 3. 模块代码（MM）

由各个服务自行定义，从 01 开始递增。

**示例**（mall-agent-employee-service）：
| 代码 | 模块 |
|------|------|
| 01 | 岗位类型管理 |
| 02 | 智能员工管理 |
| 03 | 名额配置管理 |
| 04 | 话术管理 |
| 05 | 知识库管理 |

---

## 4. 错误类型（T）

| 代码 | 类型 | 说明 |
|------|------|------|
| 1 | 参数错误 | 请求参数校验失败 |
| 2 | 业务错误 | 业务规则校验失败 |
| 3 | 系统错误 | 系统内部异常 |
| 4 | 第三方错误 | 外部服务调用失败 |
| 5 | 权限错误 | 权限/认证相关错误 |
| 9 | 未知错误 | 未分类错误 |

---

## 5. 错误码示例

```java
public enum AgentErrorCodeEnum implements ErrorCode {
    
    // 参数错误（类型 1）
    PARAM_ERROR(200101001, "参数错误"),
    PARAM_NAME_EMPTY(200101002, "岗位名称不能为空"),
    PARAM_NAME_TOO_LONG(200101003, "岗位名称长度不能超过50"),
    
    // 业务错误（类型 2）
    JOB_TYPE_NOT_FOUND(200102001, "岗位类型不存在"),
    JOB_TYPE_NAME_DUPLICATE(200102002, "岗位类型名称已存在"),
    JOB_TYPE_IN_USE(200102003, "岗位类型正在使用中，无法删除"),
    
    // 系统错误（类型 3）
    SYSTEM_ERROR(200103001, "系统繁忙，请稍后重试"),
    DATABASE_ERROR(200103002, "数据库操作失败"),
    
    // 第三方错误（类型 4）
    REMOTE_CALL_ERROR(200104001, "远程服务调用失败"),
    
    // 权限错误（类型 5）
    PERMISSION_DENIED(200105001, "无权操作"),
    
    // 未知错误（类型 9）
    UNKNOWN_ERROR(200109001, "未知错误");
    
    private final int code;
    private final String message;
    
    AgentErrorCodeEnum(int code, String message) {
        this.code = code;
        this.message = message;
    }
    
    @Override
    public int getCode() {
        return code;
    }
    
    @Override
    public String getMessage() {
        return message;
    }
}
```

---

## 6. 错误码使用规范

### 6.1 Controller 层

```java
// 参数校验失败（自动抛出）
throw new MethodArgumentValidationException("参数校验失败");

// 业务异常
throw new BusinessException(AgentErrorCodeEnum.JOB_TYPE_NOT_FOUND);

// 带动态参数的业务异常
throw new BusinessException(AgentErrorCodeEnum.PARAM_NAME_TOO_LONG, "当前长度：" + name.length());
```

### 6.2 Service 层

```java
// 业务规则校验失败
if (jobType == null) {
    throw new BusinessException(AgentErrorCodeEnum.JOB_TYPE_NOT_FOUND);
}

// 远程调用失败
if (!remoteResult.isSuccess()) {
    throw new BusinessException(AgentErrorCodeEnum.REMOTE_CALL_ERROR);
}
```

### 6.3 禁止事项

- **禁止**在代码中直接使用魔法数字作为错误码
- **禁止**随意创建新的错误码，优先复用已有错误码
- **禁止**错误码与错误信息不匹配

---

## 7. 错误码管理

### 7.1 新增错误码流程

1. 检查是否已有合适的错误码可复用
2. 确定系统代码、模块代码、错误类型
3. 选择下一个可用的错误序号
4. 在枚举中添加新错误码
5. 更新错误码文档

### 7.2 错误码范围分配

| 范围 | 用途 |
|------|------|
| 001-099 | 通用错误（参数、系统、权限等） |
| 100-199 | 模块特定错误（如岗位类型管理） |
| 200-299 | 模块特定错误（如智能员工管理） |
| ... | ... |
