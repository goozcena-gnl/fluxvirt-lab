# ADR 0002: Ubuntu version

- Status: Proposed
- Date: 2026-07-22

## Decision

Pin the outer laboratory VM to Ubuntu Server 24.04.4 LTS for the first portfolio release.

## Rationale

Ubuntu 26.04 LTS is available, but 24.04.4 has a longer period of ecosystem exposure and is explicitly accepted by current K3s requirements. The selected Kubernetes/KubeVirt intersection is more important than using the newest OS release.

## Upgrade gate

Evaluate Ubuntu 26.04 after its first point release and after a full rebuild test confirms KVM, K3s, Flux, KubeVirt, CDI, storage, and networking behavior.
