# Observability plan

## MVP evidence

Use `kubectl get events`, pod logs, Flux status, KubeVirt/ CDI conditions, VMI console/SSH, node pressure, PVC/DV status, and scripted HTTP checks.

## Intermediate

Install Prometheus and Grafana with short retention and one replica. Monitor node CPU/memory/disk, Flux reconciliation, KubeVirt operator/handler/controller availability, VM running state, CDI import failures, and PVC capacity.

## Advanced

Add Loki, Tempo, and OpenTelemetry only after measuring the outer VM budget. Candidate alerts:

- Flux Kustomization not Ready;
- KubeVirt CR unavailable or virt-handler not ready;
- no allocatable KVM device;
- DataVolume failed or stalled;
- node memory/disk pressure;
- VM not running;
- outer disk approaching capacity;
- container/VM HTTP check failing.
