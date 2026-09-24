# Agent Instructions

## Repository purpose

This repository is a reproducible Kubernetes virtualization lab using K3s, Flux CD, KubeVirt, and CDI. Preserve the distinction between retained runtime evidence, external raw artifacts, and repository-only static CI.

## Sources of truth

- `docs/ARCHITECTURE.md` defines the recorded architecture.
- `VALIDATION.md` records dated validation evidence.
- `docs/BACKUP-RESTORE.md` records the bounded recovery exercise.
- `clusters/fluxvirt-lab/` defines Flux reconciliation.
- `versions.env` defines pinned project versions where applicable.

## Mandatory validation

Before claiming repository validation, required tools must actually be present. The validation script may skip unavailable tools.

```bash
for tool in shellcheck yamllint kubectl kubeconform; do
  command -v "$tool" >/dev/null 2>&1 || exit 1
done

./scripts/validation/validate-repository.sh
git diff --check
```

If a change affects the live platform or workloads, also run when a suitable lab is available:

```bash
RESTART_STABILITY_SECONDS=15 ./scripts/validation/check-workloads.sh
```

## Engineering rules

- Preserve Flux as the reconciliation authority.
- Keep version/checksum verification for downloaded bootstrap and validation tooling.
- Do not weaken secret scanning, Trivy, manifest validation, or immutable workload references to make CI pass.
- Never commit private SSH keys, GitHub tokens, kubeconfigs, passwords, SOPS/age private keys, cloud credentials, or generated secret-bearing files.
- Do not describe configuration or static validation as live KVM/KubeVirt evidence.
- Runtime work that was not executed must be explicitly marked `NOT RUN`.

## Lab boundaries

This is a single-node engineering lab, not a production HA environment. Do not introduce production-readiness claims without separate evidence. Recovery evidence applies only to the exact exercise documented.

## Pull request discipline

Document objective, static validation, runtime validation status, security/operational risks, and rollback. Do not merge or release on behalf of the user.
