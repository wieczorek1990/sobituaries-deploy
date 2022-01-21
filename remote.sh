#!/bin/bash

set -e

bold="$(tput -T linux bold)"
normal="$(tput -T linux sgr0)"

function print {
  echo "${bold}$1${normal}"
}

tar xfz /root/sobituaries.tar.gz
rm /root/sobituaries.tar.gz
rm -rf /srv/sobituaries/
mv /root/sobituaries /srv/

chown -R root:root /srv/sobituaries/
chcon -Rt httpd_sys_content_t /srv/sobituaries/

cd /srv/sobituaries/

pip install -r requirements.txt

for file in envs/*.sh
do
  source "${file}"
done
rm -rf envs/
export DEPLOY_DATETIME \
       DJANGO_DEBUG \
       DJANGO_SECRET_KEY \
       STRIPE_API_KEY \
       POSTGRES_USERNAME \
       POSTGRES_PASSWORD \
       POSTGRES_HOST

# Do not refactor to bold, normal this is called by exec.
bin/wait localhost -- echo -e '\033[1mDone waiting for PostgreSQL.\033[0m'

cd /srv/sobituaries/sobituaries/

python manage.py collectstatic --noinput
python manage.py migrate --noinput

if pgrep daphne
then
  pkill daphne
fi
nohup daphne sobituaries.asgi:application > /var/log/daphne.log &

rm /root/remote.sh

print 'Done.'
