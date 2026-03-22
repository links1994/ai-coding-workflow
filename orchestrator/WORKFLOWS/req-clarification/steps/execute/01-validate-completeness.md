# Step: 验证需求文档完整性

## 目的
验证 requirement-spec.md 是否包含了 feature-implementation 所需的全部信息，确保文档可直接驱动后续实现。

## 输入
- `requirement_spec_confirmed`: 已确认的需求规格文档

## 输出
- `completeness_check`: 完整性检查报告

## 执行步骤

### 1. 逐项检查必备内容

对照以下清单检查 requirement-spec.md：

**业务信息（必须）**
- [ ] 业务目标已描述（解决什么问题）
- [ ] 用户角色已明确（管理员/商家/买家）
- [ ] 典型使用场景已描述

**接口信息（必须）**
- [ ] 门面层接口清单完整（方法 + 路径 + 描述）
- [ ] 应用层内部接口清单完整（/inner/api/v1/）
- [ ] 每个接口的入参/出参字段已说明

**数据模型（必须）**
- [ ] 涉及的表名已确定（aim_{module}_{name} 格式）
- [ ] 核心字段已列出（包含类型和说明）
- [ ] 关联关系已说明

**业务规则（必须）**
- [ ] 创建/更新/删除的校验规则已说明
- [ ] 状态流转已说明（如有）
- [ ] 权限规则已说明（如有）

**服务范围（必须）**
- [ ] 涉及的服务已列出（facade/application/inner-api）
- [ ] 是否新建服务还是扩展现有服务已明确

### 2. 识别缺失项

若发现缺失项，按严重程度分类：

**阻塞项**（必须补充，否则无法实现）：
- 接口路径未定义
- 数据表字段不清楚
- 关键业务规则缺失

**警告项**（建议补充，可在实现时确认）：
- 某些边界场景未说明
- 部分字段格式未约束

### 3. 输出检查报告

```yaml
completeness_check:
  passed: true
  blocking_issues: []
  warnings:
    - "消息内容字段最大长度未说明"
  checklist:
    business_info: true
    interface_list: true
    data_model: true
    business_rules: true
    service_scope: true
```

## 处理阻塞项

若存在阻塞项，**不进入 feedback 阶段**，直接返回 decision 阶段补充澄清：
1. 列出所有阻塞项
2. 向用户追问缺失信息
3. 更新 requirement-spec.md
4. 重新执行本步骤验证
