# provision-dev-desktop

Provisions a fresh Ubuntu desktop into a personal development environment, in a repeatable way.

## Setup

- Target prerequisites: openssh-server installed and running, and the user `iain` set up for passwordless sudo. Documented in `README.md`.
- Before provisioning, create `ansible/credentials/tailscale.login-server` and `ansible/credentials/tailscale.authkey`.
- Galaxy roles install automatically through `./provision`. Never edit them: `./provision` reinstalls them with `-f`, so any change is lost.

## Commands

- Provision a host: `./provision <TARGET_IP>`
- Run the playbook alone: `ansible-playbook ansible/provision.yml -i <TARGET_IP>,`
- Install the pinned roles only: `ansible-galaxy install -f -r ansible/requirements.yml -p ansible/roles`
- Syntax check: `ansible-playbook ansible/provision.yml --syntax-check -i <TARGET_IP>,`
- Spin up the test VM: `vagrant up` (box `bento/ubuntu-26.04`)

## Conventions

- One role per concern under `ansible/roles/`. Custom roles are committed; Galaxy roles are gitignored.
- Variables live in `ansible/group_vars/all.yml`. Override third-party role behaviour there, never inside the installed role.
- User-level config runs with `become_user: '{{ dev_user }}'` and `become: yes`.
- Secrets load through the `password` lookup from `ansible/credentials/`.
- Commented lines in `ansible/provision.yml` are toggles for optional roles.
- YAML indents two spaces.
- The control node must have the `community.general` collection installed for the snap tasks.

## Review process

Run this before provisioning work against a new or changed target OS release. Do not run the provisioner during a review unless the user asks.

1. Record the target codename (current target: Ubuntu 26.04, `resolute`).
2. Enumerate every package installed through apt, from every role, including the `vars/` and `defaults/` of the pinned Galaxy roles.
3. Verify each package against the archive index `archive.ubuntu.com/ubuntu/dists/<codename>/{main,universe}/binary-amd64/Packages.gz`. Never use `packages.ubuntu.com`: it returns 200 for packages that do not exist.
4. Verify every third-party apt repository: the `dists/<codename>/Release` file and the GPG key URL must both resolve for the codename.
5. Verify every downloaded binary URL and every snap name against its source.
6. Check the pinned roles in `ansible/requirements.yml` for newer tags, and confirm each vendor repo supports the codename.
7. When the target is reachable, run a read-only resolution check over SSH: `apt-get -s install <all packages>`. The simulation makes no changes.

## Security and secrets

- Never run commands on target hosts unless the user gives a direct instruction to do so for that occasion. The instruction does not carry over to later sessions.
- Do not print the contents of files under `ansible/credentials/`.
- `tailscale.authkey` and `tailscale.login-server` are gitignored.
- `ansible/credentials/vagrant-ansible_become_password` is committed; treat it as the dev-VM password only.

## Gotchas

- nerd-fonts flattened its `patched-fonts` tree. Paths in `nf_single_fonts` must not include the weight subdirectory (`Meslo/S/...`, not `Meslo/S/Regular/...`).
- Ubuntu 26.04 dropped `libpcre3-dev`, `php8.5-imap`, and `php8.5-opcache`. `php_packages` in `group_vars/all.yml` lists the installable set for the geerlingguy.php role.
- `docker_apt_repository`, `docker_apt_arch`, and the apt override lines in `group_vars/all.yml` are dead config for `geerlingguy.docker` 8.0.0, which builds the repo from `ansible_facts.distribution_release`.
- `firefox-l10n-en-gb` lives in the `binary-all` index of the Mozilla repo. Check that index, not `binary-amd64`.
- The `fish` role installs the tide prompt and the `powerline-go` role defines `fish_prompt`; tide wins because fish sources `config.fish` before the functions directory.
- `mkcert` is required by the ddev role and is installed from `basic-utils`.