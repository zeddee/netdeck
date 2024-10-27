# Netdeck

Container image for troubleshooting networking issues.

Meant to be used with
[`kubectl debug`](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_debug/)

## Usage

```bash
kubectl debug <pod> \
  -ti \
  --image ghcr.io/zeddee/netdeck \
  --target <container> \
  --profile netadmin -- ash
```
