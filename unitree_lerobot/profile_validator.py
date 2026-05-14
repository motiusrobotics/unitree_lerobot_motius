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
