# Motius Robotics — Dual-Bot 每日自动开发计划

> **最后更新**：2026-05-17

---

## 成员

| Bot | GitHub | 运行时间 | 专注领域 |
|-----|--------|----------|----------|
| **OpenClaw** | @openclaw-ai | 09:00 北京时间 | LeRobot 适配层、Profile 系统、Schema |
| **Felix** | @Felix22r4 | 10:00 北京时间 | ROS2 硬件接口、Motion Planner、Sensor Fusion、Nav2 |

---

## 分支策略

```
main          ← 受保护，仅通过 PR 合并
  └── dev     ← 集成分支
        ├── feature/openclaw-*   ← OpenClaw Bot 贡献
        └── feature/felix-*     ← Felix Bot 贡献
```

- 所有变更通过 PR 合并到 `dev`
- `main` 禁止直接 push
- 两个 Bot 在不同时间运行，互不干扰

---

## 每日任务轮转

### OpenClaw（7天一循环，09:00 北京时间）

| Day | 任务 | 内容 |
|-----|------|------|
| 0 | LeRobotProfileAdapter 核心类 | 核心类开发 |
| 1 | ProfileValidator 边界检查 | 边界检查 |
| 2 | UnitreeG1PoseMixin | 身体姿势扩展 |
| 3 | 新增 guide task type | Schema 扩展 |
| 4 | LeRobot Adapter 集成测试 | 测试 |
| 5 | README 架构图扩展 | 文档 |
| 6 | __init__.py API 导出更新 | API 导出 |

### Felix（7天一循环，10:00 北京时间）

| Day | 任务 | 内容 |
|-----|------|------|
| 0 | ROS2 Hardware Interface | Unitree G1 ros2_control 节点 |
| 1 | Motion Planner Bridge | 轨迹生成 |
| 2 | Camera/LiDAR Sensor Fusion | 传感器融合 |
| 3 | Navigation Stack Integration | Nav2 桥接 |
| 4 | End-to-End Integration Tests | 全链路测试 |
| 5 | API Usage Examples | 使用教程 |
| 6 | CI/CD Pipeline | GitHub Actions |

---

## 模块结构

```
unitree_lerobot/
├── __init__.py                    # API 导出
├── motius_schema.py               # Schema 定义
├── motius_profiles.py             # Profile 运行时
├── profile_validator.py           # 边界检查（OpenClaw）
├── lerobot_adapter.py             # LeRobot 适配器（OpenClaw）
├── ros2_hardware_interface.py     # ROS2 硬件接口（Felix）
├── motion_planner.py              # 运动规划（Felix）
├── sensor_fusion.py               # 传感器融合（Felix）
└── nav_integration.py             # Nav2 集成（Felix）
```

---

## 仓库

- **仓库**：`https://github.com/motiusrobotics/unitree_lerobot_motius`
- **协作文档**：`.github/TEAM_PLAN.md`
- **OpenClaw 脚本**：`/root/unitree_lerobot_motius/.github/scripts/daily_dev.sh`
- **Felix 脚本**：`/root/unitree_lerobot_felix/felix_daily_dev.sh`
