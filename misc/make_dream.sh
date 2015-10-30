cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo
mkdir dreamfactory
cd dreamfactory
git init
git pull https://github.com/dreamfactorysoftware/dreamfactory.git
mkdir bootstrap/cache
chmod -R 2775 bootstrap/cache
chmod -R 2775 storage

sed -i '/DB_DRIVER=/ c\DB_DRIVER=mysql' .env-dist
sed -i '/DB_HOST=/ c\DB_HOST='$OPENSHIFT_MYSQL_DB_HOST'' .env-dist
sed -i '/DB_PORT=/ c\DB_PORT='$OPENSHIFT_MYSQL_DB_PORT'' .env-dist
sed -i '/DB_USERNAME=/ c\DB_USERNAME='$OPENSHIFT_MYSQL_DB_USERNAME'' .env-dist
sed -i '/DB_PASSWORD=/ c\DB_PASSWORD='$OPENSHIFT_MYSQL_DB_PASSWORD'' .env-dist
sed -i '/DB_DATABASE=/ c\DB_DATABASE='$OPENSHIFT_APP_NAME'' .env-dist

cp .env-dist .env

cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo

rm -f -r www

ln -s ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/dreamfactory/public www

export PATH=${OPENSHIFT_HOMEDIR}/app-root/runtime/bin:$PATH
alias php='~/app-root/runtime/bin/php'

php $OPENSHIFT_DATA_DIR/bin/composer install --no-dev

php artisan dreamfactory:setup


