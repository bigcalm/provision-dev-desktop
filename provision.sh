#!/usr/bin/env bash

set -x

#ansible-galaxy collection install -r ansible/requirements.yml -p ansible/collections
ansible-galaxy install -f -r ansible/requirements.yml -p ansible/roles

ansible-playbook -i ansible/inventories/$1.yml ansible/provision.yml
# --ask-become-pass
