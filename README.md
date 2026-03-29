# provision-dev-desktop

This project will take a target host and install/configure it to work as a development environment to my exacting needs in a repeatable way.

It expects a recent version of ubuntu to be present on the target host.

## usage

On the target host, install and enable the openssh server, and copy over your public key:

```shell
sudo apt install openssh-server
```

Also allow the provisioning user to run `sudo` without entering a password:

```shell
echo 'iain ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/iain
```

On this host...

Copy your public SSH key to the target server:

```
ssh 192.168.56.7 mkdir -p ~/.ssh
scp ~/.ssh/id_ed25519.pub 192.168.56.7:.ssh/authorized_keys
```

Create `credentials/tailscale.login-server` and set the headscale management server address:

```shell
echo 'https://hs.example.com' > ansible/credentials/tailscale.login-server
```

Same for `credentials/tailscale.authkey` to set a valid key for use with headscale:

```shell
echo 'abc123' > ansible/credentials/tailscale.authkey
```

Trigger the `provision` script with the target host IP address. This will first install the required ansible roles & collections. And then run the ansible playbook against the target:

```shell
./provision 192.168.56.7
```
