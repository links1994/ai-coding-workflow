---
name: env-check
description: 检查测试环境就绪状态，验证 Nacos 可连通、目标服务健康。在 http-api-testing 流程 research 阶段、执行测试前使用。支持 local/dev/test 多环境，从 RESOURCE-MAP.yml 读取配置。
version: 1.0.0
---

# 环境检查 Skill

验证 Nacos 连通性与目标服务健康状态，输出结构化检查报告。

---

## 触发条件

- 进入 `http-api-testing` 流程的 `research` 阶段
- 用户指令："检查环境"、"检测服务"、"重新检测"
- 执行自动化测试前的前置验证

---

## 环境配置来源

从 `orchestrator/ALWAYS/RESOURCE-MAP.yml` 的 `environments` 节点读取：

```
environments:
  local:   # 本地环境（默认）
  dev:     # 开发联调环境
  test:    # 测试环境
```

**默认使用 `local` 环境**，用户可通过指令切换，如 "使用 dev 环境"。

---

## 执行步骤

### Step 1：生成检查脚本

基于目标环境配置，生成 `check_services.py` 到工作区临时目录，执行后删除。

脚本模板见 [scripts/check_services_template.py](scripts/check_services_template.py)。

### Step 2：执行脚本

```bash
python check_services.py
```

> **Windows 注意**：必须将脚本写入文件后执行，禁止使用多行 `python -c` 方式。

### Step 3：解析结果

检查输出中每个服务状态：
- `UP` → 健康
- `DOWN` → 未启动或连接拒绝

### Step 4：输出结果

以结构化表格展示，并给出下一步建议：
- 全部 UP → "环境就绪，可以开始测试"
- 部分 DOWN → 列出未就绪服务，等待用户处理后重新检测

---

## 输出格式

```
环境检查结果（{env_name} 环境）：

| 检查项                         | 状态 | 地址                          |
|-------------------------------|------|-------------------------------|
| Nacos                         | ✅   | http://192.168.110.101:8848   |
| mall-agent-employee-service   | ✅   | 192.168.110.101:8094          |
| mall-admin                    | ✅   | 192.168.110.101:8979          |
| mall-toc-service              | ✅   | 192.168.110.101:9201          |

>>> 所有服务就绪，可以开始测试！
```

---

## 相关资源

- 环境配置：`orchestrator/ALWAYS/RESOURCE-MAP.yml`
- 检查脚本模板：`scripts/check_services_template.py`
- 调用方：`http-api-testing` workflow `research` 阶段 `check_environment_prerequisites` 步骤
