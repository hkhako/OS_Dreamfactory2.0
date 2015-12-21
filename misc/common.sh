#!/bin/bash
# This shell script will run before httpd starts.
# You can also change HTTPD_ARGUMENT to append something interesting.

export HTTPD_ARGUMENT="-f ${OPENSHIFT_REPO_DIR}/conf/httpd.conf"

export OPENSHIFT_RUNTIME_DIR=${OPENSHIFT_HOMEDIR}/app-root/runtime

export PATH=${OPENSHIFT_HOMEDIR}/app-root/runtime/bin:$PATH

export PHPRC=${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/conf/php5/php.ini

alias php='${OPENSHIFT_HOMEDIR}/app-root/runtime/bin/php'

cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/dreamfactory

php $OPENSHIFT_DATA_DIR/bin/composer install --no-dev

cd ..

env|>${OPENSHIFT_TMP_DIR}/httpd_temp.conf awk 'BEGIN{FS="="} $1 ~ /^OPENSHIFT/ {print "PassEnv", $1}'