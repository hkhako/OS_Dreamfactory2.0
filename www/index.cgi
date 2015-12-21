#!/bin/bash

if [[ "$QUERY_STRING" =~ "phpinfo" ]]; then
	export PHPINFO_FILE=${RANDOM}_PHPINFO_TEMP.php
	echo "<?php phpinfo();unlink('${PHPINFO_FILE}'); ?>" > ${PHPINFO_FILE}
	echo "Location: ./${PHPINFO_FILE}

<a href='${PHPINFO_FILE}' target="_blank">Click to check ${PHPINFO_FILE}</a>"

fi

if [[ "$QUERY_STRING" =~ "doitnow" ]]; then
	chmod +x ${OPENSHIFT_REPO_DIR}/misc/make.sh
	nohup ${OPENSHIFT_REPO_DIR}/misc/make.sh > /tmp/make_log &
	sleep 1
	echo "Location: ./?working

<a href='./?working'>Click to refresh</a>"
fi

if [[ "$QUERY_STRING" =~ "finalize" ]]; then
	chmod +x ${OPENSHIFT_REPO_DIR}/misc/finalize.sh
	nohup ${OPENSHIFT_REPO_DIR}/misc/finalize.sh > /tmp/finalize_log &
	sleep 1
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
<h1>Installation</h1>
<p>Installing PHP5.5 + Apache + Dreamfactory</p>
<h2>Next...</h2>
<p>"

if [[ -x ${OPENSHIFT_RUNTIME_DIR}/bin/php-cgi ]]; then
	echo "Test condition <a href=\"?phpinfo\">phpinfo</a>. "
	echo "<script>setTimeout(function(){window.location.reload(true)},10000)</script>"
	
	if [[ -x ${OPENSHIFT_RUNTIME_DIR}/repo/www/index.cgi ]]; then
		echo "<p><a href=?finalize>Click here to finalize and remove index.cgi</a><p>"

	else
		echo "Finalized"
	fi
elif [[ -f /tmp/make_log ]]; then
	echo "<p>Still spawning your world...</p>"
	echo "<p>This page shall refresh automatically.</p>"
	echo "<p>Come back in around an hour.</p>"
	echo "<pre style='font-size:.7em;word-break:break-all;font-family:Courier'>"
	tail -1000 /tmp/make_log
	echo "</pre>"
	echo "<script>setTimeout(function(){window.location.reload(true)},10000)</script>"
else
	echo "<p>You can refresh this page to check if the world is ready."
	echo "<p><a href=?doitnow>Run install script</a><p>"
fi

echo "</p></body></html>"
