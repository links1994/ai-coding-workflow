# Step: 生成 Swagger API 文档

## 目的
基于生成的门面服务 Controller 代码，生成 Swagger 格式的 API 文档。

## 输入
- `tech_spec`: 技术规格书
- `facade_layer_code`: 门面服务层代码目录
- `application_layer_code`: 应用服务层代码目录
- `program_id`: Program 标识符

## 输出
- `swagger_docs`: Swagger API 文档目录

## 执行步骤

1. **扫描 Controller 文件**
   - 遍历 facade_layer_code 中的 Controller 文件
   - 识别 AdminController / AppController / MerchantController

2. **提取 API 信息**
   - 解析 @Tag 注解获取模块名称
   - 解析 @Operation 注解获取接口描述
   - 提取 @RequestMapping 路径
   - 分析方法参数和返回类型

3. **生成 Markdown 文档**
   - 按 Controller 组织文档
   - 包含 Frontmatter 元数据
   - 生成接口列表和详情

4. **增量更新**
   - 检查现有文档
   - 保留未变更接口内容
   - 更新变更的接口描述

## 输出文件结构

```
outputs/swagger/
├── {facade-service}/
│   └── {Name}Admin/
│       └── {中文功能描述}-{Name}AdminApi.md
└── {facade-service-2}/
    └── {Name}App/
        └── {中文功能描述}-{Name}AppApi.md
```

## 文档格式

### Frontmatter
```yaml
---
service: {facade-service}
controller: {Name}AdminController
module: {domain}
title: {中文功能描述}
version: 1.0.0
updated_at: 2026-03-17
updated_by: {program_id}
---
```

### 接口文档模板
- 接口名称和描述
- 请求方法 + 路径
- 请求参数表格
- 响应字段表格
- 示例请求/响应

## 触发条件

- Program 涉及门面服务 Controller 变更
- 用户主动要求生成 API 文档
- 产物归档前自动生成

## 跳过条件

- 纯应用服务或基础数据服务（无门面层变更）
- 用户明确指定跳过文档生成
