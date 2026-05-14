# 🤖 Motius Robotics

> **AI-Adaptive Behavior Layer for Service Robots**
> Same robot. Different feel for everyone.

[![GitHub stars](https://img.shields.io/github/stars/motiusrobotics/unitree_lerobot_motius?style=flat&logo=github)](https://github.com/motiusrobotics/unitree_lerobot_motius)
[![arXiv](https://img.shields.io/badge/arXiv-2026-orange?style=flat&logo=arxiv)](https://arxiv.org)
[![Unitree G1](https://img.shields.io/badge/Platform-Unitree%20G1-blue?style=flat&logo=robotics)](https://github.com/unitreerobotics/unitree_lerobot)
[![License](https://img.shields.io/badge/License-Apache%202.0-green?style=flat&logo=apache)](LICENSE)

---

## 🎯 What Is Motius?

Motius Robotics builds an **AI-adaptive behavior layer** that sits above the robot controller — translating learned interaction patterns into runtime-safe motion parameters in real time.

Service robots already move through hotels, lobbies, and public environments. What has been missing is a behavior layer that **adapts instead of being rebuilt** property by property. The same robot feels different in every deployment — not because of the hardware, but because nobody built a data-driven way to make behavior **transferable and adaptive**.

> The more the layer runs, the smarter it gets. Community reference data is the long-term moat.

---

## 🔬 Current Proof

| Metric | Value |
|--------|-------|
| **Platform** | Unitree G1 humanoid robot |
| **Visible tasks** | Handover · Approach · Push |
| **Human raters** | Real clip-based study participants |
| **Adaptive fields** | Speed · Pause · Distance · Smoothing |
| **Gentle preference** | 92–96% across tasks |

---

## 🧩 How It Works

```
┌──────────────────────────────────────────────────────┐
│  1. PERCEIVE                                          │
│  User type + Scene + Interaction cues                 │
└──────────────────────┬───────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────┐
│  2. ADAPT                                             │
│  Speed, pause, distance shift at runtime              │
│  Same robot · Same task · Different feel              │
└──────────────────────┬───────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────┐
│  3. VALIDATE                                         │
│  Cross-task proof + human preference ratings           │
└──────────────────────┬───────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────┐
│  4. DEPLOY                                            │
│  Adapter → Controller boundary (safety preserved)      │
└──────────────────────────────────────────────────────┘
```

---

## 🌍 Data Flywheel

```
Contributors upload clips
        ▼
Reference Network structures data
        ▼
Adaptive models improve
        ▼
Robots behave better
        ▼
More deployments → more data → smarter layer
```

---

## 📦 Interaction Profiles

Profiles are **learned behavior bands**, not frozen numbers.

| Profile | Character | Speed | Pause | Distance | Smoothing |
|---------|-----------|-------|-------|----------|-----------|
| **Standard** | Neutral · Direct · Efficient | 1.00 | 200ms | 0.80m | 0.90 |
| **Gentle** | Warm · Patient · Soft | 0.82 | 420ms | 0.95m | 0.96 |
| **Attentive** | Alert · Polished · Social | 0.92 | 300ms | 0.88m | 0.94 |

### What "Adaptive" Means in Practice

> **Same Gentle profile — different parameters for different people**

| User | Speed | Pause | Distance |
|------|-------|-------|----------|
| Elder approaches | 0.65 | 650ms | 1.10m |
| Child runs nearby | 0.50 | 800ms | 1.25m |
| Business user | 0.90 | 250ms | 0.82m |

---

## 🚀 Quick Start

```bash
# Clone the scaffold
git clone https://github.com/motiusrobotics/unitree_lerobot_motius.git
cd unitree_lerobot_motius
pip install -e .

# Load a profile
python -c "
from unitree_lerobot import get_profile, profile_to_runtime_adapter

profile = get_profile('gentle')
runtime = profile_to_runtime_adapter(profile, task='handover')
print(runtime)
"
```

---

## 📁 Repository Structure

```
unitree_lerobot_motius/
├── unitree_lerobot/
│   ├── motius_profiles.py     # Profile definitions + Runtime Adapter
│   └── motius_schema.py        # Reference Network data models
├── examples/motius/            # JSON examples of runtime output
├── test/                       # Unit tests
└── README.md
```

---

## 📄 Paper

> **"Motius: Interaction Profiles as a Behavior Layer for Human-Facing Robot Control"**  
> *Human–Robot Interaction 2026*  
> 🔗 [arXivcoming] · [GitHub](https://github.com/motiusrobotics/unitree_lerobot_motius)

---

## 🤝 Participate

### 🗂 Upload Reference Clips
Contributors upload short service interaction videos, attach behavior tags, and feed the Reference Network that trains and validates adaptive robot behavior.

### 🚀 Pilot Program
Operators can reserve an early deployment path for adaptive behavior tuning, validation, and runtime integration.

---

## 🔗 Links

- 🌐 [motiusrobotics.com](https://www.motiusrobotics.com/)
- 📄 [Paper (arXiv)](https://arxiv.org)
- 🤖 [Unitree LeRobot](https://github.com/unitreerobotics/unitree_lerobot)
- 🧠 [LeRobot (HuggingFace)](https://github.com/huggingface/lerobot)

---

## 📄 License

Apache 2.0 — free to use, modify, and distribute.
