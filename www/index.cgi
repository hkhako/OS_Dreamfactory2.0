#!/bin/bash

if [[ "$QUERY_STRING" =~ "phpinfo" ]]; then
	export PHPINFO_FILE=${RANDOM}_PHPINFO_TEMP.php
	echo "<?php phpinfo();unlink('${PHPINFO_FILE}'); ?>" > ${PHPINFO_FILE}
	echo "Location: ./${PHPINFO_FILE}

<a href='${PHPINFO_FILE}'>Click to visit ${PHPINFO_FILE}</a>"
	exit
fi

if [[ "$QUERY_STRING" =~ "doitnow" ]]; then
	chmod +x ${OPENSHIFT_REPO_DIR}/misc/make.sh
	nohup ${OPENSHIFT_REPO_DIR}/misc/make.sh > /tmp/makephp &
	sleep 1
	echo "Location: ./?working

<a href='./?working'>Click to refresh</a>"
fi

cd ../..
export RUNTIME_DIR=${PWD}

echo "Content-Type: text/html
X-Powered-By: /bin/bash

<html>
<head>
<title>Installed</title>
</head>
<body>
<h1>Installed</h1>
<p>Building PHP5.5 + Apache + Dreamfactory</p>
<h2>Next...</h2>
<p>"

if [[ -x ${OPENSHIFT_RUNTIME_DIR}/bin/php-cgi ]]; then
	echo "Start coding or test <a href=\"?phpinfo\">phpinfo</a>. <b>Remember to remove index.cgi</b>"
elif [[ -f /tmp/makephp ]]; then
	echo "<p>Still spawning your world...</p>"
	echo "<p>This page shall refresh automatically...</p>"
	echo "<p>Now you can close this page, and come back whenever...</p>"
	echo "<p>Have problem? <a href=https://github.com/laobubu/openshift-php5.5-cgi-apache/issues/new >submit issue.</a></p>"
	echo "<pre style='font-size:.7em;word-break:break-all;font-family:Courier'>"
	tail -1000 /tmp/makephp
	echo "</pre>"
	echo "<script>setTimeout(function(){window.location.reload(true)},10000)</script>"
else
	echo "<p>You can refresh this page to check if the world is ready."
	echo "<p><a href=?doitnow>Run install script</a><p>"
fi

echo "</p></body></html>"