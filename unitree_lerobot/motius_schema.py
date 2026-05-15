from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any


ALLOWED_TASK_TYPES = {
    "handover",
    "approach_stop",
    "wait_behavior",
    "corridor_etiquette",
    "guide",
    "push_object",
}


@dataclass(frozen=True)
class TaskContext:
    task_type: str
    scene_type: str
    notes: str = ""

    def __post_init__(self) -> None:
        if self.task_type not in ALLOWED_TASK_TYPES:
            raise ValueError(
                f"Unsupported task_type={self.task_type!r}. Allowed: {sorted(ALLOWED_TASK_TYPES)}"
            )


@dataclass(frozen=True)
class HumanReferenceClip:
    clip_id: str
    relative_path: str
    clip_duration_s: float
    context: TaskContext
    behavior_tags: tuple[str, ...]
    review_status: str = "validating"
    source: str = "field_capture"

    def to_dict(self) -> dict[str, Any]:
        payload = asdict(self)
        payload["behavior_tags"] = list(self.behavior_tags)
        return payload


@dataclass(frozen=True)
class BehaviorDatasetEntry:
    entry_id: str
    robot_type: str
    active_profile: str
    reference_clip: HumanReferenceClip
    labels: dict[str, float | str] = field(default_factory=dict)
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)

    @property
    def dataset_key(self) -> str:
        return (
            f"{self.robot_type}:{self.active_profile}:"
            f"{self.reference_clip.context.task_type}:{self.entry_id}"
        )
