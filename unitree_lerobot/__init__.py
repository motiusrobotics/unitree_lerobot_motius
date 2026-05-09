from .motius_profiles import (
    BehaviorTraits,
    InteractionProfile,
    PROFILE_LIBRARY,
    get_profile,
    profile_to_runtime_adapter,
)
from .motius_schema import (
    BehaviorDatasetEntry,
    HumanReferenceClip,
    TaskContext,
)

# Canonical public API entrypoint — both names resolve to the same function
get_motius_profile = get_profile

__all__ = [
    "BehaviorTraits",
    "InteractionProfile",
    "PROFILE_LIBRARY",
    "get_profile",
    "get_motius_profile",
    "profile_to_runtime_adapter",
    "BehaviorDatasetEntry",
    "HumanReferenceClip",
    "TaskContext",
]
