# Release checklist

> **Status reconciled 2026-08-09:** v0.1.0 was published on 2026-07-27.
> Checked runtime and recovery items reflect the bounded PR #3 and published
> release records; their detailed raw artifacts are not retained in this
> repository. Unchecked items remain unverified rather than implicitly
> complete.

## Repository state

- [x] Release tag targets the release-time `main` commit
- [ ] Working tree is clean
- [x] No unresolved merge conflicts
- [x] Version and date are consistent
- [x] README reflects the current operational state
- [x] Changelog contains the release

## Static validation

- [x] `bash -n` passes
- [x] ShellCheck passes
- [x] yamllint passes
- [x] all Kustomize roots render
- [x] Kubeconform passes
- [ ] server-side VM dry-run passes
- [x] Gitleaks reports no leaks
- [x] Trivy reports no blocking findings

## Runtime validation

- [x] all Flux Kustomizations are Ready
- [x] KubeVirt is Available
- [x] KVM devices are allocatable
- [x] VM and VMI are Running and Ready
- [x] QEMU Guest Agent is connected
- [x] DataVolume is Succeeded
- [x] PVC is Bound
- [x] container Deployment is available
- [x] container restart count remains stable
- [x] VM HTTP endpoint responds
- [x] container HTTP endpoint responds

Run:

```bash
./scripts/validation/validate-repository.sh

RESTART_STABILITY_SECONDS=15 \
  ./scripts/validation/check-workloads.sh
```

## Reproducibility and recovery

- [x] clean-room rebuild starts from a fresh outer Ubuntu VM
- [x] rebuild duration and environment details are recorded
- [x] clean-room static acceptance passes
- [x] clean-room runtime acceptance passes
- [x] VM disk or PVC backup is created
- [x] backup checksum and metadata are recorded
- [x] VM disk or PVC restore is completed
- [x] restored VM passes end-to-end acceptance
- [x] tested procedure is documented in `docs/BACKUP-RESTORE.md`

## Governance

- [x] release change is submitted through a pull request
- [x] both required CI checks pass
- [x] review conversations are resolved
- [x] pull request is squash merged
- [x] direct push protection remains active

## Release publication

- [x] squash commit for the release pull request is present on `main`
- [ ] annotated `v0.1.0` tag independently verified
- [x] tag pushed
- [x] GitHub Release created
- [x] release notes reviewed
- [x] source archives visible
- [x] repository description and topics updated

## Post-release

- [ ] `git describe --tags --always` returns `v0.1.0`
- [ ] Flux reconciles the tagged release commit
- [x] static acceptance still passes
- [ ] runtime acceptance still passes
- [x] release URL opens successfully
