#!/bin/bash
set -e
set -u
#set -x

PROFILE=${1:-x86_64}
#PROFILE="RaspberryPi4"

KIWI_BUILD_DIR="/home/vagrant/kiwi-images/"
REPO_DIR="rockstor-installer/"

echo '============================================='
echo 'Starting Build'
echo '============================================='
cd ${REPO_DIR}
if [ -e ${KIWI_BUILD_DIR} ]; then
    sudo rm -rf "${KIWI_BUILD_DIR}/build";
fi
sudo kiwi-ng --profile=Leap15.2."${PROFILE}" --type oem system build --description ./ --target-dir "${KIWI_BUILD_DIR}/"

# Fix the output file names to match RPM version.
RPM_VERSION=$(cat "${KIWI_BUILD_DIR}/build/image-root.log" | sed -n 's/.*Installing: rockstor-\(.*\)\.[a-z0-9_]* .*/\1/p')
source /etc/os-release
BASE_OS=$(echo ${PRETTY_NAME} | cut -d ' ' -f2,3 | tr -d ' ')

for file in $(find ${KIWI_BUILD_DIR} -maxdepth 1 -name "Rockstor-*"); do
  new_file=$(echo "$file" | sed "s/\(Rockstor-\).${PROFILE}-4.0.0-0\(.*\)/\1${BASE_OS}-${PROFILE}-${RPM_VERSION}\2/")
  if [ "$file" != "$new_file" ]; then
    sudo mv -v "$file" "${new_file}"
  fi
done

sudo find ${KIWI_BUILD_DIR} -name "*.iso" -exec cp -v {} /vagrant/ \;
echo '============================================='
echo 'Finished Build'
echo '============================================='
