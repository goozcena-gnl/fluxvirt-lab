# GitOps model

Flux bootstraps `clusters/fluxvirt-lab`. Reconciliation order is:

1. namespaces;
2. KubeVirt operator;
3. KubeVirt custom resource;
4. CDI operator;
5. CDI custom resource;
6. workloads.

Every change follows branch → static checks → review → merge → Flux reconciliation → runtime evidence. Platform release manifests are vendored to prevent an upstream URL from changing underneath the desired state. Upgrades occur in a dedicated branch: update pins, vendor assets, inspect diffs, run static checks, deploy to the lab, and record results in an ADR/release note.

Never commit the GitHub token used for bootstrap. After bootstrap, inspect the deploy key and repository permissions and unset the shell variable.
