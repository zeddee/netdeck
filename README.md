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

## debugging profiles

See
[KEP-1441:kubectl debug](https://github.com/kubernetes/enhancements/tree/master/keps/sig-cli/1441-kubectl-debug#debugging-profiles).

If a container spec overrides has a
`runAsUser` security context set,
you may need to:

- Run `kubectl debug` against the node instead.
  See [Running `tcpdump` on node](#running-tcpdump-on-node)
- Override it.
  See [runAsUser](#runasuser).

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

## Running `tcpdump` on node

If [runAsUser](#runasuser) does not work on a given
container because it refuses to let you run as root,
you will have to run `kubectl debug`
against the owning node instead.

1. Find the network interface that the container is bound on.
   Run `kubectl debug` against the target pod and run `ip link`
   to see what network interface `eth0` is bound to:

   ```bash
   ~ $ tcpdump eth0
   tcpdump: eth0: You don't have permission to perform this capture on that device
   (socket: Operation not permitted)
   ~ $ ip link
   1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
   47: eth0@if48: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP qlen 1000
   link/ether fa:a0:53:eb:8b:6a brd ff:ff:ff:ff:ff:ff
   ```

   Here, you can see that it is bound against `if47` on the node.

1. Run `kubectl debug` with this container image against the node.

   ```bash
   kubectl debug node/<node-name> -ti --image ghcr.io/zeddee/netdeck:main --profile sysadmin -- ash
   ```

1. Find the network interface name:

   ```bash
   $ ip link | grep if47
   48: lxce37f298c3ba2@if47: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP qlen 1000
   ```

1. Run tcpdump against that network interface:

   ```bash
   tcpdump -i lxce37f298c3ba2
   ```

1. (Optional) To verify that you are running tcpdump
   against the right network interface,
   run a `tcpdump` that filters _out_ all traffic
   not to/from the IP address of your target pod.

   ```bash
   tcpdump -i lxce37f298c3ba2 "not host 10.244.26.162"
   ```

   Let it run for a few minutes. If it does not
   capture any packets, then you are capturing
   traffic on the correct network interface.
