# Motius 团队协作计划

**日期**: 2026-05-14  
**成员**: motiusrobotics (Bot/架构), Felix22r4 (开发主力)

---

## 🤝 分工

| 角色 | 负责内容 |
|------|---------|
| **motiusrobotics** | 架构设计、Profile 定义层、每日自动 commit、文档维护 |
| **Felix22r4** | 感知层开发、LeRobot Adapter、Sim 环境搭建、控制器集成 |

---

## 📋 任务池 (GitHub Issues)

### Phase 1 — 核心适配层（本周）

| # | 任务 | 负责人 | 状态 |
|---|------|--------|------|
| 1 | LeRobotProfileAdapter 完成 | Felix | 🔲 |
| 2 | UnitreeG1PoseMixin 完成 | Felix | 🔲 |
| 3 | ProfileValidator 单元测试补充 | Felix | 🔲 |
| 4 | LeRobot Adapter 集成测试 | Felix | 🔲 |
| 5 | Reference Network 数据模型完善 | motiusrobotics | 🔲 |
| 6 | Perceive → Adapt 感知层骨架 | Felix | 🔲 |

### Phase 2 — 感知层（下周）

| # | 任务 | 负责人 | 状态 |
|---|------|--------|------|
| 7 | PerceptionController 骨架 | Felix | 🔲 |
| 8 | 场景分类模型（3类：酒店/医院/公共） | Felix | 🔲 |
| 9 | Profile Predictor MVP | Felix | 🔲 |
| 10 | Camera + LiDAR 集成 | Felix | 🔲 |

### Phase 3 — Reference Network（第三周）

| # | 任务 | 负责人 | 状态 |
|---|------|--------|------|
| 11 | 视频上传 + 匿名化 pipeline | Felix | 🔲 |
| 12 | AI 辅助标注工具 | Felix | 🔲 |
| 13 | 数据集导出格式定义 | motiusrobotics | 🔲 |
| 14 | 24人数据冷启动训练 | motiusrobotics | 🔲 |

---

## 🔄 协作流程

1. **每日**: motiusrobotics 定时 commit（Profile 层改动）
2. **每日**: Felix 自主开发 commit（感知+适配层）
3. **每周一**: 同步会议（Issue 评论确认进度）
4. **每周五**: PR Review + 合并

---

## 📁 Felix 开发环境

```bash
# Clone 主项目（forked）
git clone https://github.com/Felix22r4/unitree_lerobot_motius.git
cd unitree_lerobot_motius
git remote add upstream https://github.com/motiusrobotics/unitree_lerobot_motius.git

# 添加 upstream 后
git fetch upstream
git checkout main
git merge upstream/main  # 同步 motiusrobotics 最新改动
```

---

## 📦 Felix Fork 的仓库（参考学习）

- `Felix22r4/habitat-lab` — 仿真环境
- `Felix22r4/dm_control` — 控制框架
- `Felix22r4/webots_ros` — Webots ROS 集成

---

## 📊 目标里程碑

| 日期 | 里程碑 |
|------|--------|
| 2026-05-21 | LeRobot Adapter 在 Sim 中跑通闭环 |
| 2026-05-28 | PerceptionController 骨架 + Profile Predictor MVP |
| 2026-06-04 | 视频上传 pipeline 上线 + 5 条真实数据入库 |
| 2026-06-30 | arXiv 论文提交 + 机器人真机演示视频 |
