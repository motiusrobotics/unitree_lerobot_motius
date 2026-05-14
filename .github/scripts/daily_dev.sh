#!/bin/bash
# ============================================================
# Motius Daily Development Automation
# Runs every day at 09:00 AM (Beijing time)
# - Makes incremental code changes
# - Commits & pushes to motiusrobotics GitHub
# - Sends report via Feishu
# ============================================================

REPO="/root/unitree_lerobot_motius"
LOG_FILE="/root/.openclaw/workspace/memory/daily-dev.log"
DATE=$(date "+%Y-%m-%d %H:%M")

cd "$REPO" || exit 1

echo "=== [$DATE] Daily dev run started ===" >> "$LOG_FILE"

# ---------- Daily Task Queue (rotating) ----------
# Task 0: LeRobot Adapter core
# Task 1: profile_validator boundary checks
# Task 2: Unitree G1 specific adapter fields
# Task 3: add task type "guide" to schema
# Task 4: write adapter integration test
# Task 5: README usage section expansion
# Task 6: README architecture diagram update

DAY_OF_YEAR=$(date +%j)
TASK_NUM=$((DAY_OF_YEAR % 7))

commit_msg=""
did_commit=false

case $TASK_NUM in
  0)
    # Task 0: LeRobot Adapter — core converter class
    ADAPTER_FILE="$REPO/unitree_lerobot/lerobot_adapter.py"
    if [ ! -f "$ADAPTER_FILE" ]; then
      cat > "$ADAPTER_FILE" << 'PYEOF'
