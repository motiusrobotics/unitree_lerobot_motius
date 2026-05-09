# 🤖 Motius — Behavior Layer for Human-Facing Robot Control

**`unitree_lerobot_motius`** is a lightweight behavior-layer scaffold that packages robot interaction style into reusable, inspectable **interaction profiles** — sitting above the motion controller as an explicit software surface rather than scattered runtime parameters.

Built on top of [unitree_lerobot](https://github.com/unitreerobotics/unitree_lerobot) and validated on a **Unitree G1** humanoid platform.

---

## ✨ What Problem It Solves

Robot behavior in human-facing tasks is often "tuned" into hidden parameters, scene-local scripts, and operator intuition. This makes behavior:

- **Hard to inspect** — you can't see what profile a robot is running
- **Hard to transfer** — settings don't travel across robots or sites
- **Hard to compare** — no version history, no baseline

Motius proposes a **behavior layer**: a reusable profile surface that resolves into explicit execution fields (speed scaling, pause timing, stopping distance, end-effector smoothing) while preserving controller ownership.

---

## 📦 What's Included

### Core Library — `unitree_lerobot.motius_profiles`

```python
from unitree_lerobot import get_motius_profile

# Load a profile
profile = get_motius_profile("gentle")

# Inspect the fields that drive runtime behavior
print(profile.speed_scale)       # 0.82
print(profile.pause_duration_s)  # 1.05
print(profile.stopping_distance_m)  # 0.90
print(profile.ee_smoothing)      # 0.85
```

### Interaction Profiles

| Profile | Character | speed_scale | pause_duration_s | stopping_distance_m | ee_smoothing |
|---------|-----------|-------------|------------------|--------------------|--------------|
| `standard` | Baseline runtime feel | 1.00 | 0.50 | 0.75 | 0.80 |
| `gentle` | Slower, calmer, more pause | 0.82 | 1.05 | 0.90 | 0.85 |
| `attentive` | Alert, quick response | 1.10 | 0.35 | 0.65 | 0.75 |

### Schema — `unitree_lerobot.motius_schema`

Minimal data models for:
- `InteractionProfile` — profile definition with execution fields
- `ReferenceClip` — a short human behavior reference clip record
- `DatasetEntry` — profile-conditioned dataset entry with attached reference clip

---

## 🚀 Quick Start

### 1. Install

```bash
cd unitree_lerobot_motius
pip install -e .
```

### 2. Use a Profile in Runtime

```python
from unitree_lerobot import get_motius_profile

profile = get_motius_profile("gentle")

# Map profile fields into your runtime adapter
runtime_config = {
    "speed_scale": profile.speed_scale,
    "pause_duration_s": profile.pause_duration_s,
    "stopping_distance_m": profile.stopping_distance_m,
    "ee_smoothing": profile.ee_smoothing,
}

# Apply to robot controller / motion planner
apply_to_controller(runtime_config)
```

See `examples/motius/gentle_profile_runtime.json` for the full adapter output example.

### 3. Attach a Reference Clip to a Dataset Entry

```python
from unitree_lerobot.motius_schema import DatasetEntry, ReferenceClip

clip = ReferenceClip(
    clip_id="handover_ref_001",
    interaction_type="handover",
    profile_id="gentle",
    duration_s=12.4,
    human_label="natural",
)

entry = DatasetEntry(
    episode_id="epi_001",
    profile_id="gentle",
    reference_clip=clip,
)

print(entry.model_dump_json(indent=2))
```

---

## 📁 Repository Structure

```
unitree_lerobot_motius/
├── unitree_lerobot/
│   ├── __init__.py              # Public exports: get_motius_profile
│   ├── motius_profiles.py      # Profile definitions & field values
│   └── motius_schema.py        # Pydantic schemas: Profile, ReferenceClip, DatasetEntry
├── examples/motius/
│   ├── README.md                # This file
│   ├── gentle_profile_runtime.json      # Runtime adapter output example
│   ├── reference_clip_example.json      # Human reference clip record example
│   └── dataset_entry_example.json       # Profile-conditioned dataset entry example
└── test/
    └── test_motius_profiles.py  # Profile unit tests
```

---

## 📄 Paper

This scaffold corresponds to the Motius prototype described in:

> **"Motius: Interaction Profiles as a Behavior Layer for Human-Facing Robot Control"**
> *Human–Robot Interaction 2026*
> 🔗 [motiusrobotics/unitree_lerobot_motius](https://github.com/motiusrobotics/unitree_lerobot_motius)

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
