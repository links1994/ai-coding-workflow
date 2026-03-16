# Step: 需求全景扫描

## 目的
扫描并识别所有需求点。

## 输入
- `product_requirements`: 产品需求

## 输出
- `requirement_list`: 需求列表

## 执行步骤

### 1. 功能需求扫描

从 PRD 中提取：
- 功能点描述
- 业务规则
- 验收标准

### 2. 非功能需求扫描

提取：
- 性能要求
- 安全要求
- 可用性要求

### 3. 输出需求列表

```yaml
requirement_list:
  functional:
    - id: R001
      name: "{Name}管理"
      description: "支持{Name}的增删改查"
      source: "PRD 3.1节"
  non_functional:
    - id: N001
      category: performance
      description: "接口响应时间 < 200ms"
```
