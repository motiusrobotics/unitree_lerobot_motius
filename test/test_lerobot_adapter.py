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
