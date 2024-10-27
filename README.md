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

## runAsUser

Debug containers may not run as user with
root permissions, which
are required to access NICs etc.

See
[`kubectl debug: profile "sysadmin" does not work as expected when uid != 0 is specified

# 1650`](<https://github.com/kubernetes/kubectl/issues/1650>)

As a workaround, run `kubectl debug`
with a `--custom=./privileged-profile.yml` parameter,
with this yaml file:

```yaml
securityContext:
  runAsUser: 0
  privileged: true
```
