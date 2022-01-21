#!/bin/bash

set -e

bold="$(tput bold)"
normal="$(tput sgr0)"

function print {
  echo "${bold}$1${normal}"
}

DEPLOY_DATETIME=$(date +"%d-%m-%Y+%H:%M:%S")
print "Starting new deploy, date is ${DEPLOY_DATETIME}."

rm -rf sobituaries/
print "Password for git clone:"
git clone git@github.com:wieczorek1990/sobituaries.git

rm -rf sobituaries/.git/

rm -f envs/*.sh
for file in envs/*
do
  python3 preprocess_envs.py "${file}"
done
echo "DEPLOY_DATETIME='${DEPLOY_DATETIME}'" > envs/deploy.sh

cp -r envs sobituaries/
cp envs.website/envs.json sobituaries/website/js/

tar cfz sobituaries.tar.gz sobituaries/
print "Password for scp:"
scp sobituaries.tar.gz root@nekrologi:/root/

print "Password for scp:"
scp remote.sh root@nekrologi:/root/

print "Password for ssh:"
ssh root@nekrologi /root/remote.sh
