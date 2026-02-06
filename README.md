# provision-dev-desktop

This project will take a target host and install/configure it to work as a development environment to my exacting needs in a repeatable way.

It expects a recent version of ubuntu to be present on the target host.

## usage

On the target host, install and enable the openssh server, and copy over your public key:

```shell
sudo apt install openssh-server
```

On this host...

Create `credentials/tailscale.login-server` and set the headscale management server address:

```shell
echo 'https://hs.example.com' > ansible/credentials/tailscale.login-server
```

Same for `credentials/tailscale.authkey` to set a valid key for use with headscale:

```shell
echo 'abc123' > ansible/credentials/tailscale.authkey
```

Create an inventory file for the target host:

```yaml
---

all:
  hosts:
    iain-precision5530:
      ansible_host: 192.168.1.231

  children:
    desktop-dev:
      hosts:
        iain-precision5530:
```

Trigger the `provision.sh script with the target host's inventory name. This will first install the required ansible roles & collections. And then run the ansible playbook against the target host:

```shell
./provision.sh precision5530
```
