# 🤖 Motius — Behavior Layer for Human-Facing Robot Control

**`unitree_lerobot_motius`** is a lightweight behavior-layer scaffold that packages robot interaction style into reusable, inspectable **interaction profiles** — sitting above the motion controller as an explicit software surface rather than scattered runtime parameters.

Built on top of [unitree_lerobot](https://github.com/unitreerobotics/unitree_lerobot) and validated on a **Unitree G1** humanoid platform.

---

## ✨ What Problem It Solves

Robot behavior in human-facing tasks is often "tuned" into hidden parameters, scene-local scripts, and operator intuition. This makes behavior:

- **Hard to inspect** — you can't see what profile a robot is running
- **Hard to transfer** — settings don't travel across robots or sites
- **Hard to compare** — no version history, no baseline

Motius proposes a **behavior layer**: a reusable profile surface that resolves into explicit execution fields while preserving controller ownership.

---

## 📦 What's Included

### Core Library — `unitree_lerobot.motius_profiles`

```python
from unitree_lerobot import get_profile

# Load a profile
profile = get_profile("gentle")

# Inspect the fields that drive runtime behavior
print(profile.speed_scale)           # 0.82
print(profile.pause_ms)             # 420
print(profile.approach_distance_m)  # 0.95
print(profile.ee_smoothing)         # 0.96
```

### Interaction Profiles

| Profile | Character | speed_scale | pause_ms | approach_distance_m | ee_smoothing | hold_ms | finish_softness |
|---------|-----------|-------------|----------|--------------------|--------------|---------|----------------|
| `standard` | Baseline runtime feel | 1.00 | 200 | 0.80 | 0.90 | 350 | 0.30 |
| `gentle` | Slower, calmer, more pause | 0.82 | 420 | 0.95 | 0.96 | 620 | 0.72 |
| `attentive` | Alert, quick response | 0.92 | 300 | 0.88 | 0.94 | 420 | 0.55 |

### Schema — `unitree_lerobot.motius_schema`

Minimal data models for:
- `TaskContext` — task + scene type with enum validation
- `HumanReferenceClip` — a short human behavior reference clip record
- `BehaviorDatasetEntry` — profile-conditioned dataset entry with attached reference clip

Supported `task_type` values: `handover`, `approach_stop`, `wait_behavior`, `corridor_etiquette`, `push_object`

---

## 🚀 Quick Start

### 1. Install

```bash
git clone https://github.com/motiusrobotics/unitree_lerobot_motius.git
cd unitree_lerobot_motius
pip install -e .
```

### 2. Use a Profile in Runtime

```python
from unitree_lerobot import get_profile, profile_to_runtime_adapter

profile = get_profile("gentle")

# Map profile fields into a runtime-facing adapter surface
runtime = profile_to_runtime_adapter(profile, task="handover")
# runtime is a dict with keys: profile, profile_id, task,
#   runtime_adapter{locomotion, arrival, handover, arm}, tags
```

### 3. Attach a Reference Clip to a Dataset Entry

```python
from unitree_lerobot import HumanReferenceClip, BehaviorDatasetEntry, TaskContext

clip = HumanReferenceClip(
    clip_id="handover_ref_001",
    relative_path="references/handover_ref_001.mp4",
    clip_duration_s=12.4,
    context=TaskContext(task_type="handover", scene_type="hotel"),
    behavior_tags=("warm", "patient", "soft"),
)

entry = BehaviorDatasetEntry(
    entry_id="epi_001",
    robot_type="Unitree_G1",
    active_profile="gentle",
    reference_clip=clip,
)

print(entry.dataset_key)
# → Unitree_G1:gentle:handover:epi_001
```

---

## 📁 Repository Structure

```
unitree_lerobot_motius/
├── .github/workflows/test.yml    # CI: pytest + ruff
├── README.md
├── unitree_lerobot/
│   ├── __init__.py               # Public exports
│   ├── motius_profiles.py        # Profile definitions & field values
│   └── motius_schema.py          # Pydantic-like dataclass schemas
├── examples/motius/
│   ├── gentle_profile_runtime.json
│   ├── reference_clip_example.json
│   └── dataset_entry_example.json
└── test/
    └── test_motius_profiles.py   # Profile + schema unit tests
```

---

## 📄 Paper

This scaffold corresponds to the Motius prototype described in:

> **"Motius: Interaction Profiles as a Behavior Layer for Human-Facing Robot Control"**
> *Human–Robot Interaction 2026*
> 🔗 [github.com/motiusrobotics/unitree_lerobot_motius](https://github.com/motiusrobotics/unitree_lerobot_motius)

Key numbers from the paper (Standard vs. Gentle on Unitree G1):

| Metric | Delta |
|--------|-------|
| Speed scale | −18.0% |
| Pause duration | +110.0% |
| Stopping distance | +18.7% |
| End-effector smoothing | +6.7% |
| Human preference (Gentle) | 92–96% across tasks |

---

## 🙏 Acknowledgement

This scaffold builds on:

- [unitreerobotics/unitree_lerobot](https://github.com/unitreerobotics/unitree_lerobot) — LeRobot-based training framework for Unitree robots
- [huggingface/lerobot](https://github.com/huggingface/lerobot) — Open-source robot learning framework

---

## 📄 License

Apache 2.0
