# Step: 分析上下文

## 目的
分析需求上下文，识别关键信息。

## 输入
- `product_requirements`: 产品需求
- `architecture_constraints`: 架构约束

## 输出
- `context_analysis`: 上下文分析结果

## 分析维度

### 1. 业务域识别

识别需求涉及的业务域：
- {DomainA}
- {DomainB}
- {DomainC}
- {DomainD}

### 2. 技术复杂度评估

评估需求的技术复杂度：
- 简单：单表 CRUD
- 中等：多表关联
- 复杂：分布式事务

### 3. 依赖关系识别

识别需求间的依赖：
- 强依赖：必须前置完成
- 弱依赖：可并行进行

## 输出格式

```yaml
context_analysis:
  business_domains:
    - name: "{DomainA}"
      requirements: [FR001, FR002]
  complexity:
    overall: medium
    breakdown:
      FR001: simple
      FR002: complex
  dependencies:
    - source: FR002
      target: FR001
      type: strong
```
