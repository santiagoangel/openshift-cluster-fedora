#!/bin/sh

#start on a fresh Fedora Server install: https://download.fedoraproject.org/pub/fedora/linux/releases/25/Server/x86_64/iso/Fedora-Server-dvd-x86_64-25-1.3.iso
#or Fedora Atomic: https://download.fedoraproject.org/pub/alt/atomic/stable/Fedora-Atomic-25-20170215.1/Atomic/x86_64/iso/Fedora-Atomic-ostree-x86_64-25-20170215.1.iso
#then:
#dnf install -y wget; wget https://raw.githubusercontent.com/santiagoangel/openshift-cluster-fedora/1.4.1/install.sh; sh install.sh
#->answer propmt questions

#install packages
dnf install -y docker git
#dnf install -y ansible
#downgrade ansible to 2.2.0
#dnf downgrade -y ansible
dnf install -y https://kojipkgs.fedoraproject.org//packages/ansible/2.2.0.0/3.fc25/noarch/ansible-2.2.0.0-3.fc25.noarch.rpm
dnf install -y python-cryptography pyOpenSSL.x86_64

#python 3 set as default
alternatives --install /usr/bin/python python /usr/bin/python3 2
alternatives --install /usr/bin/python python /usr/bin/python2 1

#choose python3
alternatives --config python



#clone git projects
cd ~
git clone https://github.com/openshift/openshift-ansible
git clone 1.4.1 https://github.com/santiagoangel/openshift-cluster-fedora

#apply hosts

rm -Rf /etc/hosts
cp openshift-cluster-fedora/hosts /etc/hosts

#ssh keys
ssh-keygen -t rsa
ssh-copy-id root@cloud.successfulsoftware.io

#ansible run

ansible-playbook -i ./openshift-cluster-fedora/inventory-registry-all.erb ./openshift-ansible/playbooks/byo/config.yml -vvv

#then set a new user: e.g. developer
htpasswd /etc/origin/master/htpasswd developer

#open https://cloud.successfulsoftware.io:8443/console/
