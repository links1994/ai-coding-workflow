# Step: 收集用户反馈

## 目的
收集用户对拆分结果的反馈。

## 输入
- `decomposition_report`: 拆分报告

## 输出
- `user_feedback`: 用户反馈

## 反馈内容

### 1. 需求调整

- 需求遗漏
- 需求拆分不当
- 需求优先级调整

### 2. 依赖调整

- 依赖关系错误
- 遗漏依赖
- 依赖强度调整

### 3. 批次调整

- 批次划分不合理
- 时间安排调整

## 反馈格式

```yaml
user_feedback:
  adjustments:
    - type: "add_requirement"
      description: "需要添加{Name}导入功能"
    - type: "modify_dependency"
      source: "F002"
      target: "F001"
      new_type: "weak"
```
