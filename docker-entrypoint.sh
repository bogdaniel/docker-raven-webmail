#!/usr/bin/env sh
set -e

rm -rf config.toml
if [ ! -f config.toml ]; then

	# create default config file in ./config.toml
	node raven create-config;

	sed -i'.bak' "s|port=8635|port=$RAVEN_PORT|" config.toml;
	sed -i'.bak' "s|ssl=false|ssl=$RAVEN_SSL|" config.toml;
	if [ ! "$RAVEN_SSL_CERTIFICATE" = "" ]; then
		sed -i'.bak' "s|# ssl_certificate=\"/path/to/ssl/key.pem\"|ssl_certificate_key=\"$RAVEN_SSL_CERTIFICATE\"|" config.toml;
		sed -i'.bak' "s|# ssl_certificate_key=\"/path/to/ssl/key.pem\"|ssl_certificate_key=\"$RAVEN_SSL_CERTIFICATE_KEY\"|" config.toml;
	fi
	sed -i'.bak' "s|secret_token=\"some super secret value\"|secret_token=\"$RAVEN_SECRET_TOKEN\"|" config.toml;
	sed -i'.bak' "s|mongodb_url=\"mongodb://localhost:27017/raven-webmail\"|mongodb_url=\"$RAVEN_MONGO_DB_URL\"|" config.toml;
	sed -i'.bak' "s|wildduck_api_url=\"http://localhost:8080\"|wildduck_api_url=\"$RAVEN_WILDDUCK_API_URL\"|" config.toml;
	sed -i'.bak' "s|wildduck_api_token=\"same as in wildduck config\"|wildduck_api_token=\"$RAVEN_WILDDUCK_API_TOKEN\"|" config.toml;
	sed -i'.bak' "s|compression=false|compression=$RAVEN_COMPRESSION|" config.toml;

fi

exec "$@"

