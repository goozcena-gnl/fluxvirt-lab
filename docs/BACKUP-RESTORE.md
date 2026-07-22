# Backup, restore, and rebuild

Git contains declarative Kubernetes state, scripts, and documentation. It does not back up a PVC's data or credentials.

## Backup

- Push and tag the repository.
- Export the hypervisor definition and record VM settings.
- Back up SOPS age private keys and SSH private keys offline.
- Quiesce the guest where possible, then back up VM disk/PVC data using a storage-aware process.
- Record checksums and test restoration.

## Restore

1. Recreate the outer VM and Ubuntu baseline.
2. Prove `/dev/kvm`.
3. Install pinned K3s/Flux.
4. Reconcile platform state.
5. Restore persistent VM disk/application data.
6. Run all acceptance tests.

Hypervisor checkpoints are convenient rollback points, not the sole backup. A release is not complete until one clean rebuild and one data-restore exercise are documented.
