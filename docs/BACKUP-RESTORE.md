# Backup, restore, and rebuild

This document describes the VM-disk recovery exercise validated for the
FluxVirt Lab v0.1.0 release.

Evidence-retention boundary: this document preserves the run-specific marker,
backup SHA-256 and tested sequence, while the 22 detailed recovery artifacts
remain outside the repository. Treat the result as one bounded operator record,
not as proof of recurring backup automation or independently reproducible
disaster recovery.

Git stores the desired Kubernetes state, scripts and documentation. It does
not back up PVC data, private SSH keys, SOPS age keys, kubeconfig files,
tokens or other credentials.

## Scope and limitations

The validated workflow covers one manual backup and isolated restore of the
`ubuntu-legacy-web` KubeVirt virtual machine.

It demonstrates:

- VM-disk export with gzip and SHA-256 verification;
- upload into a separate CDI DataVolume and PVC;
- read-only restored-disk inspection with libguestfs;
- construction of a halted restored VM without replaying cloud-init;
- isolated first boot and QEMU Guest Agent validation;
- exact HTTP verification through a temporary local port-forward;
- removal of all temporary restored resources;
- continued health of the protected source workload.

It does not provide recurring backups, high availability, distributed
storage, live migration or production disaster recovery.

## Preconditions

Before starting:

1. Keep the source VM, DataVolume and PVC intact.
2. Confirm that the source VM and VMI are `Running` and `Ready`.
3. Confirm that the source DataVolume is `Succeeded`.
4. Confirm that the source PVC is `Bound`.
5. Record the source VM, VMI, DataVolume, PVC and PV identities.
6. Record the source Service UID, ClusterIP and NodePort assignments.
7. Verify that all Flux Kustomizations are active and `Ready`.
8. Run the canonical runtime acceptance script.
9. Provide enough storage for the compressed export and restored disk.
10. Use a `virtctl` version compatible with the installed KubeVirt version.

Keep credentials and private keys outside both Git and evidence transcripts.

## Source workload protection

The source workload is:

```text
Namespace:  vm-workloads
VM:         ubuntu-legacy-web
DataVolume: ubuntu-legacy-web-rootdisk
PVC:        ubuntu-legacy-web-rootdisk
```

Record its identities before starting:

```bash
namespace='vm-workloads'
source_vm='ubuntu-legacy-web'
source_dv='ubuntu-legacy-web-rootdisk'
source_pvc='ubuntu-legacy-web-rootdisk'

kubectl -n "$namespace"   get vm "$source_vm"   -o jsonpath='{.metadata.uid}'

kubectl -n "$namespace"   get datavolume "$source_dv"   -o jsonpath='{.metadata.uid}'

kubectl -n "$namespace"   get pvc "$source_pvc"   -o jsonpath='{.metadata.uid}{" "}{.spec.volumeName}'
```

Do not patch, rename, replace or delete the source storage during the
exercise.

## VMExport backup creation

Use a temporary KubeVirt VMExport compatible with the installed KubeVirt
release.

Inspect the local command syntax before creating or downloading an export:

```bash
virtctl vmexport create --help
virtctl vmexport download --help
```

The export must:

- target only the protected source VM or its root PVC;
- leave the source storage identities unchanged;
- write the downloaded artifact outside the Git working tree;
- avoid persisting temporary VMExport access credentials;
- be removed after the download and integrity checks complete.

## Download and SHA-256 verification

Store the backup outside the repository:

```bash
backup_root="$HOME/fluxvirt-backups/v0.1.0"
mkdir -p "$backup_root"
```

Verify the compressed artifact and record its checksum:

```bash
gzip -t "$backup_file"

sha256sum "$backup_file"   >"${backup_file}.sha256"

sha256sum --check   "${backup_file}.sha256"
```

Record the filename, byte size, checksum, timestamp, source workload names,
source storage identities and platform versions.

## Isolated CDI DataVolume upload

Upload the disk into a new DataVolume and PVC whose names cannot conflict
with the source workload.

The validated restored storage used:

```text
DataVolume: ubuntu-legacy-web-restored-rootdisk
PVC:        ubuntu-legacy-web-restored-rootdisk
```

Inspect the installed client syntax before upload:

```bash
virtctl image-upload --help
```

Require:

- restored DataVolume phase `Succeeded`;
- restored PVC phase `Bound`;
- restored DataVolume UID different from the source UID;
- restored PVC UID different from the source UID;
- restored PV different from the source PV;
- no VM, VMI or active Pod using the restored PVC before inspection.

## Offline read-only libguestfs verification

Inspect the restored disk before creating or booting a restored VM.

Use the KubeVirt libguestfs tooling compatible with the installed release and
keep filesystem inspection read-only.

Verify:

1. the expected virtual disk size;
2. the detected root filesystem;
3. the system marker;
4. the web marker;
5. the expected nginx page;
6. a successful inspection exit code;
7. removal of the inspection Pod;
8. complete restored-PVC detachment after inspection.

