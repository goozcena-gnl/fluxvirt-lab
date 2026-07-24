# Repository governance

## Protected branch

The default branch is `main`.
Changes to `main` must be introduced through a pull request.

## Required validation

The following GitHub Actions status checks must pass before merge:

- `Static validation`;
- `static-validation`.

`Static validation` performs:

- ShellCheck validation;
- YAML linting;
- Kustomize rendering;
- Kubernetes schema validation with Kubeconform;
- secret scanning with Gitleaks;
- verification of independent Flux ownership.

`static-validation` performs:

- retrieval of the pinned KubeVirt and CDI manifests;
- repository validation;
- a pinned Trivy filesystem scan for HIGH and CRITICAL findings.

Runtime acceptance is executed from the FluxVirt lab with:

```bash
./scripts/validation/check-workloads.sh
```

Runtime results must be documented in the pull request as either:

- tested;
- not tested, with a reason.

## Merge strategy

The repository uses squash merging.
Merge commits and rebase merging are disabled to preserve a simple,
linear project history.

## Branch lifecycle

Feature branches should use descriptive names such as:

- `feat/<description>`;
- `fix/<description>`;
- `docs/<description>`;
- `ci/<description>`;
- `chore/<description>`.

Branches are deleted automatically after merge.

## Administrative safeguards

The default branch must prevent:

- direct pushes;
- force pushes;
- branch deletion;
- merging when required checks fail;
- merging while review conversations remain unresolved.

## Dependency updates

Dependabot checks GitHub Actions dependencies weekly.
Automated dependency pull requests must pass the same required validation
as any other pull request.
