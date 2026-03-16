# Feature 实现报告: F-006 智能员工申请与审核

> Feature ID: F-006
> 生成时间: 2026-03-11

## 1. 服务分层分析

| 服务名称 | 分层 | 生成内容 |
|----------|------|----------|
| mall-admin | facade | EmployeeAuditAdminController（5接口） |
| mall-toc-service | facade | AiEmployeeAppController（4接口） |
| mall-agent-employee-service | application | AiEmployeeInnerController（8接口） |

## 2. 关键设计决策

| 决策点 | 选择 | 理由 |
|--------|------|------|
| 校验顺序 | 名额→商品→重复申请 | 避免无效操作 |
| 客服岗免商品校验 | jobType.code=客服岗时跳过 | 客服岗无需绑定商品 |
| 名额扣减事务 | 同一 @Transactional | 保证原子性 |
| 免邀请激活 | skipActivation=true | 灵活控制流程 |

## 3. 验收标准验证

| 验收标准 | 状态 |
|----------|------|
| 用户提交申请 | ✅ 完成 |
| 运营审核通过/驳回 | ✅ 完成 |
| 名额校验与扣减 | ✅ 完成 |
| 商品代理校验 | ✅ 完成 |
| 员工编号生成 | ✅ 完成 |
| 重新申请 | ✅ 完成 |
| 免邀请激活 | ✅ 完成 |

---

*报告生成时间: 2026-03-11*
