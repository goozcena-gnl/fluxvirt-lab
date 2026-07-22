# Security plan

## MVP

- SSH key authentication and restricted management subnet.
- No passwords, private keys, PATs, kubeconfigs, or age private keys in Git.
- Fixed component versions and vendored platform manifests.
- GitHub Actions `contents: read` only.
- Non-root container, dropped capabilities, read-only root filesystem, seccomp runtime default.
- UFW permits only explicit management/API/NodePort paths.
- Trivy filesystem scan pinned to the known-safe `trivy-action` v0.35.0 commit and Trivy v0.69.3; mutable tags are prohibited because of the March 2026 Trivy supply-chain incident.

## Intermediate

- SOPS with age for Kubernetes secrets.
- Kyverno in Audit first, then Enforce after reviewing false positives.
- Gitleaks or TruffleHog secret scanning.
- Dependabot/Renovate with controlled upgrade PRs.
- NetworkPolicies and signed project images.

## Threat boundaries

Treat Windows, the hypervisor, outer Ubuntu, Kubernetes API, Flux deploy credentials, privileged KubeVirt components, CDI image sources, cloud-init, and guest SSH as separate trust boundaries. `/dev/kvm` is intentionally privileged access to hardware virtualization and should not be made broadly writable.
