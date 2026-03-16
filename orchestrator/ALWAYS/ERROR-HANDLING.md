# 全局错误处理策略

> 本文档定义 AI Coding Workflow 中所有流程的统一错误处理策略。

---

## 错误分类

### 按严重程度分类

| 级别 | 名称 | 说明 | 处理方式 |
|------|------|------|----------|
| **P0** | 阻塞错误 | 导致流程无法继续执行 | 立即暂停，等待人工干预 |
| **P1** | 严重错误 | 影响核心功能，但可降级处理 | 记录并报告，尝试降级方案 |
| **P2** | 一般错误 | 局部功能异常 | 记录并继续，汇总报告 |
| **P3** | 警告 | 非最优实践或潜在风险 | 记录日志，不中断流程 |

### 按错误类型分类

| 类型 | 说明 | 示例 |
|------|------|------|
| `validation_error` | 验证失败 | 输入格式错误、参数缺失 |
| `generation_error` | 生成失败 | 代码生成异常、模板解析失败 |
| `io_error` | IO 错误 | 文件读写失败、网络超时 |
| `dependency_error` | 依赖错误 | 依赖服务不可用、版本冲突 |
| `logic_error` | 逻辑错误 | 业务规则冲突、状态异常 |
| `resource_error` | 资源错误 | 内存不足、上下文窗口超限 |

---

## 错误处理策略

### 策略类型

| 策略 | 说明 | 适用场景 |
|------|------|----------|
| `pause_and_report` | 暂停执行并报告错误 | P0 阻塞错误 |
| `auto_retry` | 自动重试 | 网络超时等临时错误 |
| `report_and_continue` | 报告但继续执行 | P1 严重错误，有降级方案 |
| `skip_and_continue` | 跳过并继续 | 可选步骤失败 |
| `rollback_and_report` | 回滚并报告 | 事务性操作失败 |

### 重试机制

```yaml
retry_policy:
  max_retries: 3                    # 默认最大重试次数
  retry_delay: 5s                   # 默认重试间隔
  exponential_backoff: true         # 指数退避
  max_delay: 60s                    # 最大重试间隔
  
  # 特定错误类型的重试配置
  error_specific:
    - type: network_error
      max_retries: 5
      retry_delay: 2s
    - type: io_error
      max_retries: 3
      retry_delay: 1s
```

---

## Workflow 级别错误处理

### 全局配置

```yaml
error_handling:
  # 默认策略
  default_strategy: pause_and_report
  
  # 错误升级策略
  escalation:
    enabled: true
    threshold: 3                    # 连续错误次数阈值
    action: delegate_to_user        # 升级动作
  
  # 通知配置
  notification:
    on_pause: true                  # 暂停时通知
    on_complete: true               # 完成时通知（含错误汇总）
    on_escalation: true             # 升级时通知
```

### 阶段级别配置

```yaml
lifecycle:
  execute:
    enabled: true
    error_handling:
      strategy: pause_and_report
      max_retries: 3
      rollback_on_failure: true     # 失败时回滚
```

### 步骤级别配置

```yaml
steps:
  - id: generate_code
    error_handling:
      strategy: auto_retry
      max_retries: 3
      fallback_step: manual_generation  # 失败后的降级步骤
```

---

## 错误报告格式

### 标准错误报告

```yaml
error_report:
  timestamp: "2026-03-17T10:30:00+08:00"
  workflow: feature-implementation
  program: P-2026-001
  phase: execute
  step: generate_code
  
  error:
    type: generation_error
    severity: P0
    code: GEN-001
    message: "代码生成失败：模板解析异常"
    details: |
      详细错误信息...
      堆栈跟踪...
  
  context:
    inputs:
      tech_spec: "workspace/outputs/tech-spec.md"
    state: "generating_feign_interfaces"
    progress: 45%
  
  suggestions:
    - "检查 tech-spec.md 格式是否正确"
    - "确认模板文件是否存在"
    - "尝试重新生成"
  
  action_required: true
  escalation_level: 1
```

