# Storage strategy

The MVP uses K3s `local-path` storage. It is simple and sufficient for one node, but the VM disk is tied to that node and does not support a credible live-migration or HA claim.

Back up three categories separately:

1. desired state in Git;
2. credentials outside Git;
3. persistent VM disk/application data.

Before advanced multi-node work, compare Longhorn, Rook-Ceph, NFSv4, and CSI block storage against host RAM, fault domains, RWX/block capabilities, snapshot support, and KubeVirt migration requirements. Do not deploy Ceph inside the 16 GiB single-node MVP.
