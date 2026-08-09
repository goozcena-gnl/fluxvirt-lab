# Recruiter demonstration

This demonstration is designed for a 10–15 minute technical discussion.

Every claim must be supported by visible command output or a working
endpoint.

## 1. Present the problem

Explain that Windows 11 Home does not provide the full Hyper-V role and
that KubeVirt requires hardware-backed virtualization.

Show:

- the dedicated Windows lab boot;
- `HypervisorPresent=False`;
- firmware virtualization and SLAT;
- the documented separation between the normal Windows profile and the
  lab profile.

## 2. Prove nested virtualization

On the Windows host, show:

```powershell
VBoxManage showvminfo fluxvirt-lab
```

Inside Ubuntu, show:

```bash
ls -l /dev/kvm
kvm-ok
```

## 3. Show the Kubernetes platform

```bash
kubectl get nodes -o wide
flux get kustomizations -A
```

Explain the dependency order:

1. namespaces;
2. KubeVirt operator and custom resource;
3. CDI operator, custom resource and storage profile;
4. virtual machine and container workloads.

## 4. Run the operational acceptance gate

```bash
RESTART_STABILITY_SECONDS=15 \
  ./scripts/validation/check-workloads.sh
```

Highlight:

- Flux readiness;
- KubeVirt availability;
- allocatable KVM devices;
- VM and VMI readiness;
- DataVolume and PVC state;
- QEMU Guest Agent connection;
- stable container restart count;
- both HTTP responses.

## 5. Show both workload models

```bash
kubectl get vm,vmi,dv,pvc -n vm-workloads
kubectl get deployment,pod,service -n demo
```

Explain that the same Kubernetes control plane operates:

- a persistent Ubuntu virtual machine;
- a stateless hardened container.

## 6. Open the services

```bash
node_ip=$(
  kubectl get nodes \
    -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'
)

test -n "$node_ip"


curl "http://${node_ip}:30080/"
curl "http://${node_ip}:30081/"
```

Optional guest access:

```bash
ssh \
  -i ~/.ssh/fluxvirt_vm_ed25519 \
  -p 30022 \
  devops@"${node_ip}"
```

## 7. Show GitOps ownership

Open:

- `clusters/fluxvirt-lab/`;
- `virtual-machines/ubuntu-legacy-web/`;
- `apps/container-demo/`.

Explain that each workload has an independent Flux Kustomization and
that the obsolete aggregate ownership layer was removed.

## 8. Show CI and governance

Open the GitHub Actions page and show:

- `Static validation`;
- `static-validation`;
- Gitleaks;
- pinned Trivy;
- protected `main`;
- a merged pull request;
- the rejected direct-push evidence.

## 9. Optional live change

Create a branch and modify either:

- the container response;
- the guest Nginx page;
- a safe replica or resource setting.

Open a pull request, wait for both CI checks, merge with squash and show
Flux applying the new revision.

Do not perform a live change unless enough time remains to complete and
verify the full reconciliation.

## 10. Close honestly

State that the project demonstrates GitOps, validation and recovery methods
but is intentionally a single-node laboratory.

Discuss the next engineering steps:

- clean rebuild;
- backup and restore;
- encrypted GitOps secrets;
- policy-as-code;
- observability;
- eventual migration to multi-node Linux or Proxmox infrastructure.
