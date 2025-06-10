# Homelab-as-Code Deployment Guide

## Pre-requisites

READ: https://merox.dev/blog/homelab-as-code/

## Quick Deploy
Run the following command on a clean Debian LXC to set up your infrastructure:
```bash
apt update && apt install -y curl && bash -c "$(curl -fsSL https://raw.githubusercontent.com/mer0x/homelab-as-code/refs/heads/master/deploy_homelab.sh)"
```

**Disclaimer: Kubernetes folder is not completly organized and clean at this moment.**

## Talos + Flux = Kubernetes love [new article on blog this july]
