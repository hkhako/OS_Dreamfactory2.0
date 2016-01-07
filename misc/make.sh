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
export MONGODB_DIR=${OPENSHIFT_RUNTIME_DIR}/srv/mongodb

export DIST_PHP_VER=5.5.18

cd $OPENSHIFT_RUNTIME_DIR
mkdir srv
mkdir srv/libmcrypt
mkdir srv/mongodb
mkdir srv/v8js
mkdir srv/v8js/include
mkdir srv/v8js/lib
mkdir srv/libsasl2
#mkdir srv/libsasl2-devel-2.1.26-4
mkdir tmp
cd tmp


# Build libmcrypt		
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



#wget ftp://ftp.dvo.ru/pub/cygwin/64bit/release/cyrus-sasl/libsasl2-devel/libsasl2-devel-2.1.26-4.tar.bz2
#tar -jxf libsasl2-devel-2.1.26-4.tar.bz2
#cd libsasl2-devel-2.1.26-4

#cd ..

#cp -f ../repo/misc/files/mongodb.* ${OPENSHIFT_RUNTIME_DIR}/srv/mongodb

# Build PHP
pushd ${OPENSHIFT_REPO_DIR}/misc
chmod +x make_php
source make_php
check_php
export PATH=${OPENSHIFT_HOMEDIR}/app-root/runtime/bin:$PATH
alias php='${OPENSHIFT_HOMEDIR}/app-root/runtime/bin/php'


# Build SASL
pushd ${OPENSHIFT_RUNTIME_DIR}/tmp
wget ftp://ftp.cyrusimap.org/cyrus-sasl/cyrus-sasl-2.1.26.tar.gz
tar -zxf cyrus-sasl-2.1.26.tar.gz
cd cyrus-sasl-2.1.26
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/libsasl2
make && make install
export MONGODB_SASL=${OPENSHIFT_RUNTIME_DIR}/srv/libsasl2
export SASL_PATH=${OPENSHIFT_RUNTIME_DIR}/srv/libsasl2
cd ..
rm -f -r *.tar.gz
rm -f -r cyrus-sasl-2.1.26


# Build Mongo Driver
pushd ${OPENSHIFT_RUNTIME_DIR}/tmp
git clone https://github.com/mongodb/mongo-php-driver-legacy.git mongo
cd mongo
phpize
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/mongodb \
--enable-developer-flags \
--with-mongodb-sasl=$SASL_PATH
make -j8 all
make install
cp -f -v ./modules/*.* ../../srv/mongodb
cd ..
rm -f -r mongo

# Build MongoDB Driver
pushd ${OPENSHIFT_RUNTIME_DIR}/tmp
git clone https://github.com/mongodb/mongo-php-driver.git mongodb
cd mongodb
git submodule update --init
mkdir include
mkdir ./include/sasl
cp $SASL_PATH/include/sasl/*.* ./include/sasl
cp -f -v ../../repo/misc/file/sasl.h ./include/sasl/sasl.h
phpize
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/mongodb \
--enable-developer-flags \
--with-mongodb-sasl=$SASL_PATH
make -j8 all
make install
cp -f -v ./modules/*.* ../../srv/mongodb
cd..
rm -f -r mongodb


# Build V8JS php driver
pushd ${OPENSHIFT_RUNTIME_DIR}/tmp

git clone https://github.com/v8/v8
cd v8
git checkout tags/3.15.4
make dependencies
svn checkout --force http://gyp.googlecode.com/svn/trunk build/gyp --revision 1501
#make native library=shared
make -j8 all

pushd ${OPENSHIFT_RUNTIME_DIR}/tmp/v8
cp -f -v ./include/v* ${OPENSHIFT_RUNTIME_DIR}/srv/v8js/include/

cp -f -v ./out/native/lib.target/libv8.so ../../srv/v8js/lib/libv8.so


pushd ${OPENSHIFT_RUNTIME_DIR}/tmp/
wget https://pecl.php.net/get/v8js-0.1.3.tgz
tar -zxf v8js-0.1.3.tgz
cd v8js-0.1.3
phpize
./configure  --with-v8js=${OPENSHIFT_RUNTIME_DIR}/srv/v8js
sed -i '1s/^/#define PHP_V8_VERSION "0.1.3" \n/' v8js.cc
make && make install


cp ./modules/* ../../srv/v8js/

sed -i '1s/^/#define PHP_V8_VERSION "0.1.3" \n/' ${OPENSHIFT_REPO_DIR}/conf/php5/php.ini

# Build Composer
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
mkdir dreamfactory
cd dreamfactory
git init
git pull https://github.com/dreamfactorysoftware/dreamfactory.git
mkdir bootstrap/cache
chmod -R 2775 bootstrap/cache
chmod -R 2775 storage

chmod -R 2777 .env-dist
sed -i '/DB_DRIVER=/ c\DB_DRIVER=mysql' .env-dist
sed -i '/DB_HOST=/ c\DB_HOST='${OPENSHIFT_MYSQL_DB_HOST}'' .env-dist
sed -i '/DB_PORT=/ c\DB_PORT='${OPENSHIFT_MYSQL_DB_PORT}'' .env-dist
sed -i '/DB_USERNAME=/ c\DB_USERNAME='${OPENSHIFT_MYSQL_DB_USERNAME}'' .env-dist
sed -i '/DB_PASSWORD=/ c\DB_PASSWORD='${OPENSHIFT_MYSQL_DB_PASSWORD}'' .env-dist
sed -i '/DB_DATABASE=/ c\DB_DATABASE='${OPENSHIFT_APP_NAME}'' .env-dist

cp .env-dist .env
chmod -R 0600 .env-dist
chmod -R 0600 .env
export PHPRC=${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/conf/php5/php.ini

cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo

cd dreamfactory
chmod 2755 composer.json
sed -i '/dist/ c\  "preferred-install": "source"' composer.json
chmod 0700 composer.json
php $OPENSHIFT_DATA_DIR/bin/composer install --no-dev
php artisan key:generate

