
##RedHat OpenShift - DIY Dreamfactory 2.0 Cartridge
=======
### Acknowledgment

This project is based on laobubu's php installation script: https://github.com/laobubu/openshift-php5.5-cgi-apache

### Introduction
The new Dreamfactory2.0 is just out of beta (as in yesterday to when this file was written).  The new 2.0 added OAuth services which are very useful.  I had been trying to install 2.0 beta to OpenShift.  However, it requires PHP 5.5, which is not in the list of OpenShift pre-made Cartridges.  So, I decided to DIY.  The process isn't smooth at all, took me a week or two to find solutions to all issues.  Many errors had occured and dependency missing during the process.  Hope you find this DIY cartridge useful.  

### Requirment

1. OpenShift account, goto http://openshift.redhat.com
2. Github account, goto https://github.com

### Installation - Build PHP and Dreamfactory

1. Goto OpenShift web console
2. Create a new app with DIY cartridge, the source put:   https://github.com/hkhako/OS_Dreamfactory2.0.git
3. After the app is created, goto the OpenShift web console and add mysql5.5 cartridge
4. Goto your app's url, that is:  https://"<"app">"-"<"account">".rhcloud.com
5. Click "Run installation script" link at the bottom of page
6. Wait for 40+ minutes

### Installation - Configure Dreamfactory

7. SSH to your app,  the SSH command can be found at your ( OpenShift Web Console ) > <Your APP> > click "Want to log in to your application?"  >  A new box with the command will appears
8. Setup Dreamfactory by running the following commands, during which it will ask for github token and admin credentials, just follow the promoted instructions:

	export PATH=${OPENSHIFT_HOMEDIR}/app-root/runtime/bin:$PATH
	
	alias php='~/app-root/runtime/bin/php'
	
	cd ${OPENSHIFT_HOMEDIR}/app-root/runtime/repo/dreamfactory
	
	php $OPENSHIFT_DATA_DIR/bin/composer install --no-dev
	
	php artisan dreamfactory:setup
	
	<Enter your admin credentials>

9. Your Dreamfactory2.0 is up and running, goto your app's url to use it.


### Note

Sometimes the SQL parameters are not set in the /dreamfactory/.env file, despite the installation script has the instructions.  If that is the case, you will need to run the following commands with SSH:
	chmod -R 2777 .env-dist
	sed -i '/DB_DRIVER=/ c\DB_DRIVER=mysql' .env-dist
	sed -i '/DB_HOST=/ c\DB_HOST='$OPENSHIFT_MYSQL_DB_HOST'' .env-dist
	sed -i '/DB_PORT=/ c\DB_PORT='$OPENSHIFT_MYSQL_DB_PORT'' .env-dist
	sed -i '/DB_USERNAME=/ c\DB_USERNAME='$OPENSHIFT_MYSQL_DB_USERNAME'' .env-dist
	sed -i '/DB_PASSWORD=/ c\DB_PASSWORD='$OPENSHIFT_MYSQL_DB_PASSWORD'' .env-dist
	sed -i '/DB_DATABASE=/ c\DB_DATABASE='$OPENSHIFT_APP_NAME'' .env-dist
	cp .env-dist .env
	chmod -R 0600 .env-dist
	chmod -R 0600 .env
