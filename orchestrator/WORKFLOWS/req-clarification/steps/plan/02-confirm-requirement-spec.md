# Step: 确认需求文档

## 目的
将生成的需求文档展示给用户确认，确保文档准确反映澄清结果，无误后作为可信源锁定。

## 输入
- `requirement_spec`: 需求规格文档草稿

## 输出
- `requirement_spec_confirmed`: 已确认的需求规格文档

## 执行步骤

### 1. 展示文档摘要

以结构化方式展示文档的核心内容，便于用户快速核对：

**功能清单是否完整？**
- 管理端：[列出已包含的功能]
- 用户端：[列出已包含的功能 / 无]

**接口清单是否正确？**
- 展示接口列表（方法 + 路径 + 描述）

**数据模型是否准确？**
- 展示表名、核心字段

**Feature 拆分是否合理？**
- 展示 Feature 列表和依赖关系

### 2. 询问用户确认

> 需求文档已生成，请确认以下内容：
> - 功能清单是否完整？是否有遗漏的操作？
> - 接口路径命名是否符合预期？
> - 数据字段是否准确？是否有遗漏的字段？
> - Feature 拆分粒度是否合适？

### 3. 处理修改意见

**如果用户提出修改：**
1. 记录修改点
2. 更新 requirement-spec.md（使用 search_replace 工具）
3. 展示修改后的内容
4. 再次确认

**如果用户确认无误：**
- 将 requirement-spec.md 标记为已确认，进入 execute 阶段

## 输出格式

```yaml
requirement_spec_confirmed: true
requirement_spec_path: "workspace/outputs/requirement-spec.md"
confirmed_at: "{timestamp}"
```

## 注意事项

- 确认后的 requirement-spec.md 是后续所有 feature-implementation 的**唯一输入源**
- 若用户确认后又提出修改，需同步更新文档并重新确认
- 文档路径固定为 `workspace/outputs/requirement-spec.md`，不得更改