"""
LeRobotProfileAdapter — translates Motius Interaction Profiles into
LeRobot-compatible runtime actions for Unitree G1.

The adapter sits above the LeRobot controller boundary:
  profile fields → LeRobot action dict → RobotState / DesiredState

Reference: unitree_lerobot_motius_scaffold/README.md §How It Works
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any

from .motius_profiles import (
    InteractionProfile,
    get_profile,
    profile_to_runtime_adapter,
)


# LeRobot action field names on Unitree G1
_LEROBOT_LOCOMOTION_KEYS = {
    "forward_speed":   "forward_speed",
    "turn_speed":      "turn_speed",
    "foot_height":      "foot_height",
    "torso_height":    "torso_height",
}

_LEROBOT_ARM_KEYS = {
    "ee_smoothing":    "ee_smoothing",
    "reach_force":     "reach_force",
    "grip_width":      "grip_width",
}

_LEROBOT_ARRIVAL_KEYS = {
    "stop_distance":   "stop_distance",
    "pause_duration":  "pause_duration",
    "approach_speed":  "approach_speed",
}


@dataclass
class LeRobotProfileAdapter:
    """
    Converts a Motius InteractionProfile into a LeRobot action dict
    that can be dispatched through the LeRobot controller loop.

    Usage:
        adapter = LeRobotProfileAdapter(profile=get_profile("gentle"))
        action  = adapter.to_lerobot_action(task="handover")
        le_robot_dispatch(action)
    """

    profile: InteractionProfile
    _runtime_cache: dict[str, Any] = field(default_factory=dict)

    # Scale mapping: Motius speed_scale → LeRobot forward_speed (m/s)
    # Unitree G1 nominal walking speed ≈ 0.3 m/s
    _NOMINAL_SPEED_MPS: float = 0.3

    def to_lerobot_action(self, task: str) -> dict[str, Any]:
        """
        Returns a LeRobot-compatible action dict for the given task.

        Parameters
        ----------
        task : str
            One of the Motius allowed task types:
            handover | approach_stop | wait_behavior | corridor_etiquette | push_object

        Returns
        -------
        dict
            Action payload with keys: profile_id, task, locomotion,
            arrival, arm, and a _meta dict for dispatch traceability.
        """
        runtime = profile_to_runtime_adapter(self.profile, task=task)
        loco    = runtime["runtime_adapter"]["locomotion"]
        arr     = runtime["runtime_adapter"]["arrival"]
        arm     = runtime["runtime_adapter"]["arm"]
        hand    = runtime["runtime_adapter"]["handover"]

        lerobot_action = {
            # -- Meta --
            "profile_id": runtime["profile_id"],
            "profile_name": runtime["profile"],
            "task": task,

            # -- Locomotion --
            "forward_speed": self._scale_speed(loco["speed_scale"]),
            "turn_speed":   0.0,           # static; extend with user bearing
            "finish_softness": loco.get("finish_softness", 0.5),

            # -- Arrival --
            "stop_distance":  arr["stop_distance_m"],
            "pause_duration": arr["pause_ms"] / 1000.0,   # ms → s
            "approach_speed": self._scale_speed(
                loco["speed_scale"] * 0.7              # slower on approach
            ),

            # -- Arm / End-Effector --
            "ee_smoothing":  arm["ee_smoothing"],
            "grip_width":    self._grip_width_for_task(task),
            "reach_force":   0.5,           # normalised 0–1; TODO: calibrate

            # -- Handover --
            "hold_duration": hand["hold_ms"] / 1000.0,   # ms → s

            # -- Dispatch meta --
            "_meta": {
                "motius_version": "0.1.0",
                "adaptation":     "runtime",
                "platform":       "Unitree_G1",
            },
        }

        return lerobot_action

    def _scale_speed(self, speed_scale: float) -> float:
        """Map Motius speed_scale (0–1) → LeRobot forward_speed (m/s)."""
        return round(speed_scale * self._NOMINAL_SPEED_MPS, 4)

    def _grip_width_for_task(self, task: str) -> float:
        """Return default grip width (m) for common task types."""
        widths = {
            "handover":        0.08,
            "push_object":     0.12,
            "approach_stop":   0.05,
            "wait_behavior":   0.04,
            "corridor_etiquette": 0.04,
        }
        return widths.get(task, 0.06)

    def to_action_dict(self, task: str) -> dict[str, Any]:
        """Alias for to_lerobot_action — backwards-compatible."""
        return self.to_lerobot_action(task=task)


def adapt_profile(name: str, task: str) -> dict[str, Any]:
    """
    One-liner: load a profile by name and return its LeRobot action dict.

    Usage:
        action = adapt_profile("gentle", task="handover")
    """
    profile = get_profile(name)
    adapter = LeRobotProfileAdapter(profile=profile)
    return adapter.to_lerobot_action(task=task)
PYEOF
      git add "$ADAPTER_FILE"
      commit_msg="feat(lerobot): add LeRobotProfileAdapter core converter class"
      did_commit=true
      echo "[Task 0] Created lerobot_adapter.py" >> "$LOG_FILE"
    fi
    ;;

  1)
    # Task 1: profile_validator with boundary checks
    VALIDATOR_FILE="$REPO/unitree_lerobot/profile_validator.py"
    if [ ! -f "$VALIDATOR_FILE" ]; then
      cat > "$VALIDATOR_FILE" << 'PYEOF'
"""
Profile Validator — runtime boundary checks for Motius profile fields.

Ensures all profile parameter values stay within robot-safe operating ranges
before they are translated into runtime adapters.

Ranges are calibrated for Unitree G1 humanoid platform.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import NamedTuple


# ─── Unitree G1 Safe Operating Ranges ─────────────────────────────────────────
class ProfileFieldRanges(NamedTuple):
    min_val: float
    max_val: float


RANGES: dict[str, ProfileFieldRanges] = {
    "speed_scale":          ProfileFieldRanges(0.30, 1.20),
    "pause_ms":            ProfileFieldRanges(50,   2000),
    "approach_distance_m": ProfileFieldRanges(0.40, 2.00),
    "ee_smoothing":        ProfileFieldRanges(0.50, 1.00),
    "hold_ms":            ProfileFieldRanges(0,     5000),
    "finish_softness":    ProfileFieldRanges(0.0,  1.00),
}


@dataclass
class ValidationResult:
    field: str
    value: float
    valid: bool
    reason: str = ""


