# Portfolio positioning

## Repository description

GitOps-managed K3s and KubeVirt lab on Ubuntu Server, running containers and virtual machines through Flux CD inside a reproducible VirtualBox environment on Windows 11 Home.

## Elevator pitch

FluxVirt Lab demonstrates how I build and operate a hybrid Kubernetes platform rather than only deploying applications. It validates a Windows Home → VirtualBox → Ubuntu → KVM virtualization chain, provisions K3s, reconciles KubeVirt and CDI with Flux, and manages both a VM and a hardened container from Git, with CI, security controls, capacity planning, and rebuild evidence.

## CV bullets

- Designed a Windows 11 Home nested-virtualization lab running K3s and KubeVirt on Ubuntu Server with explicit hardware-acceleration preflight gates.
- Automated Oracle VirtualBox VM provisioning, NAT port forwarding, Ubuntu configuration, Kubernetes bootstrap, and validation using PowerShell and Bash.
- Implemented dependency-ordered GitOps reconciliation with Flux CD for platform operators, CDI, virtual machines, and containers.
- Added CI checks for YAML, shell, Kubernetes manifests, and vulnerability scanning with least-privilege workflow permissions.
- Documented architecture, host-mode security trade-offs, capacity, failure modes, backup, and a reproducible recruiter demonstration.

## GitHub topics

`kubernetes`, `kubevirt`, `fluxcd`, `gitops`, `k3s`, `ubuntu`, `virtualbox`, `windows-11-home`, `nested-virtualization`, `devops`, `platform-engineering`, `infrastructure-as-code`, `sre`, `devsecops`
