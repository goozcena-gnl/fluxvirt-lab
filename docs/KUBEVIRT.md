# KubeVirt operations

Hardware acceleration is a release gate. Required evidence:

```bash
ls -l /dev/kvm
kubectl get node -o custom-columns=NAME:.metadata.name,KVM:.status.allocatable.devices\.kubevirt\.io/kvm
kubectl -n kubevirt wait kubevirt/kubevirt --for=condition=Available --timeout=15m
```

The first VM imports the Ubuntu 24.04 cloud image through CDI, stores it in a `local-path` PVC, injects cloud-init user data, and attaches to the pod network with masquerade. NodePort Services expose SSH and HTTP through the outer Ubuntu node.

Useful diagnostics:

```bash
kubectl -n vm-workloads get vm,vmi,dv,pvc
kubectl -n vm-workloads describe dv ubuntu-legacy-web-rootdisk
kubectl -n vm-workloads describe vmi ubuntu-legacy-web
kubectl -n kubevirt logs deploy/virt-controller
kubectl -n cdi get pods
```

Software emulation is not enabled by this repository. A separate experiment may document it as degraded, but it cannot satisfy the MVP hardware-acceleration criterion.
