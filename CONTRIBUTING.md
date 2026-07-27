# Contributing

## Workflow

Changes must be made through a branch and pull request.

Use descriptive branch names:

- `feat/<description>`;
- `fix/<description>`;
- `docs/<description>`;
- `ci/<description>`;
- `chore/<description>`.

## Required local validation

Install ShellCheck, yamllint, kubectl and Kubeconform before running
local validation. The validation script skips unavailable tools, so a
successful exit code is valid evidence only when the output confirms
that all required checks actually ran.

Verify the prerequisites:

```bash
for tool in shellcheck yamllint kubectl kubeconform; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "[FAIL] Required validation tool is unavailable: $tool"
    exit 1
  }
done
```

Run:

```bash
./scripts/validation/validate-repository.sh
```


Server-side KubeVirt validation also requires cluster access and the
`virtualmachines.kubevirt.io` CRD. Review the command output for skipped
checks before reporting local validation as successful.

When the change affects the running platform or workloads, also run:

```bash
RESTART_STABILITY_SECONDS=15 \
  ./scripts/validation/check-workloads.sh
```

## Pull requests

Every pull request must document:

- its objective and scope;
- static validation evidence;
- whether runtime validation was performed;
- security and operational risks;
- an explicit rollback procedure.

Both required GitHub Actions checks must pass before merge.

## Security

Never commit:

- private SSH keys;
- GitHub tokens or PATs;
- kubeconfigs;
- passwords;
- SOPS or age private keys;
- cloud credentials;
- generated files containing secrets.

## Merge policy

The repository uses squash merging and a linear history.
Force pushes and direct updates to `main` are prohibited.
