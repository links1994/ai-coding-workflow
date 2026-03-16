# 文档管理规范

## 1. 文档体系结构

```
docs/
├── index.yml                    # 文档索引（元数据中心）
├── output/                      # 当前生效文档
│   ├── architecture/            # 架构设计文档
│   ├── api/                     # API 文档
│   └── guides/                  # 指南文档
│
└── archive/                     # 版本归档
    └── {doc-name}/
        ├── v1.0.0-YYYYMMDD.md
        ├── v1.1.0-YYYYMMDD.md
        └── CHANGELOG.md
```

## 2. 文档生命周期

### 2.1 创建新文档

```bash
# 1. 确定文档类型和名称
doc_type="architecture"  # architecture/api/guides
doc_name="feature-name"

# 2. 创建文档文件
touch docs/output/${doc_type}/${doc_name}.md

# 3. 注册到索引
# 编辑 docs/index.yml，添加文档条目
```

### 2.2 文档索引条目格式

```yaml
documents:
  feature-name:
    type: architecture          # 文档类型
    title: "文档标题"
    description: "一句话描述"
    current: docs/output/architecture/feature-name.md
    versions:
      - version: "1.0.0"
        file: docs/archive/feature-name/v1.0.0-20260315.md
        date: "2026-03-15"
        changes: "初始版本"
    status: draft               # draft/review/stable/deprecated
    tags: [tag1, tag2]
    related_programs: [P-2026-001]
    authors: ["author-name"]
```

### 2.3 版本管理

**语义化版本规范：**

| 版本变化 | 说明 | 示例 |
|---------|------|------|
| MAJOR | 重大架构变更，不兼容修改 | 1.0.0 → 2.0.0 |
| MINOR | 功能增强，向后兼容 | 1.0.0 → 1.1.0 |
| PATCH | 错误修复，向后兼容 | 1.0.0 → 1.0.1 |

**版本发布流程：**

```bash
# 1. 当前文档归档
cp docs/output/architecture/feature-name.md \
   docs/archive/feature-name/v1.1.0-$(date +%Y%m%d).md

# 2. 更新 CHANGELOG
echo "## v1.1.0 - $(date +%Y-%m-%d)" >> docs/archive/feature-name/CHANGELOG.md

# 3. 更新索引
docs/index.yml 中添加新版本记录
```

## 3. 内容修改策略

### 3.1 修改前检查清单

- [ ] 读取现有文档内容
- [ ] 对比历史版本（如有）
- [ ] 确定修改类型（替换/追加/重构）

### 3.2 修改类型决策

| 场景 | 判断标准 | 操作策略 |
|------|----------|----------|
| **替换** | 内容重复度 > 80% | 直接替换，更新版本号 |
| **追加** | 新增独立章节 | 追加内容，PATCH 版本+1 |
| **重构** | 结构调整 | 归档旧版，新建 MAJOR 版本 |
| **废弃** | 内容过时 | 标记 deprecated，指向替代文档 |

### 3.3 避免重复追加

**检测机制：**

```yaml
# 在写入前，Agent 应执行：
1. 提取现有文档摘要
2. 计算与新内容的相似度
3. 如果相似度 > 0.8，提示用户选择：
   - 替换现有内容
   - 创建新版本
   - 取消操作
```

## 4. 与 Program 的关联

### 4.1 Program 文档输出

Program 的产出文档应注册到 docs/index.yml：

```yaml
documents:
  feature-auth:
    type: architecture
    title: "用户认证系统设计"
    related_programs: [P-2026-002]  # 关联 Program
    # ...
```

### 4.2 知识沉淀

Program 完成后，复盘经验应沉淀到 repowiki/_index.yml：

```yaml
knowledge_base:
  experiences:
    - id: exp-xxx
      title: "从 P-2026-002 提取的经验"
      source: P-2026-002
      # ...
```

## 5. 文档模板

### 5.1 架构设计文档模板

```markdown
# 标题

## 1. 概述

### 1.1 背景
### 1.2 目标
### 1.3 范围

## 2. 方案设计

### 2.1 架构图
### 2.2 关键组件
### 2.3 数据流

## 3. 决策记录

| 决策 | 选项 | 理由 |
|------|------|------|

## 4. 实施计划

## 5. 附录

- 版本历史
- 参考资料
```

## 6. 索引维护

### 6.1 定期任务

- 每月检查 `status: deprecated` 的文档，确认是否删除
- 每季度统计文档使用情况，优化标签体系
- 每年审查文档架构，调整分类

### 6.2 自动化检查

```yaml
# 建议添加的 CI 检查
- 检查 docs/index.yml 语法
- 验证所有 current 文件存在
- 检查 archive 版本完整性
- 检测重复标签
```

---

*文档版本: 1.0.0*  
*最后更新: 2026-03-15*
