#!/bin/bash
#
# This is the MAKE script which makes PHP and other necessary stuffs.
#
# After creating your amazing app, access SSH and run this script.
# And wait for ~1 hour (depends on your luck)
# And start coding!
#

export OPENSHIFT_RUNTIME_DIR=${OPENSHIFT_HOMEDIR}/app-root/runtime
export ROOT_DIR=${OPENSHIFT_RUNTIME_DIR}	#CARTRIDGE
export LIB_DIR=${ROOT_DIR}/lib
export CONF_DIR=${OPENSHIFT_REPO_DIR}/conf


export DIST_PHP_VER=5.5.18

cd $OPENSHIFT_RUNTIME_DIR
mkdir srv
mkdir srv/libmcrypt
mkdir tmp
cd tmp
				
wget http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
tar -zxf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/libmcrypt \
--disable-posix-threads
make && make install
cd ..
				
rm -f -r libmcrypt-2.5.8
				
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*.tar.gz





pushd ${OPENSHIFT_REPO_DIR}/misc

chmod +x make_php
source make_php
check_php

export COMPOSER_HOME="${OPENSHIFT_DATA_DIR}.composer"
echo $COMPOSER_HOME > ${OPENSHIFT_HOMEDIR}.env/user_vars/COMPOSER_HOME
echo "Installing composer"
curl -s https://getcomposer.org/installer | env - PATH="/usr/bin:$PATH" php -- --install-dir=$OPENSHIFT_DATA_DIR >/dev/null
cd $OPENSHIFT_DATA_DIR
git clone --quiet git://github.com/composer/composer.git composer
cd $OPENSHIFT_DATA_DIR/composer
env - PATH="/usr/bin:$PATH" COMPOSER_HOME="$COMPOSER_HOME" php ${OPENSHIFT_DATA_DIR}composer.phar install >/dev/null
mkdir -p $OPENSHIFT_DATA_DIR/bin
ln -s $OPENSHIFT_DATA_DIR/composer/bin/composer $OPENSHIFT_DATA_DIR/bin/composer
	
	
	
cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo
git pull https://github.com/dreamfactorysoftware/dreamfactory.git dreamfactory
cd dreamfactory
mkdir bootstrap/cache
chmod -R 2775 bootstrap/cache
chmod -R 2775 storage

export PATH=${OPENSHIFT_HOMEDIR}/app-root/runtime/bin:$PATH
alias php='~/app-root/runtime/bin/php'

php $OPENSHIFT_DATA_DIR/bin/composer install --no-dev


sed -i 's/"DB_DRIVER="/DB_DRIVER=mysql/g' .env-dist
sed -i 's/"DB_HOST="/DB_HOST=${OPENSHIFT_MYSQL_DB_HOST}/g' .env-dist
sed -i 's/"DB_PORT="/DB_PORT=${OPENSHIFT_MYSQL_DB_PORT}/g' .env-dist
sed -i 's/"DB_USERNAME="/DB_USERNAME=${OPENSHIFT_MYSQL_DB_USERNAME}/g' .env-dist
sed -i 's/"DB_PASSWORD="/DB_PASSWORD=${OPENSHIFT_MYSQL_DB_PASSWORD}/g' .env-dist
sed -i 's/"DB_DATABASE="/DB_DATABASE=${OPENSHIFT_APP_NAME}/g' .env-dist

cp .env-dist .env
php $OPENSHIFT_DATA_DIR/bin/composer install --no-dev




popd
