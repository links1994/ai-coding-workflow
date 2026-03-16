---
trigger: model_decision
description: PRD功能聚合拆分规范 - Feature定义与拆分策略
globs: ["orchestrator/PROGRAMS/**/decomposition.md"]
alwaysApply: false
---

# Feature 定义与拆分规范

本规范定义将 PRD 按**功能（Feature）聚合**进行拆分的标准，解决子需求过多导致的复杂度问题。

> **核心原则**：一个功能 = 一个 Feature，内部按服务分层管理，接口定义集中维护。

---

## 1. 拆分策略

**Feature**：具有完整业务价值的独立功能单元，可跨多个服务实现。

```yaml
feature:
  id: F-XXX                    # 格式：F-001, F-002...
  name: 功能名称
  description: 一句话描述业务价值
  priority: P0/P1/P2           # 优先级
  
  # 功能涉及的服务分层
  services:
    - name: {facade-service}         # 服务名
      layer: facade            # 层级：facade/application/data
      scope: 负责范围描述
      interfaces:              # 接口列表（仅门面层）
        - method: POST
          path: /admin/api/v1/xxx
          description: 接口描述
      
    - name: mall-{domain}
      layer: application
      scope: 业务逻辑实现
      dependencies:            # 依赖的其他服务
        - mall-product
        
    - name: mall-product
      layer: data
      scope: 数据访问层
      tables:                  # 涉及的数据表
        - aim_xxx
  
  # 跨服务接口定义（{inner-api-service}）
  api_definitions:
    - module: mall-product-api
      feign: {Name}RemoteService
      methods:
        - signature: ApiResponse methodName(params)
          description: 方法描述
  
  # 依赖关系
  dependencies:
    hard: []                   # 强依赖（必须完成）
    soft: []                   # 软依赖（可降级）
  
  # 验收标准
  acceptance_criteria:
    - 可验证的业务条件1
    - 可验证的业务条件2
```

---

## 2. 拆分粒度控制

### 2.1 Feature 大小评估

| 指标 | 建议范围 | 说明 |
|------|----------|------|
| 涉及服务数 | 2-4 个 | 过多考虑拆分 |
| 接口数量 | 5-15 个 | 过多考虑拆分 |
| 数据表数量 | 1-5 个 | 过多考虑拆分 |
| 开发人天 | 3-10 天 | 过大考虑拆分 |

### 2.2 拆分决策树

```
PRD 功能点分析
    │
    ├─ 是否独立业务模块？
    │   ├─ 是 → 独立 Feature
    │   └─ 否 → 继续分析
    │
    ├─ 涉及服务 > 4 个？
    │   ├─ 是 → 按业务域拆分多个 Feature
    │   └─ 否 → 合并为一个 Feature
    │
    └─ 接口数量 > 15 个？
        ├─ 是 → 按操作类型拆分（查询/管理）
        └─ 否 → 保持为一个 Feature
```

---

## 3. 与 Program 的映射

### 3.1 Feature → Program

每个 Feature 对应一个 `implementation` 类型的 Program：

```
orchestrator/PROGRAMS/
├── P-2024-001-user-management/      # 对应 F-001
│   ├── PROGRAM.md
│   ├── STATUS.yml
│   ├── SCOPE.yml
│   └── workspace/
├── P-2024-002-xxx/                   # 对应 F-002
│   └── ...
```

### 3.2 Program 命名规范

```
P-{YYYY}-{NNN}-{feature-name}

示例：
- P-2024-001-user-management
- P-2024-002-order-management
- P-2024-003-product-catalog
```

---

## 4. Checklist

### Phase 1 完结检查

- [ ] 所有 PRD 功能点已映射为 Feature
- [ ] 每个 Feature 已明确服务分层
- [ ] 接口定义已集中维护在 api_definitions
- [ ] 数据表归属已明确
- [ ] 依赖关系已分析
- [ ] 开发顺序已建议
