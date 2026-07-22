# Roadmap

## v0.1.0-windows-home-preflight

- BIOS/UEFI evidence
- Windows Home preflight output
- dedicated lab boot entry documented
- Hypervisor ADR

## v0.2.0-virtualbox-ubuntu-lab

- Reproducible VirtualBox VM definition
- Ubuntu Server 24.04.4 installation
- VirtualBox NAT forwarding
- `/dev/kvm` proof

## v0.3.0-kubernetes

- K3s 1.35.6
- Node Ready
- local-path storage validation

## v0.4.0-flux-bootstrap

- Flux 2.9.2
- GitHub bootstrap
- dependency-ordered reconciliations

## v0.5.0-kubevirt-mvp

- KubeVirt 1.8.4
- CDI 1.65.0
- one Ubuntu VM and one container workload
- validation evidence

## v1.0.0-portfolio-release

- CI checks
- diagrams and screenshots
- troubleshooting guide
- clean rebuild exercise
- recruiter demo script

## Intermediate

- SOPS with age
- Kyverno
- Trivy and secret scanning
- Prometheus/Grafana
- backup/restore exercise
- Ansible configuration of the KubeVirt guest
- optional VirtualBox host-only adapter

## Advanced

- multiple outer Ubuntu nodes on dedicated hardware
- KubeVirt migration-capable storage
- network policies and MetalLB
- Loki/Tempo/OpenTelemetry
- self-service VM templates
- migration to Proxmox VE or Linux KVM/libvirt
