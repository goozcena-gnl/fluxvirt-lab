# Security

## Implemented controls

### Repository and delivery

- GitHub Actions permissions restricted to `contents: read`;
- third-party actions pinned to immutable commit SHAs;
- Gitleaks scans the complete Git history;
- Trivy scans the repository for HIGH and CRITICAL findings;
- GitHub secret scanning and push protection are enabled;
- Dependabot version and security updates are enabled;
- `main` requires pull requests and both CI security checks;
- force pushes and branch deletion are blocked;
- review conversations must be resolved before merge.

### Credentials and secrets

The repository must not contain:

- passwords;
- PATs or API tokens;
- private SSH keys;
- kubeconfigs;
- SOPS or age private keys;
- cloud credentials;
- generated files containing secrets.

The KubeVirt guest SSH private key is stored outside the repository.

### Workloads

The container workload uses:

- a non-root user;
- dropped Linux capabilities;
- a read-only root filesystem;
- `RuntimeDefault` seccomp;
- disabled service-account token mounting;
- CPU and memory requests and limits;
- readiness and liveness probes.

### Supply chain

- component versions are pinned;
- upstream KubeVirt and CDI manifests are vendored;
- Repository CI checksum-verifies downloaded kubectl, Kubeconform,
  and Gitleaks release artifacts;
- mutable GitHub Action tags are prohibited for security-sensitive jobs.

## Threat boundaries

Treat the following as distinct trust boundaries:

- Windows host;
- VirtualBox hypervisor;
- outer Ubuntu VM;
- Kubernetes API;
- Flux deployment credentials;
- privileged KubeVirt components;
- CDI image sources;
- cloud-init data;
- KubeVirt guest;
- guest SSH credentials.

`/dev/kvm` intentionally exposes hardware virtualization and must not be
made broadly writable.

## Planned improvements

- SOPS with age for encrypted GitOps secrets;
- Kyverno policy enforcement;
- Kubernetes NetworkPolicies;
- SBOM generation;
- image signing and signature verification;
- dedicated vulnerability triage documentation;
- periodic credential and Git-history audits.

## Reporting security issues

Do not disclose active credentials or exploitable findings in a public
issue.

Revoke or rotate an exposed credential first, preserve relevant
evidence, and then document the remediation without reproducing the
secret.
