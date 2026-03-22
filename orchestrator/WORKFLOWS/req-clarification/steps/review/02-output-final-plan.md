# Step: 输出最终方案

## 目的
完成所有验证后，向用户展示本次需求澄清的最终产物，并给出直接进入 feature-implementation 的指引。

## 输入
- `requirement_spec_confirmed`: 已确认的需求规格文档
- `coverage_check`: 覆盖度检查报告

## 输出
- 流程完成，产物归档

## 执行步骤

### 1. 最终产物确认

展示本次需求澄清的产出：

---
## 需求澄清完成

**产出文档**

| 产物 | 路径 | 说明 |
|------|------|------|
| 需求规格文档 | workspace/outputs/requirement-spec.md | feature-implementation 的唯一输入源 |

**文档摘要**
- 功能：[列出主要功能操作]
- 接口：共 X 个（门面层 X 个 + 应用层 X 个）
- 数据表：[表名]
- 服务范围：[涉及的服务]
---

### 2. 指引进入 feature-implementation

> 需求澄清已完成。直接开始实现：
> ```
> 继续 feature-implementation，需求文档：workspace/outputs/requirement-spec.md
> ```
>
> feature-implementation 会读取需求文档，通过多个步骤完成全部功能实现。若功能较复杂，实现阶段会自动拆分为多个步骤依次完成。

## 完成标志

本步骤执行完毕后，req-clarification 流程正式结束。
Program 状态更新为 `req-clarification 完成`。
