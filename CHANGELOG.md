# Changelog

All notable changes to FluxVirt Lab are documented in this file.
The project follows semantic versioning for formal releases.

## [Unreleased]

### Planned

- introduce encrypted GitOps secrets;
- add policy-as-code and observability.

## [0.1.0] - 2026-07-27

### Added

- Windows 11 Home virtualization preflight and dedicated lab boot;
- VirtualBox provisioning with nested hardware virtualization;
- Ubuntu Server 24.04.4 LTS outer virtual machine;
- hardware-accelerated nested KVM validation;
- single-node K3s cluster;
- Flux CD bootstrap and dependency-ordered reconciliation;
- KubeVirt and CDI installation;
- Ubuntu KubeVirt VM with cloud-init and persistent root disk;
- QEMU Guest Agent integration;
- NodePort access for guest SSH and HTTP;
- hardened container workload;
- static repository and runtime acceptance scripts;
- ShellCheck, yamllint, Kustomize and Kubeconform validation;
- Gitleaks full-history secret scanning;
- pinned Trivy HIGH and CRITICAL filesystem scanning;
- protected `main` branch and pull-request governance;
- Dependabot version and security updates;
- architecture, operations, security and portfolio documentation;
- clean-room rebuild validation from a fresh outer Ubuntu virtual machine;
- checksum-verified KubeVirt VM-disk export and isolated CDI restore;
- read-only libguestfs verification of the restored system and web markers;
- halted restored-VM construction without cloud-init replay and with a
  distinct firmware identity;
- restored VM first boot, QEMU Guest Agent validation and exact HTTP marker
  verification through a temporary `virtctl port-forward`;
- complete cleanup of the temporary VM, VMI, DataVolume, PVC and PV;
- canonical runtime acceptance with the restored VM running and again after
  cleanup.

### Security

- GitHub Actions permissions restricted to `contents: read`;
- action references pinned to immutable commit SHAs;
- GitHub secret scanning and push protection enabled;
- direct pushes, force pushes and branch deletion blocked;
- private SSH keys and kubeconfig data excluded from Git.

### Known limitations

- one Kubernetes node;
- local-path storage is node-bound;
- no live migration or high availability;
- no distributed storage;
- runtime acceptance requires access to the local lab cluster.
