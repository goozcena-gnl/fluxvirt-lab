# Roadmap

## v0.1.0 — validated single-node MVP

Status: validated implementation baseline.

Completed:

- Windows 11 Home host-mode preflight;
- dedicated non-Microsoft-hypervisor lab boot;
- VirtualBox and Ubuntu provisioning;
- nested KVM validation;
- single-node K3s;
- Flux CD bootstrap;
- KubeVirt and CDI;
- persistent Ubuntu virtual machine;
- hardened container workload;
- static and runtime acceptance;
- Gitleaks and Trivy scanning;
- protected repository governance;
- Dependabot version and security updates;
- recruiter-facing documentation.

Remaining gates before publication:

- clean-room rebuild from a fresh outer Ubuntu VM, with timing and evidence;
- documented VM disk or PVC backup and restore exercise;
- tested disaster-recovery runbook with end-to-end acceptance evidence.

## v0.2.0 — reproducibility and resilience

Planned:

- automated and repeatable clean-room rebuild validation;
- recurring backup and restore validation;
- SOPS with age for encrypted GitOps secrets;
- NetworkPolicies for workload isolation;
- improved release automation.

## v0.3.0 — policy and observability

Planned:

- Kyverno in Audit mode and then Enforce;
- Prometheus and Grafana;
- KubeVirt and node health dashboards;
- alerting for reconciliation and VM failures;
- capacity and saturation reporting;
- SBOM generation and image-signature validation.

## v0.4.0 — platform usability

Planned:

- reusable virtual-machine templates;
- self-service workload examples;
- Ansible guest configuration;
- optional host-only networking;
- documented upgrade and rollback exercises.

## v1.0.0 — expanded platform

Potential scope:

- multiple physical or virtual Kubernetes nodes;
- migration-capable storage;
- KubeVirt live migration;
- high-availability control plane;
- load balancer and ingress design;
- Loki, Tempo and OpenTelemetry;
- migration to Proxmox VE or native Linux KVM/libvirt.
