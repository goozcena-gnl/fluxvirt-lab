# Resource budget

| Layer/component | CPU guidance | Memory guidance | Storage guidance |
|---|---:|---:|---:|
| Ubuntu outer VM base | 0.2–0.5 vCPU | 0.8–1.5 GiB | 12–20 GiB |
| K3s control plane/runtime | 0.5–1.5 vCPU | 1.5–3 GiB | 8–15 GiB |
| Flux controllers | 0.1–0.5 vCPU | 0.3–0.8 GiB | Minimal |
| KubeVirt + CDI idle | 0.5–1.5 vCPU | 1.5–3 GiB | Import scratch space |
| First Ubuntu guest | 2 vCPU | 2 GiB | 12 GiB PVC |
| Demo container | 0.01–0.1 vCPU | 16–64 MiB | Minimal |
| Prometheus + Grafana | 1–2 vCPU | 2–4 GiB | 10–30 GiB |
| Loki/Tempo/OTel | 2–4 vCPU | 4–8 GiB | 20–60 GiB |

## Profiles

- Absolute minimum: 6 vCPU, 12 GiB RAM, 100 GiB disk. No full observability stack.
- Recommended MVP: 8 vCPU, 16 GiB RAM, 150 GiB disk.
- Observability: 10–12 vCPU, 24 GiB RAM, 200 GiB disk.
- Advanced multi-node lab: multiple outer VMs and at least 32 GiB host RAM available to the lab.

Dynamic memory is disabled because predictable memory availability matters when the outer VM hosts Kubernetes and nested VMs. CPU can be overcommitted for a lab, but guest latency and outer-host contention must be measured rather than assumed.
