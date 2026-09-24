# GitHub Copilot Instructions

Read and follow `AGENTS.md` as the repository-wide engineering and evidence contract.

For Copilot-specific work:
- preserve Flux as the reconciliation authority and keep changes focused;
- inspect version pins, checksum verification, validation scripts, and retained evidence before editing;
- do not weaken Gitleaks, Trivy, Kubeconform, or immutable-reference controls to make CI pass;
- distinguish static repository checks from live K3s/KubeVirt/CDI evidence;
- do not create production-readiness claims from this single-node lab;
- leave merge, release, bootstrap credentials, and live-lab mutations to a human.
