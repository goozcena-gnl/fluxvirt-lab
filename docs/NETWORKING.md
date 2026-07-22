# Networking

## MVP recommendation

Use the first VirtualBox adapter in **NAT** mode with explicit host port-forwarding rules. Ubuntu normally receives an address such as `10.0.2.15` through DHCP, but the project does not rely on that address from Windows.

Windows reaches the lab through loopback forwards:

| Purpose | Windows endpoint | Ubuntu/Node endpoint |
|---|---|---|
| Ubuntu SSH | `127.0.0.1:2222` | `22` |
| Kubernetes API, optional | `127.0.0.1:6443` | `6443` |
| Container demo | `127.0.0.1:30081` | `30081` |
| KubeVirt guest HTTP | `127.0.0.1:30080` | `30080` |
| KubeVirt guest SSH | `127.0.0.1:30022` | `30022` |

Traffic path:

```text
Windows 127.0.0.1:<forwarded-port>
  → VirtualBox NAT
  → Ubuntu Server NAT interface
  → K3s NodePort or SSH
  → container pod or KubeVirt VMI
```

KubeVirt uses pod-network masquerade for the first VM. The Service selects the VMI using `kubevirt.io/domain`.

## Why NAT first

- It works without depending on Wi-Fi bridge support.
- It avoids exposing the lab directly to the home LAN.
- It avoids home-router DHCP conflicts.
- It creates stable Windows endpoints even when the Ubuntu DHCP address changes.
- It is reproducible through `VBoxManage`.

## Optional host-only adapter

Add a second host-only adapter only in the intermediate phase when direct host-to-Ubuntu addressing is useful. Do not use bridged networking as the MVP default because Wi-Fi drivers, VPN clients, and managed networks can constrain it.

## Firewall

The Ubuntu baseline permits SSH, the Kubernetes API, and NodePort traffic from the VirtualBox NAT subnet `10.0.2.0/24`. Review the detected interface and source addresses before tightening these rules further.

MetalLB is intentionally excluded from the MVP because NAT forwarding plus NodePort already proves end-to-end connectivity with less address-management risk.