The accepted run selected `/dev/sda1` as the root filesystem and matched both
marker files exactly.

## Halted restored-VM construction

Create the restored VM with `runStrategy: Halted`.

Its manifest must:

- reference the restored PVC directly;
- contain no DataVolume template;
- contain no cloud-init volume;
- contain no reference to the source DataVolume or PVC;
- contain no Flux controller ownership;
- create no Service or NodePort;
- remain without a VMI until halted-state validation passes.

Excluding cloud-init prevents first-boot provisioning from being replayed
against an already configured restored disk.

## Firmware and storage identity isolation

Do not copy the source firmware UUID or serial into the restored VM.

Allow KubeVirt to generate new values, then confirm that the restored
firmware UUID and serial differ from the source values.

Also verify that:

- the root volume references only the restored PVC;
- restored and source DataVolume, PVC and PV identities differ;
- the restored PVC has no active user while the VM is halted;
- no restored Service or NodePort exists.

## First boot and guest-agent validation

After halted-state checks pass, set the restored VM to
`runStrategy: Always`.

Wait for:

- VM printable status `Running`;
- VM readiness `true`;
- VMI phase `Running`;
- VMI condition `Ready=True`;
- QEMU Guest Agent condition `AgentConnected=True`;
- exactly one `virt-launcher` Pod using the restored PVC.

Prove runtime isolation with distinct VMI UIDs, interface MAC addresses,
launcher-Pod UIDs or IPs, and storage identities. Treat guest IP addresses as
network-mode-specific information rather than a universal uniqueness gate.

## Temporary `virtctl port-forward` HTTP verification

Do not create a restored Service or NodePort.

Bind the temporary tunnel only to loopback:

```bash
virtctl port-forward   "vm/${restored_vm}/${namespace}"   "${local_port}:80"   --address=127.0.0.1
```

Verify the marker and page:

```bash
curl   --fail   --silent   --show-error   "http://127.0.0.1:${local_port}/restore-marker.txt"

curl   --fail   --silent   --show-error   "http://127.0.0.1:${local_port}/"
```

The marker must match exactly and the page must contain:

```html
<h1>FluxVirt KubeVirt VM</h1>
```

Terminate the tunnel and prove that its local port is no longer reachable.

## Canonical runtime acceptance

With the restored VM running, execute:

```bash
RESTART_STABILITY_SECONDS=15   ./scripts/validation/check-workloads.sh
```

The accepted result ends with:

```text
[PASS] End-to-end FluxVirt workload acceptance passed.
```

The source workload, source Service and all nine Flux Kustomizations must
remain healthy during the restored-VM test.

## Cleanup of restored VM and storage

After evidence capture:

1. Patch the restored VM to `runStrategy: Halted`.
2. Wait for its VMI to disappear.
3. Wait for complete restored-PVC detachment.
4. Delete the restored VM.
5. Delete the restored DataVolume.
6. Wait for the restored PVC and PV to be reclaimed.
7. Confirm that no restored Pod, Service or NodePort remains.

Do not delete any source VM, VMI, DataVolume, PVC, PV or Service.

## Post-cleanup source and Flux verification

After cleanup, verify:

- source VM, VMI, DataVolume, PVC and PV identities are unchanged;
- source Service UID, ClusterIP and ports are unchanged;
- source VM remains `Ready`;
- source VMI remains `Running`;
- the source marker still matches;
- all nine Flux Kustomizations remain active and `Ready`;
- Flux remains at the protected `main` revision;
- canonical runtime acceptance still passes;
- backup gzip and SHA-256 verification still pass;
- the Git working tree remains clean.

## Evidence artifacts

The clean-room exercise produced 22 hashed evidence artifacts covering:

- export and upload planning;
- isolated DataVolume and PVC creation;
- libguestfs attempts, findings and accepted inspection;
- halted restored-VM construction;
- runtime and launcher-Pod identities;
- first boot and temporary port-forward verification;
- canonical acceptance with the restored VM running;
- cleanup and post-cleanup acceptance.

The inventory is stored outside the repository:

```text
$HOME/fluxvirt-v0.1.0-cleanroom/isolated-restore-evidence-inventory.tsv
```

### Run-specific validated values

These identify the accepted v0.1.0 clean-room exercise. They are evidence
values, not reusable configuration constants.

```text
Marker:
fluxvirt-restore-20260726T105541Z-197f8a4d

Backup SHA-256:
96c57a1f29bd25d60453e4ff8b8a0654936f7410e461dbfe8a01e800386febf2
```

## Recovery limitations

This exercise validates recovery of one VM disk while the original
single-node lab remains available.

It does not prove:

- recovery after physical loss of the local-path node;
- crash-consistent application recovery during uncontrolled guest writes;
- automated scheduling or retention;
- off-site backup durability;
- recovery of excluded secrets and identities;
- multi-node failover;
- production recovery-time or recovery-point objectives.

Hypervisor checkpoints are useful rollback points, but they are not a
substitute for an independently verified VM-disk backup.
