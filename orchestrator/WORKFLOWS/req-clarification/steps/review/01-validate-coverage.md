# Step: 验证需求覆盖度

## 目的
验证 Feature 列表是否完整覆盖了需求文档中的所有功能点，确保无遗漏。

## 输入
- `requirement_spec_confirmed`: 已确认的需求规格文档
- `feature_list_confirmed`: 已确认的 Feature 列表
- `feedback_result`: 反馈结果

## 输出
- `coverage_check`: 覆盖度检查报告

## 执行步骤

### 1. 提取需求功能点

从 requirement-spec.md 中提取所有功能点：
- 管理端功能列表（增删改查、状态操作、批量操作等）
- 用户端功能列表（如有）
- 特殊业务规则对应的功能（审核流程、通知等）

### 2. 功能点与 Feature 映射

对每个功能点，找到对应的 Feature：

| 功能点 | 对应 Feature | 是否覆盖 |
|--------|-------------|---------|
| 分页查询 | F-002 | ✅ |
| 新增 | F-002 | ✅ |
| 状态切换 | F-002 | ✅ |
| 批量导出 | ？ | ❌ 未覆盖 |

### 3. 识别缺口

标记未被任何 Feature 覆盖的功能点：
- 若发现缺口，自动生成补充建议（新增 Feature 或扩充现有 Feature）
- 若功能点是无关紧要的边界情况，记录并说明原因

### 4. 生成检查报告

```yaml
coverage_check:
  total_requirements: 10
  covered: 10
  uncovered: 0
  coverage_rate: "100%"
  uncovered_items: []
  warnings: []
```

## 处理缺口

如果发现未覆盖的功能点：
1. 评估遗漏的严重性（核心功能 / 次要功能）
2. 给出补救方案：
   - 扩充现有 Feature 的范围
   - 新增 Feature
3. 需要用户确认补救方案