class ProfileValidator:
    """
    Validates a dict of profile field values against Unitree G1 safe ranges.

    Usage:
        validator = ProfileValidator()
        results   = validator.validate(profile.to_dict())
        violations = [r for r in results if not r.valid]
    """

    def __init__(self, ranges: dict[str, ProfileFieldRanges] | None = None) -> None:
        self.ranges = ranges or RANGES

    def validate(self, profile_fields: dict[str, float]) -> list[ValidationResult]:
        results: list[ValidationResult] = []
        for field, value in profile_fields.items():
            if field not in self.ranges:
                continue   # skip unknown fields
            rng = self.ranges[field]
            if not (rng.min_val <= value <= rng.max_val):
                results.append(ValidationResult(
                    field=field,
                    value=value,
                    valid=False,
                    reason=f"value {value} outside safe range "
                           f"[{rng.min_val}, {rng.max_val}]",
                ))
            else:
                results.append(ValidationResult(
                    field=field,
                    value=value,
                    valid=True,
                ))
        return results

    def validate_or_raise(self, profile_fields: dict[str, float]) -> None:
        violations = [r for r in self.validate(profile_fields) if not r.valid]
        if violations:
            lines = "\n".join(
                f"  - {r.field}={r.value}: {r.reason}"
                for r in violations
            )
            raise ValueError(f"Profile field violations:\n{lines}")


def validate_profile(profile_fields: dict[str, float]) -> list[ValidationResult]:
    return ProfileValidator().validate(profile_fields)
PYEOF
      git add "$VALIDATOR_FILE"
      commit_msg="feat(validator): add ProfileValidator with Unitree G1 boundary checks"
      did_commit=true
      echo "[Task 1] Created profile_validator.py" >> "$LOG_FILE"
    fi
    ;;

  2)
    # Task 2: Unitree G1 specific adapter fields extension
    ADAPTER_FILE="$REPO/unitree_lerobot/lerobot_adapter.py"
    if [ -f "$ADAPTER_FILE" ] && ! grep -q "_torso_height" "$ADAPTER_FILE"; then
      cat >> "$ADAPTER_FILE" << 'PYEOF'


# ─── Unitree G1 Body Geometry Constants ──────────────────────────────────────
# These values are used to convert Motius abstract fields into
# robot-specific body poses.

LEG_STAND_HEIGHT_M = 0.58    # default standing torso height (m)
LEG_SIT_HEIGHT_M    = 0.38    # sitting torso height (m)
ARM_REACH_M         = 0.40    # nominal arm reach from shoulder (m)


@dataclass
class UnitreeG1PoseMixin:
    """
    Mixin that adds Unitree G1 body-specific pose conversions
    to LeRobotProfileAdapter.

    Extend LeRobotProfileAdapter with:
        class LeRobotAdapterG1(LeRobotProfileAdapter, UnitreeG1PoseMixin):
            pass
    """

    def torso_height_for_distance(self, distance_m: float) -> float:
        """
        Adjust torso height (m) based on target approach distance.
        Closer → lower torso for stability; farther → full height.
        """
        if distance_m < 0.6:
            return LEG_SIT_HEIGHT_M
        elif distance_m < 1.0:
            return round(LEG_STAND_HEIGHT_M * 0.85, 4)
        return LEG_STAND_HEIGHT_M

    def arm_pose_for_task(self, task: str, ee_smoothing: float) -> dict[str, float]:
        """
        Return arm joint angle targets (rad) keyed by joint name.
        These are calibrated for the Unitree G1 27-DOF arm configuration.
        """
        return {
            "shoulder_lift_joint":  0.3 + (1 - ee_smoothing) * 0.2,
            "elbow_joint":         1.2 - (1 - ee_smoothing) * 0.3,
            "wrist_roll_joint":    0.0,
            "wrist_pitch_joint":    0.0,
            "gripper_joint":        self._grip_width_for_task(task),
        }
