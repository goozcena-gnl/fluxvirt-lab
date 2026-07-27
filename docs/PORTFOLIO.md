# Portfolio positioning

## Repository description

GitOps-managed K3s and KubeVirt laboratory on Ubuntu Server, running a
persistent virtual machine and a hardened container through Flux CD
inside a reproducible VirtualBox environment on Windows 11 Home.

## Elevator pitch

FluxVirt Lab demonstrates how I design, secure and operate a hybrid
Kubernetes platform rather than only deploying an application.

The project validates a Windows Home → VirtualBox → Ubuntu → nested KVM
virtualization chain, deploys K3s, reconciles KubeVirt and CDI with Flux,
and operates both a persistent Ubuntu VM and a hardened container from
Git.

The repository includes automated validation, vulnerability and secret
scanning, protected-branch governance, runtime acceptance and
architecture documentation.

## Engineering competencies demonstrated

### Systems and virtualization

- Windows virtualization-mode analysis;
- VirtualBox automation;
- Ubuntu Server administration;
- nested KVM verification;
- SSH and network-forwarding design.

### Kubernetes and platform engineering

- K3s installation and operation;
- CRD and operator lifecycle management;
- KubeVirt virtual machines;
- CDI DataVolumes and persistent storage;
- cloud-init guest provisioning;
- Kubernetes security contexts and health probes.

### GitOps and delivery

- Flux bootstrap;
- dependency-ordered reconciliation;
- independent workload ownership;
- server-side apply validation;
- pull-request-only delivery.

### DevSecOps and quality

- ShellCheck and yamllint;
- Kustomize rendering;
- Kubeconform validation;
- Gitleaks history scanning;
- pinned Trivy scanning;
- immutable GitHub Actions references;
- protected branch and required checks;
- Dependabot updates.

### SRE and operations

- preflight gates;
- health and readiness validation;
- end-to-end runtime acceptance;
- rollback documentation;
- explicit limitations and failure boundaries;
- troubleshooting based on evidence.

## Verifiable outcomes

The repository proves:

- a K3s node is Ready;
- all Flux Kustomizations reconcile successfully;
- KubeVirt reports Available;
- KVM devices are allocatable;
- a KubeVirt VM and VMI are Running and Ready;
- CDI import completes successfully;
- the guest persistent volume is Bound;
- QEMU Guest Agent connects;
- the VM-hosted and container-hosted HTTP services respond;
- both required CI security gates pass;
- direct pushes to `main` are rejected.

## CV bullets

- Designed and operated a Windows 11 Home nested-virtualization lab
  running K3s and KubeVirt on Ubuntu Server with explicit hardware
  acceleration gates.
- Automated VirtualBox provisioning, Ubuntu preparation, Kubernetes
  bootstrap and validation using PowerShell and Bash.
- Implemented dependency-ordered Flux CD reconciliation for KubeVirt,
  CDI, virtual machines and container workloads.
- Provisioned a persistent Ubuntu VM with CDI, cloud-init, QEMU Guest
  Agent and NodePort connectivity.
- Built CI gates for shell, YAML and Kubernetes validation, Gitleaks
  secret detection and pinned Trivy vulnerability scanning.
- Enforced protected-branch governance with required pull requests,
  status checks, squash merges and blocked force pushes.
- Documented architecture, security boundaries, failure modes, backup
  strategy and a reproducible recruiter demonstration.

## Interview narrative

A useful discussion sequence is:

1. why nested virtualization on Windows Home is non-trivial;
2. how the host-mode preflight prevents false assumptions;
3. why KubeVirt and CDI are reconciled in dependency order;
4. why VM disks require different lifecycle thinking from containers;
5. how static CI differs from cluster-side runtime acceptance;
6. how the repository prevents unvalidated changes to `main`;
7. which design choices would change in a production multi-node system.

## Honest boundaries

This project does not claim production availability.

The current MVP is deliberately:

- single-node;
- local-path-backed;
- non-migratable;
- NAT-exposed;
- operated as a controlled learning and portfolio environment.

## GitHub topics

`kubernetes`, `kubevirt`, `fluxcd`, `gitops`, `k3s`, `ubuntu`,
`virtualbox`, `windows-11-home`, `nested-virtualization`, `devops`,
`platform-engineering`, `infrastructure-as-code`, `sre`, `devsecops`
