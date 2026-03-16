---
trigger: model_decision
description: 目录结构规范 - 代码生成前确定文件存放位置时适用
globs: [ "**/*.java" ]
---

# 目录结构规范

> **适用范围**：确定代码文件的包路径和目录结构

---

## 1. 应用服务 / 基础数据服务

应用服务和基础数据服务聚焦于**单一业务域**，`controller/` 下只有 `inner/` 一层，内部所有 Controller 直接平铺，不再按子域分目录。`service/` 同理，所有 Service 类直接平铺，以类名前缀区分业务。

```
{service}/src/main/java/{base-package}/
├── controller/
│   └── inner/                           # 所有 Inner Controller 直接平铺（不再按子域建子目录）
│       ├── {Name}InnerController.java
│       └── ScriptTemplateInnerController.java
├── service/                             # 所有 Service 直接平铺，以类名前缀区分业务
│   ├── mp/
│   │   └── Aim{Name}Service.java           # 继承 IService<Aim{Name}DO>
│   ├── {Name}ApplicationService.java       # 应用服务接口
│   ├── {Name}QueryService.java             # 查询服务接口
│   └── {Name}ManageService.java            # 管理服务接口
├── service/impl/
│   ├── mp/
│   │   └── Aim{Name}ServiceImpl.java       # 继承 ServiceImpl<Aim{Name}Mapper, Aim{Name}DO>
│   ├── {Name}ApplicationServiceImpl.java
│   ├── {Name}QueryServiceImpl.java
│   └── {Name}ManageServiceImpl.java
├── mapper/
│   └── Aim{Name}Mapper.java
└── domain/
    ├── entity/                          # Aim{Name}DO（必须以 Aim 开头，DO 结尾）
    ├── dto/                             # 内部传输对象（Query / DTO）
    ├── enums/
    └── exception/
```

---

## 2. 门面服务（BFF）

门面服务聚合**多个业务域**，`controller/` 和 `dto/` 下按**业务域**（`{domain}`）建子目录（如 `{domain}/`、`merchant/`）；`service/` 层所有 ApplicationService 直接平铺，不按子域建子目录。

```
{facade-service}/src/main/java/{base-package}/
├── controller/
│   └── {domain}/                        # 按业务域分子目录（如 {domain}/、merchant/）
│       ├── {Name}AdminController.java  # 同一 domain 下所有子域 Controller 共用此目录
│       └── ScriptTemplateAdminController.java
├── service/                             # 所有业务域的 ApplicationService 均直接平铺，不建子目录
│   ├── {Name}ApplicationService.java   # 以类名前缀区分子域
│   ├── ScriptTemplateApplicationService.java
│   └── impl/
│       ├── {Name}ApplicationServiceImpl.java
│       └── ScriptTemplateApplicationServiceImpl.java
└── dto/
    ├── request/
    │   └── {domain}/                    # 按业务域分子目录，同一 domain 下所有子域 Request 共用
    │       ├── {Name}CreateRequest.java
    │       └── ScriptTemplateCreateRequest.java
    └── response/
        └── {domain}/                    # 按业务域分子目录，同一 domain 下所有子域 Response 共用
            ├── {Name}Response.java
            └── ScriptTemplateResponse.java
```

**门面服务通用约束**：不存在 `feign/` 目录，所有远程调用通过引入 `{inner-api-service}` 对应子模块实现。

---

## 3. 对比汇总

| 位置 | 应用服务 / 基础数据服务 | 门面服务（BFF） |
|------|------------------------|-----------------|
| `controller/` | `inner/` 下直接平铺，不分子域目录 | `{domain}/` 子目录，所有子域 Controller 共用 |
| `service/` | 直接平铺，以类名前缀区分 | 直接平铺，以类名前缀区分 |
| `dto/` | `domain/dto/`，内部传输对象 | `dto/request/{domain}/` + `dto/response/{domain}/`，按业务域分 |

---

## 4. 存量代码适配原则

代码生成前必须扫描目标服务的实际目录结构。若存量代码已存在 `controller/`、`service/`、`entity/`、`dto/request/`、`dto/response/`、`config/` 等目录，**以实际目录为准**，不得强制按规范目录新建或迁移。规范目录仅作为**新建服务**的参考。

---

## 5. {inner-api-service} 目录结构

```
{inner-api-service}/{module}/
├── feign/
│   └── {Name}RemoteService.java            # Feign 接口
├── dto/
│   ├── request/
│   │   └── {Name}ApiRequest.java           # 远程请求参数
│   └── response/
│       └── {Name}ApiResponse.java          # 远程响应参数
└── fallback/
    └── {Name}RemoteServiceFallback.java    # Feign 降级实现
```

---

## 6. 包命名规范

| 服务类型 | 基础包名示例 |
|----------|--------------|
| {app-service} | `{base_package}.{domain}.employee` |
| mall-product | `{base_package}.product` |
| {facade-service} | `{base_package}.admin` |
| {facade-service-2} | `{base_package}.toc` |

---

## 7. 文件命名规范

| 类型 | 命名格式 | 示例 |
|------|----------|------|
| Inner Controller | `{业务域}InnerController` | `{Name}InnerController` |
| Admin Controller | `{业务域}AdminController` | `{Name}AdminController` |
| Application Service | `{业务域}ApplicationService` | `{Name}ApplicationService` |
| Query Service | `{业务域}QueryService` | `{Name}QueryService` |
| Manage Service | `{业务域}ManageService` | `{Name}ManageService` |
| MP Service | `Aim{业务域}Service` | `Aim{Name}Service` |
| Mapper | `{业务域}Mapper` | `{Name}Mapper` |
| DO | `Aim{业务域}DO` | `Aim{Name}DO` |
| Feign | `{业务域}RemoteService` | `{Name}RemoteService` |
| Request | `{业务域}{动作}Request` | `{Name}CreateRequest` |
| Response | `{业务域}Response` | `{Name}Response` |
| ApiRequest | `{业务域}{动作}ApiRequest` | `{Name}CreateApiRequest` |
| ApiResponse | `{业务域}ApiResponse` | `{Name}ApiResponse` |
