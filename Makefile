SHELL := /usr/bin/env bash

.PHONY: help preflight-guest bootstrap-ubuntu bootstrap-k3s install-flux bootstrap-flux vendor validate status

help:
	@printf '%s\n' \
	  'preflight-guest  Validate nested virtualization and /dev/kvm inside Ubuntu' \
	  'bootstrap-ubuntu Install baseline Ubuntu packages and kernel settings' \
	  'bootstrap-k3s    Install the pinned single-node K3s version' \
	  'install-flux     Install and verify the pinned Flux CLI' \
	  'bootstrap-flux   Bootstrap Flux to GitHub; requires environment variables' \
	  'vendor           Download and checksum pinned KubeVirt/CDI manifests' \
	  'validate         Run local static checks and cluster validation when available' \
	  'status           Show Kubernetes, Flux, KubeVirt, CDI and VM status'

preflight-guest:
	./scripts/preflight/check-ubuntu-kvm.sh

bootstrap-ubuntu:
	./scripts/bootstrap/configure-ubuntu.sh

bootstrap-k3s:
	./scripts/bootstrap/install-k3s.sh

install-flux:
	./scripts/bootstrap/install-flux-cli.sh

bootstrap-flux:
	./scripts/bootstrap/bootstrap-flux.sh

vendor:
	./scripts/vendor/vendor-platform-manifests.sh

validate:
	./scripts/validation/validate-repository.sh

status:
	./scripts/validation/check-platform.sh
