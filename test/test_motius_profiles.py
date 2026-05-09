import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from unitree_lerobot import (
    BehaviorDatasetEntry,
    HumanReferenceClip,
    TaskContext,
    get_profile,
    profile_to_runtime_adapter,
)


def test_gentle_profile_maps_to_expected_runtime_fields():
    profile = get_profile("gentle")
    runtime = profile_to_runtime_adapter(profile, task="handover")

    assert runtime["profile"] == "Gentle"
    assert runtime["runtime_adapter"]["locomotion"]["speed_scale"] == 0.82
    assert runtime["runtime_adapter"]["arrival"]["pause_ms"] == 420
    assert runtime["runtime_adapter"]["arrival"]["stop_distance_m"] == 0.95
    assert runtime["runtime_adapter"]["arm"]["ee_smoothing"] == 0.96


def test_reference_entry_builds_dataset_key():
    clip = HumanReferenceClip(
        clip_id="clip_001",
        relative_path="references/clip_001.mp4",
        clip_duration_s=12.0,
        context=TaskContext(task_type="handover", scene_type="hotel"),
        behavior_tags=("warm", "patient", "soft"),
    )
    entry = BehaviorDatasetEntry(
        entry_id="entry_001",
        robot_type="Unitree_G1",
        active_profile="gentle",
        reference_clip=clip,
    )

    assert entry.dataset_key == "Unitree_G1:gentle:handover:entry_001"


def test_invalid_task_type_raises():
    try:
        TaskContext(task_type="invalid_task", scene_type="hotel")
    except ValueError as exc:
        assert "Unsupported task_type" in str(exc)
        return
    raise AssertionError("Expected invalid task type to raise ValueError")
