---
applyTo: "clusters/**,infrastructure/**,virtual-machines/**,apps/**,scripts/**,versions.env"
---

# Kubernetes Virtualization and GitOps Instructions

- Preserve Flux ownership and dependency ordering for reconciled resources.
- Keep pinned versions and checksum verification for downloaded platform artifacts and tooling.
- Do not bypass KubeVirt/CDI manifest validation or secret scanning.
- Avoid combining unrelated infrastructure and workload changes in one diff.
- For live-platform changes, record whether K3s, Flux, KubeVirt, CDI, VM, and container checks were actually executed.
- Configuration-only validation must remain distinct from runtime virtualization evidence.