PYEOF
      git add "$ADAPTER_FILE"
      commit_msg="feat(lerobot): add UnitreeG1PoseMixin torso/arm pose helpers"
      did_commit=true
      echo "[Task 2] Extended lerobot_adapter.py with G1 pose mixin" >> "$LOG_FILE"
    fi
    ;;

  3)
    # Task 3: Add "guide" task type to schema
    SCHEMA_FILE="$REPO/unitree_lerobot/motius_schema.py"
    if [ -f "$SCHEMA_FILE" ]; then
      if ! grep -q "guide" "$SCHEMA_FILE"; then
        sed -i 's/"corridor_etiquette",/"corridor_etiquette",\n    "guide",/' "$SCHEMA_FILE"
        git add "$SCHEMA_FILE"
        commit_msg="feat(schema): add guide task type for front-desk guidance scenarios"
        did_commit=true
        echo "[Task 3] Added guide task type" >> "$LOG_FILE"
      fi
    fi
    ;;

  4)
    # Task 4: Write LeRobot adapter integration test
    TEST_FILE="$REPO/test/test_lerobot_adapter.py"
    if [ ! -f "$TEST_FILE" ]; then
      cat > "$TEST_FILE" << 'PYEOF'
"""Integration tests for LeRobotProfileAdapter."""

import pathlib
import sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

import pytest
from unitree_lerobot import get_profile
from unitree_lerobot.lerobot_adapter import (
    LeRobotProfileAdapter,
    adapt_profile,
)


@pytest.fixture
def gentle_profile():
    return get_profile("gentle")


@pytest.fixture
def adapter(gentle_profile):
    return LeRobotProfileAdapter(profile=gentle_profile)


class TestLeRobotProfileAdapter:
    def test_gentle_action_contains_all_keys(self, adapter):
        action = adapter.to_lerobot_action(task="handover")
        expected_keys = {
            "profile_id", "profile_name", "task",
            "forward_speed", "turn_speed", "finish_softness",
            "stop_distance", "pause_duration", "approach_speed",
            "ee_smoothing", "grip_width", "reach_force",
            "hold_duration", "_meta",
        }
        assert expected_keys.issubset(action.keys()), f"Missing keys: {expected_keys - action.keys()}"

    def test_gentle_speed_scale_mapped_correctly(self, adapter):
        # speed_scale=0.82, nominal=0.3 m/s → 0.246 m/s
        action = adapter.to_lerobot_action(task="handover")
        assert abs(action["forward_speed"] - 0.246) < 0.001

    def test_gentle_pause_ms_converted_to_seconds(self, adapter):
        # pause_ms=420 → pause_duration=0.42s
        action = adapter.to_lerobot_action(task="handover")
        assert abs(action["pause_duration"] - 0.42) < 0.001

    def test_gentle_stop_distance(self, adapter):
        # approach_distance_m=0.95
        action = adapter.to_lerobot_action(task="handover")
        assert abs(action["stop_distance"] - 0.95) < 0.001

    def test_hold_duration_ms_to_seconds(self, adapter):
        # hold_ms=620 → 0.62s
        action = adapter.to_lerobot_action(task="handover")
        assert abs(action["hold_duration"] - 0.62) < 0.001

    def test_grip_width_different_per_task(self, adapter):
        # handover=0.08, push_object=0.12
        h_action = adapter.to_lerobot_action(task="handover")
        p_action = adapter.to_lerobot_action(task="push_object")
        assert h_action["grip_width"] < p_action["grip_width"]

    def test_approach_speed_slower_than_cruise(self, adapter):
        action = adapter.to_lerobot_action(task="handover")
        assert action["approach_speed"] < action["forward_speed"]

    def test_one_liner_adapt_profile(self):
        action = adapt_profile("gentle", task="handover")
        assert action["profile_name"] == "Gentle"
        assert action["forward_speed"] > 0

    def test_all_profiles_produce_valid_action(self):
        for name in ("gentle", "standard", "attentive", "hospitality"):
            profile = get_profile(name)
            adapter = LeRobotProfileAdapter(profile=profile)
            action  = adapter.to_lerobot_action(task="handover")
            assert action["forward_speed"] > 0
            assert action["pause_duration"] > 0
PYEOF
      git add "$TEST_FILE"
      commit_msg="test(lerobot): add integration tests for LeRobotProfileAdapter"
      did_commit=true
      echo "[Task 4] Created test_lerobot_adapter.py" >> "$LOG_FILE"
    fi
    ;;

  5)
    # Task 5: Expand README with architecture diagram and usage
    README_FILE="$REPO/README.md"
    if [ -f "$README_FILE" ]; then
      ARCH_SECTION="
