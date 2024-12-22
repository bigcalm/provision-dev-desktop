# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    if Vagrant.has_plugin?("vagrant-hostmanager")
        config.hostmanager.enabled = true
        config.hostmanager.manage_host = true
        config.hostmanager.manage_guest = true
        config.hostmanager.ignore_private_ip = false
        config.hostmanager.include_offline = true
    end

    # Forward the SSH agent so that we can use ansible on the VM to run provisioning/deploy on remote servers,
    # while using the SSH keys on the host machine.
    config.ssh.forward_agent = true

    config.vm.define "desktop-dev-vm" do |node|
        node.vm.box = "bento/ubuntu-24.04"

        node.vm.hostname = "desktop-dev-vm"

        if Vagrant.has_plugin?("vagrant-vbguest")
            # Set this to false if the vbguest plugin fails to compile guest additions
            # Set it to true (or comment out) to occasionally test the plugin
            node.vbguest.auto_update = false
        end

        node.vm.provider "virtualbox" do |vb|
            vb.memory = "8192"
            vb.cpus = 4
            vb.gui = true
        end

        node.vm.provision "shell", inline: "apt-get update -y && apt-get dist-upgrade -y"
        node.vm.provision "shell", inline: "if ! command -v ansible; then apt-get install -y ansible; fi"

        node.vm.provision "shell", inline: "chmod 0600 ~vagrant/.ssh/*"

        node.vm.provision "shell", inline: "apt-get install kubuntu-desktop -y"

        # Invoke ansible-playbook to provision the Vagrant machine, from the Vagrant machine
        node.vm.provision "ansible_local" do |ansible|
            ansible.groups = {
                "vagrant" => "desktop-dev-vm",
                "desktop-dev" => "desktop-dev-vm"
            }
            ansible.provisioning_path = "/vagrant/ansible"
            ansible.galaxy_role_file = "requirements.yml"
            ansible.galaxy_roles_path = "roles"
            ansible.playbook = "provision.yml"
#             ansible.verbose = "vvv"
        end


    end
end
