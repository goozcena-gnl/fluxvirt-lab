# Recruiter demonstration

1. Show the Windows 11 Home host preflight and `HypervisorPresent=False` in the dedicated lab boot.
2. Show `VBoxManage showvminfo fluxvirt-lab` and the enabled nested-hardware-virtualization setting.
3. Connect with `ssh -p 2222 <ubuntu-user>@127.0.0.1` and show `ls -l /dev/kvm` plus `kvm-ok`.
4. Show `kubectl get nodes -o wide`.
5. Show `flux get kustomizations -A`.
6. Show KubeVirt/CDI readiness and allocatable KVM devices.
7. Open the Git manifest for `ubuntu-legacy-web`.
8. Change the Nginx page in cloud-init or scale the container demo through a pull request.
9. Reconcile and show the resulting resource state.
10. Show the KubeVirt VM, VMI, DataVolume, PVC, and Service.
11. Open `http://127.0.0.1:30080` and `http://127.0.0.1:30081`.
12. Show CI validation and a policy/Trivy result.
13. Close with the architecture diagram, Windows Home limitation, and migration roadmap.

Do not claim that a step succeeded unless command output or a visible endpoint proves it.