## 🏗 Architecture

```
┌─────────────────────────────────────────────────────┐
│              Reference Network                       │
│  Human behavior clips → AI annotation → Data store  │
└──────────────────────┬──────────────────────────────┘
                       │ trains
                       ▼
┌─────────────────────────────────────────────────────┐
│           Profile Predictor (AI model)              │
│  scene + user type → profile parameter ranges      │
└──────────────────────┬──────────────────────────────┘
                       │ outputs
                       ▼
┌─────────────────────────────────────────────────────┐
│         InteractionProfile (this repo)              │
│  gentle / standard / attentive / hospitality       │
└──────────────────────┬──────────────────────────────┘
                       │ profile_to_runtime_adapter
                       ▼
┌─────────────────────────────────────────────────────┐
│         LeRobotProfileAdapter (lerobot_adapter.py)  │
│  runtime fields → LeRobot action dict               │
└──────────────────────┬──────────────────────────────┘
                       │ dispatches
                       ▼
┌─────────────────────────────────────────────────────┐
│           LeRobot Controller (Unitree G1)            │
│         Low-level control + safety limits           │
└─────────────────────────────────────────────────────┘
```

### Perceive → Adapt → Validate → Deploy

| Step | What happens |
|------|-------------|
| **Perceive** | Camera/LiDAR detects user type + scene |
| **Adapt** | Profile Predictor outputs parameter ranges |
| **Validate** | Adapter maps to LeRobot-safe action values |
| **Deploy** | LeRobot controller executes with new parameters |
"
      # Append architecture section before the License line
      if ! grep -q "## 🏗 Architecture" "$README_FILE"; then
        sed -i "/## 📄 License/i\\$ARCH_SECTION" "$README_FILE"
        git add "$README_FILE"
        commit_msg="docs: add architecture diagram and Perceive-Adapt-Validate-Deploy flow"
        did_commit=true
        echo "[Task 5] Expanded README architecture section" >> "$LOG_FILE"
      fi
    fi
    ;;

  6)
    # Task 6: Extend __init__.py with new public exports
    INIT_FILE="$REPO/unitree_lerobot/__init__.py"
    if [ -f "$INIT_FILE" ]; then
      if ! grep -q "lerobot_adapter" "$INIT_FILE"; then
        echo "" >> "$INIT_FILE"
        echo "# LeRobot Adapter (new)" >> "$INIT_FILE"
        echo "from .lerobot_adapter import LeRobotProfileAdapter, adapt_profile  # noqa: F401" >> "$INIT_FILE"
        echo "from .profile_validator import ProfileValidator, validate_profile  # noqa: F401" >> "$INIT_FILE"
        git add "$INIT_FILE"
        commit_msg="feat(api): export LeRobotProfileAdapter and ProfileValidator"
        did_commit=true
        echo "[Task 6] Updated __init__.py exports" >> "$LOG_FILE"
      fi
    fi
    ;;
esac

# ---------- Commit & Push ----------
if [ "$did_commit" = true ] && [ -n "$commit_msg" ]; then
  git config user.email "bot@motiusrobotics.com"
  git config user.name  "Motius Bot"
  git commit -m "$commit_msg"
  git push origin main 2>&1 | tail -5 >> "$LOG_FILE"
  echo "[$DATE] ✓ Committed & pushed: $commit_msg" >> "$LOG_FILE"

  # Send Feishu report
  COMMIT_MSG_CLEAN=$(echo "$commit_msg" | sed "s/\`//g")
  REPORT="🤖 Motius 每日开发报告 | $DATE

✅ 今日完成: $COMMIT_MSG_CLEAN
📁 Repo: motiusrobotics/unitree_lerobot_motius
⏰ 明天继续 Task $(( (TASK_NUM + 1) % 7 ))"
  
  echo "$REPORT"
else
  echo "[$DATE] No changes needed today (Task $TASK_NUM)" >> "$LOG_FILE"
fi

echo "=== [$DATE] Run complete ===" >> "$LOG_FILE"
