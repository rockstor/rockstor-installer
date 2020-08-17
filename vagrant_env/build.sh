#!/bin/bash
set -e
set -u
#set -x

VAGRANT_HOST="rockstor"

vagrant up ${VAGRANT_HOST}

VAGRANT_PATH="/home/vagrant"
#vagrant ssh -c "ls -l ${VAGRANT_PATH}" ${VAGRANT_HOST}

CODE_PATH="${VAGRANT_PATH}"
echo "$(basename ${BASH_SOURCE[0]}): CODE_PATH is '${CODE_PATH}'"

vagrant ssh -c "cd ${CODE_PATH}; /vagrant/run_kiwi.sh" ${VAGRANT_HOST}