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

Run:

```bash
./scripts/validation/validate-repository.sh
```

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
