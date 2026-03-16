# Boot Sequence

## 启动检查

### 1. 检查 RESOURCE-MAP.yml

读取 `orchestrator/ALWAYS/RESOURCE-MAP.yml`：

**如果内容为空（仅注释或不存在）：**
1. 提示用户执行初始化脚本：`./init.ps1`（Windows）或 `./init.sh`（Linux/Mac）
2. 等待用户完成初始化后重新启动

**如果内容不为空：**
继续正常启动流程

---

## 正常启动流程

### 2. 扫描 Programs

扫描 `outputs/PROGRAMS/` 目录：

**如果存在正在进行的 Program（STATUS.yml 中 status ≠ completed）：**
1. 列出所有进行中的 Program
2. 提示用户选择继续执行

**如果没有正在进行的 Program：**
1. 动态加载可用工作流（扫描 `orchestrator/WORKFLOWS/` 目录）
2. 展示工作流列表
3. 提示用户新建 Program 时需要指定基于哪个工作流

---

## 用户指定 Program 后的加载顺序

用户选择继续某个 Program 后，按以下顺序加载：

1. `orchestrator/ALWAYS/CORE.md` — 核心工作协议
2. `orchestrator/ALWAYS/DEV-FLOW.md` — 开发流程规范
3. `orchestrator/ALWAYS/RESOURCE-MAP.yml` — 资源索引
4. `outputs/PROGRAMS/{program_id}/PROGRAM.md` — 任务定义
5. `outputs/PROGRAMS/{program_id}/STATUS.yml` — 当前状态
6. `outputs/PROGRAMS/{program_id}/SCOPE.yml` — 写入范围

---

## 加载完成后输出

```
Program: {名称}
目标: {一句话}
当前阶段: {阶段名}
下一步: {具体行动}
```

---

## 特殊情况处理

- 如果 Program 目录不存在，询问用户是否创建（从 `_TEMPLATE` 复制）
- 如果存在 `workspace/CHECKPOINT.md`，优先读取恢复上下文
- 如果存在 `workspace/HANDOFF.md`，读取上次交接内容

---

## 新建 Program

### 基于工作流创建

新建 Program 必须指定基于哪个工作流：

```bash
# 1. 从工作流模板创建
workflow={workflow_name}
cp -r orchestrator/WORKFLOWS/_TEMPLATE outputs/PROGRAMS/P-YYYY-NNN-<name>

# 2. 编辑 Program 定义
echo "workflow_ref: $workflow" >> outputs/PROGRAMS/P-YYYY-NNN-<name>/PROGRAM.md
```

### 可用工作流列表

扫描 `orchestrator/WORKFLOWS/` 目录动态获取（排除 `_TEMPLATE`）：
