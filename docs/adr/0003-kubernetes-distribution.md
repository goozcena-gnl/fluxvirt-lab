# ADR 0003: Kubernetes distribution

- Status: Proposed
- Date: 2026-07-22

## Decision

Use single-node K3s v1.35.6+k3s1 with containerd, Flannel, and local-path-provisioner. Disable bundled Traefik and ServiceLB for the MVP.

## Rationale

K3s runs directly on Ubuntu, has a low resource footprint, avoids another container/VM abstraction layer, and exposes the host `/dev/kvm` path to KubeVirt components more directly than kind or k3d. Kubernetes 1.35 is the center of the current KubeVirt 1.8 support range and is supported by Flux 2.9.

## Consequences

The MVP is not highly available. local-path storage binds VM disks to one node and cannot support meaningful live migration.
