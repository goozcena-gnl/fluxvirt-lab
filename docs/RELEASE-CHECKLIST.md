# Release checklist

## Repository state

- [ ] Release branch is based on current `main`
- [ ] Working tree is clean
- [ ] No unresolved merge conflicts
- [ ] Version and date are consistent
- [ ] README reflects the current operational state
- [ ] Changelog contains the release

## Static validation

- [ ] `bash -n` passes
- [ ] ShellCheck passes
- [ ] yamllint passes
- [ ] all Kustomize roots render
- [ ] Kubeconform passes
- [ ] server-side VM dry-run passes
- [ ] Gitleaks reports no leaks
- [ ] Trivy reports no blocking findings

## Runtime validation

- [ ] all Flux Kustomizations are Ready
- [ ] KubeVirt is Available
- [ ] KVM devices are allocatable
- [ ] VM and VMI are Running and Ready
- [ ] QEMU Guest Agent is connected
- [ ] DataVolume is Succeeded
- [ ] PVC is Bound
- [ ] container Deployment is available
- [ ] container restart count remains stable
- [ ] VM HTTP endpoint responds
- [ ] container HTTP endpoint responds

Run:

```bash
./scripts/validation/validate-repository.sh

RESTART_STABILITY_SECONDS=15 \
  ./scripts/validation/check-workloads.sh
```

## Reproducibility and recovery

- [ ] clean-room rebuild starts from a fresh outer Ubuntu VM
- [ ] rebuild duration and environment details are recorded
- [ ] clean-room static acceptance passes
- [ ] clean-room runtime acceptance passes
- [ ] VM disk or PVC backup is created
- [ ] backup checksum and metadata are recorded
- [ ] VM disk or PVC restore is completed
- [ ] restored VM passes end-to-end acceptance
- [ ] tested procedure is documented in `docs/BACKUP-RESTORE.md`

## Governance

- [ ] release change is submitted through a pull request
- [ ] both required CI checks pass
- [ ] review conversations are resolved
- [ ] pull request is squash merged
- [ ] direct push protection remains active

## Release publication

- [ ] squash commit for the release pull request is present on `main`
- [ ] annotated `v0.1.0` tag created from `main`
- [ ] tag pushed
- [ ] GitHub Release created
- [ ] release notes reviewed
- [ ] source archives visible
- [ ] repository description and topics updated

## Post-release

- [ ] `git describe --tags --always` returns `v0.1.0`
- [ ] Flux reconciles the tagged release commit
- [ ] static acceptance still passes
- [ ] runtime acceptance still passes
- [ ] release URL opens successfully
