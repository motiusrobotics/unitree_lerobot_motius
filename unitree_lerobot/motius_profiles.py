from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any


@dataclass(frozen=True)
class BehaviorTraits:
    interaction_tone: str
    motion_traits: str


@dataclass(frozen=True)
class InteractionProfile:
    name: str
    profile_id: str
    scene_fit: tuple[str, ...]
    speed_scale: float
    pause_ms: int
    approach_distance_m: float
    ee_smoothing: float
    hold_ms: int = 0
    finish_softness: float = 0.0
    tags: tuple[str, ...] = field(default_factory=tuple)
    traits: BehaviorTraits = field(
        default_factory=lambda: BehaviorTraits(
            interaction_tone="neutral / direct / efficient",
            motion_traits="shorter pause, tighter spacing, quicker completion",
        )
    )

    def to_dict(self) -> dict[str, Any]:
        payload = asdict(self)
        payload["scene_fit"] = list(self.scene_fit)
        payload["tags"] = list(self.tags)
        return payload


PROFILE_LIBRARY: dict[str, InteractionProfile] = {
    "hospitality": InteractionProfile(
        name="Hospitality",
        profile_id="motius.hospitality.v1",
        scene_fit=("hotel_lobby", "front_desk", "formal_greeting"),
        speed_scale=0.75,
        pause_ms=500,
        approach_distance_m=1.00,
        ee_smoothing=0.97,
        hold_ms=700,
        finish_softness=0.80,
        tags=("formal", "warm", "attentive"),
        traits=BehaviorTraits(
            interaction_tone="formal / warm / attentive",
            motion_traits="slowest approach, longest pause, widest stopping distance, softest finish",
        ),
    ),
    "standard": InteractionProfile(
        name="Standard",
        profile_id="motius.standard.v1",
        scene_fit=("hotel_delivery", "general_service", "default_operations"),
        speed_scale=1.00,
        pause_ms=200,
        approach_distance_m=0.80,
        ee_smoothing=0.90,
        hold_ms=350,
        finish_softness=0.30,
        tags=("neutral", "direct", "efficient"),
        traits=BehaviorTraits(
            interaction_tone="neutral / direct / efficient",
            motion_traits="shorter pause, tighter spacing, quicker completion",
        ),
    ),
    "gentle": InteractionProfile(
        name="Gentle",
        profile_id="motius.gentle.v1",
        scene_fit=("guest_handover", "calmer_arrival", "softer_reception"),
        speed_scale=0.82,
        pause_ms=420,
        approach_distance_m=0.95,
        ee_smoothing=0.96,
        hold_ms=620,
        finish_softness=0.72,
        tags=("warm", "patient", "soft"),
        traits=BehaviorTraits(
            interaction_tone="warm / patient / soft",
            motion_traits="longer pause, wider stop distance, softer finish",
        ),
    ),
    "attentive": InteractionProfile(
        name="Attentive",
        profile_id="motius.attentive.v1",
        scene_fit=("front_desk", "lobby_guidance", "public_hospitality"),
        speed_scale=0.92,
        pause_ms=300,
        approach_distance_m=0.88,
        ee_smoothing=0.94,
        hold_ms=420,
        finish_softness=0.55,
        tags=("alert", "polished", "social"),
        traits=BehaviorTraits(
            interaction_tone="alert / polished / social",
            motion_traits="cleaner arrival, brighter cadence, composed exit",
        ),
    ),
}


def get_motius_profile(name: str) -> InteractionProfile:
    """Alias of get_profile for backwards-compatible API."""
    return get_profile(name)


def get_profile(name: str) -> InteractionProfile:
    key = name.strip().lower()
    if key not in PROFILE_LIBRARY:
        raise KeyError(f"Unknown Motius profile: {name}")
    return PROFILE_LIBRARY[key]


def profile_to_runtime_adapter(profile: InteractionProfile, task: str) -> dict[str, Any]:
    """
    Convert a robot-agnostic interaction profile into a narrow runtime-facing config.

    The intent is not to replace low-level control. It writes a small adapter surface
    that upstream runtime code can consume safely.
    """

    return {
        "profile": profile.name,
        "profile_id": profile.profile_id,
        "task": task,
        "runtime_adapter": {
            "locomotion": {
                "speed_scale": profile.speed_scale,
                "finish_softness": profile.finish_softness,
            },
            "arrival": {
                "pause_ms": profile.pause_ms,
                "stop_distance_m": profile.approach_distance_m,
            },
            "handover": {
                "hold_ms": profile.hold_ms,
            },
            "arm": {
                "ee_smoothing": profile.ee_smoothing,
            },
        },
        "tags": list(profile.tags),
    }
