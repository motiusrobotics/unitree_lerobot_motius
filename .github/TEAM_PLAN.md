# Motius Robotics 开发协作规范

> **最后更新**：2026-05-17  
> **成员**：OpenClaw Bot、Felix（GitHub: Felix22r4）

---

## 1. 仓库与分支策略

```
main          ← 受保护分支，仅通过 PR 合并
  └── dev     ← 集成分支，功能完成后合并至此
        ├── feature/felix-xxx   ← Felix 开发分支
        └── feature/auto-xxx   ← OpenClaw 每日自动任务
```

**规则**：
- `main` 禁止直接 push，所有变更走 PR
- `dev` 为默认开发分支
- Feature branch 从 `dev` checkout，PR 也 merge 到 `dev`
- `dev` 稳定后合并入 `main`（每周或每两周一次）

---

## 2. 成员分工

### OpenClaw（自动化）
- 每日北京时间 09:00 自动 commit（cron: `0 1 * * *`）
- 任务轮转（7天一循环）
- Code review PRs
- 维护 CI/CD pipeline

### Felix
- 手动开发功能模块
- 从 `dev` checkout 分支，开发完成后提 PR
- 响应 review 意见

---

## 3. 当前模块结构

```
unitree_lerobot/
├── __init__.py              # API 导出
├── motius_schema.py         # 数据 schema 定义
├── motius_profiles.py       # 场景 profile 运行时
├── profile_validator.py     # 边界检查（OpenClaw Task 1）
├── lerobot/
│   └── adapter.py           # LeRobot 适配器（待开发）
examples/
├── motius/
│   ├── dataset_entry_example.json
│   ├── gentle_profile_runtime.json
│   └── hospitality_profile_runtime.json
test/
├── test_motius_profiles.py
└── test_lerobot_adapter.py
```

---

## 4. Felix 开发任务分配

| 模块 | 文件 | 优先级 | 状态 |
|------|------|--------|------|
| LeRobot 适配器核心 | `lerobot/adapter.py` | P0 | 待认领 |
| 动作序列播放器 | `lerobot/player.py` | P1 | 待认领 |
| 单元测试补全 | `test/test_lerobot_adapter.py` | P1 | 待补全 |
| README API 文档 | `README.md` | P2 | 待补充 |

**建议 Felix 从 P0 开始**：`lerobot/adapter.py` 实现 LeRobotProfileAdapter 类，参考 `motius_profiles.py` 中的 schema。

---

## 5. Felix 本地开发配置

### 添加 remote（推送用）
```bash
git remote set-url origin https://Felix22r4:<FELIX_GITHUB_TOKEN>@github.com/motiusrobotics/unitree_lerobot_motius.git
```

### 开发流程
```bash
# 1. 克隆仓库（如尚未克隆）
git clone https://github.com/motiusrobotics/unitree_lerobot_motius.git
cd unitree_lerobot_motius

# 2. 从 dev 创建功能分支
git checkout dev
git checkout -b feature/felix-lerobot-adapter

# 3. 开发、commit
git add .
git commit -m "feat(lerobot): initial LeRobotProfileAdapter draft"

# 4. 推送分支
git push -u origin feature/felix-lerobot-adapter

# 5. 在 GitHub 提 PR 到 dev 分支
```

### GitHub Token
- **GitHub**：`https://github.com/Felix22r4`
- **Token**：`<FELIX_GITHUB_TOKEN>`（请用你的真实 token 替换）

---

## 6. PR 流程

```
Felix: 创建 PR → OpenClaw: 自动 review → 合并到 dev
```

PR 模板：
```markdown
## 实现内容
...

## 测试情况
...

## 关联任务
Closes #...
```

---

## 7. 当前每日自动任务（OpenClaw）

任务轮转（7天一循环，北京时间 09:00）：

| Day | Task | 内容 |
|-----|------|------|
| 0 | LeRobotProfileAdapter 核心类 | 核心类开发 |
| 1 | ProfileValidator 边界检查 | 边界检查 |
| 2 | UnitreeG1PoseMixin | 身体姿势扩展 |
| 3 | 新增 guide task type | Schema 扩展 |
| 4 | LeRobot Adapter 集成测试 | 测试 |
| 5 | README 架构图扩展 | 文档 |
| 6 | __init__.py API 导出更新 | API 导出 |

---

## 8. 仓库信息

- **协作文档**：`https://github.com/motiusrobotics/unitree_lerobot_motius/blob/dev/.github/TEAM_PLAN.md`
- **仓库**：`https://github.com/motiusrobotics/unitree_lerobot_motius`
- **开发脚本**：`/root/unitree_lerobot_motius/.github/scripts/daily_dev.sh`
