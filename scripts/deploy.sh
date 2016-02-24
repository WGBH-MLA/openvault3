#!/bin/bash
set -e  # Halt on error
set -vx # Echo each line and each variable

mkdir ~/openvault-deploy
cd ~/openvault-deploy

# 1. AWS

git checkout git@github.com:WGBH/aws-wrapper.git
ruby aws-wrapper/scripts/build.rb --name openvault.wgbh-mla-test.org

# 2. Ansible

git checkout git@github.com:WGBH/mla-playbooks.git
echo '[webservers]' > mla-playbooks/openvault/hosts
ruby aws-wrapper/scripts/ssh_opt.rb --name openvault.wgbh-mla-test.org --just_ips >> mla-playbooks/openvault/hosts
cd mla-playbooks # Error without this: "the role 'gcc' was not found"
ansible-playbook -i openvault/hosts openvault/site.yml --private-key ~/.ssh/openvault.wgbh-mla-test.org.pem
cd ..

# 3. Capistrano

git clone https://github.com/WGBH/openvault3_deploy.git
cd openvault3_deploy

# TODO: Right now capistrano binds a name to an IP in config, which won't work for us going forward.

# So, for right now follow the instructions by hand.

# 4. Index

# Indexing on each machine separately is processor inefficient, but
# - it is simpler
# - and if done in parallel, no slower.

# TODO
