# Step: 整体反馈与调整

## 目的
在需求文档通过完整性验证后，给用户最后一次整体审视和调整的机会。

## 输入
- `requirement_spec_confirmed`: 已确认的需求规格文档
- `completeness_check`: 完整性检查报告

## 输出
- `feedback_result`: 反馈结果（无修改 / 有修改）

## 执行步骤

### 1. 展示需求文档摘要

展示 requirement-spec.md 的核心内容：

---
**功能清单**
- 管理端：[列出所有功能操作]
- 用户端：无 / [列出]

**接口数量**：共 X 个接口（门面层 X 个 + 应用层 X 个）

**数据表**：[表名列表]

**关键业务规则**：[简要列出]
---

### 2. 询问整体反馈

> 以上是本次需求澄清的完整输出，请整体检查：
> - 是否有遗漏的功能点？
> - 是否有理解偏差？
> - 接口设计是否合理？

### 3. 处理反馈

**如果无修改意见：**
- 直接进入 review 阶段

**如果有修改意见：**
- 更新 requirement-spec.md 对应章节
- 展示修改后的内容，获得用户确认

## 输出格式

```yaml
feedback_result:
  has_changes: false
  changes: []
  # 或
  has_changes: true
  changes:
    - section: "接口清单"
      description: "新增批量导出接口"
```
