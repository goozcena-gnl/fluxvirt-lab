# ADR 0004: MVP storage strategy

- Status: Proposed
- Date: 2026-07-22

## Decision

Use K3s local-path-provisioner and filesystem-mode ReadWriteOnce PVCs for the first VM.

## Rationale

This is the smallest reproducible option for a single-node lab. It is sufficient for CDI import, VM boot, and lifecycle demonstrations.

## Consequences

Storage is node-local, not highly available, and not migration-capable. VM disk backup must be designed separately. Longhorn or another CSI system belongs to a later multi-node phase.
