# Phase 1 evidence — VirtualBox host installation

Date: 2026-07-22

Status: **VirtualBox host installation verified; outer VM not yet created.**

## Verified on the target workstation

- VirtualBox version: `7.2.14r174565`.
- Host processor: Intel Core i7-14700KF.
- Logical processors: 28.
- Physical cores reported by VirtualBox: 20.
- Hardware virtualization: supported.
- Nested paging: supported.
- Unrestricted guest mode: supported.
- Nested hardware virtualization: supported.
- Physical RAM: approximately 31.8 GiB.
- Free memory at the time of the check: approximately 14.3 GiB.
- Ubuntu Server ISO is present at `C:\ISO\ubuntu-24.04.4-live-server-amd64.iso`.

## Initial creation-script issue

The first VM-creation attempt stopped during PowerShell parsing before any
`VBoxManage` command executed. The string below was ambiguous to Windows
PowerShell because a colon immediately followed a variable reference:

```powershell
"VBoxManage failed with exit code $LASTEXITCODE: ..."
```

It was corrected by capturing the exit code and using a delimited variable:

```powershell
$exitCode = $LASTEXITCODE
"VBoxManage failed with exit code ${exitCode}: ..."
```

Because the failure was a parser error, no partial VirtualBox VM should have
been created by this attempt. This must still be verified with
`VBoxManage list vms` before retrying.

## Still required

- Verify the Ubuntu ISO SHA-256 checksum.
- Verify that no `fluxvirt-lab` VM exists from another/manual attempt.
- Run the corrected creation script.
- Run `check-virtualbox-readiness.ps1`.
- Install Ubuntu Server.
- Verify `vmx`, KVM modules, and `/dev/kvm` inside Ubuntu.