### 用户通知格式

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ 流程执行错误
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

流程: feature-implementation
程序: P-2026-001
阶段: execute - 生成代码

错误信息:
  代码生成失败：模板解析异常

可能原因:
  1. 技术规格书格式错误
  2. 模板文件缺失
  3. 字段映射不匹配

建议操作:
  [1] 检查 tech-spec.md 文件
  [2] 查看详细错误日志: workspace/errors/error-001.log
  [3] 重试当前步骤
  [4] 跳过此步骤继续

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 错误恢复机制

### 检查点（Checkpoint）

```yaml
checkpoint:
  enabled: true
  interval: 5min                  # 自动保存间隔
  on_phase_complete: true         # 阶段完成时保存
  
  restore:
    strategy: ask_user            # 恢复策略
    auto_restore: false           # 是否自动恢复
```

### 恢复流程

```
1. 检测到错误 → 保存当前状态到 CHECKPOINT.md
2. 通知用户错误信息
3. 等待用户决策：
   a. 重试（retry）- 从当前步骤重新执行
   b. 继续（continue）- 跳过当前步骤继续
   c. 回滚（rollback）- 回退到上一检查点
   d. 终止（abort）- 终止流程，保存 HANDOFF.md
4. 执行用户选择的操作
```

---

## 特定场景处理

### 上下文窗口超限

```yaml
resource_error:
  type: context_window_exceeded
  strategy: compress_and_continue
  actions:
    - compress_history             # 压缩历史消息
    - save_checkpoint              # 保存检查点
    - summarize_context            # 生成上下文摘要
```

### 代码生成失败

```yaml
generation_error:
  type: code_generation_failed
  strategy: report_and_continue
  fallback:
    - use_simplified_template      # 使用简化模板
    - generate_partial_code        # 生成部分代码
    - mark_for_manual_review       # 标记人工审查
```

### 依赖服务不可用

```yaml
dependency_error:
  type: service_unavailable
  strategy: auto_retry
  max_retries: 5
  retry_delay: 10s
  fallback: skip_optional_steps   # 跳过可选步骤
```

---

## 错误日志规范

### 日志级别

| 级别 | 用途 | 输出位置 |
|------|------|----------|
| `ERROR` | 错误信息 | workspace/errors/ |
| `WARN` | 警告信息 | workspace/logs/ |
| `INFO` | 一般信息 | workspace/logs/ |
| `DEBUG` | 调试信息 | workspace/logs/（调试模式） |

### 日志文件命名

```
workspace/
├── errors/
│   └── error-{timestamp}-{program_id}.log
├── logs/
│   ├── workflow-{date}.log
│   └── debug-{date}.log
└── checkpoints/
    └── checkpoint-{timestamp}.md
```

### 日志格式

```
[2026-03-17 10:30:00] [ERROR] [feature-implementation] [execute:generate_code]
错误类型: generation_error
错误代码: GEN-001
错误信息: 模板解析异常

上下文:
  - tech_spec: workspace/outputs/tech-spec.md
  - template: _TEMPLATE/controller-admin.md
  - line: 45

堆栈跟踪:
  at ...
```

---

## 最佳实践

### 设计阶段

1. **预判错误场景**：设计流程时识别可能的错误点
2. **定义降级方案**：为核心步骤准备备选方案
3. **设置合理超时**：避免无限等待

### 执行阶段

1. **及时保存状态**：关键节点保存检查点
2. **清晰错误信息**：错误信息应包含上下文和解决建议
3. **避免级联失败**：隔离错误，防止扩散

### 恢复阶段

1. **提供明确选项**：让用户清楚知道可以做什么
2. **保留完整上下文**：便于问题诊断
3. **记录恢复过程**：用于后续优化

---

## 相关文档

- **Workflow 设计指南**: `repowiki/guides/workflow-creation-guide.md`
- **核心工作协议**: `orchestrator/ALWAYS/CORE.md`
- **Sub-Agent 规范**: `orchestrator/ALWAYS/SUB-AGENT.md`
