#/usr/bin/env bash

ansible-playbook -i ansible/inventories/$1.yml ansible/provision.yml --ask-become-pass
