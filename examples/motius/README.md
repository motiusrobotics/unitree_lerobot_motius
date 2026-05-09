# Motius behavior-layer starter

This folder adds the smallest useful starting point for Motius work on top of
`unitree_lerobot`.

## Included

- `gentle_profile_runtime.json`
  - Example of mapping a Motius profile into a narrow runtime-facing adapter surface.
- `reference_clip_example.json`
  - Example of a short human reference clip record.
- `dataset_entry_example.json`
  - Example of attaching a reference clip to a profile-conditioned dataset entry.

## Intended use

This starter layer is not a training pipeline by itself. It is a schema and
profile surface that can be used to:

1. define behavior presets for Unitree G1 proof runs,
2. standardize short reference clips collected from field or staged service interactions,
3. attach those clips to future LeRobot-compatible evaluation and fine-tuning workflows.
