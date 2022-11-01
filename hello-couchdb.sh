#!/bin/sh

URL_CONFIG_FILENAME="$XDG_CONFIG_HOME/couchdb.url"

if [ ! -f $URL_CONFIG_FILENAME ]; then
  configure-couchdb
fi


COUCHDB_URL=$(cat $URL_CONFIG_FILENAME)

status_code=$(curl --write-out %{http_code} --silent --output /dev/null $COUCHDB_URL/_up)

if [[ "$status_code" -ne 200 ]] ; then
  echo -n "Starting CouchDB"
  
  COUCHDB_ARGS_FILE="$XDG_CONFIG_HOME/vm.args" /app/couchdb/bin/couchdb &

  until $(curl --output /dev/null --silent --head --fail $COUCHDB_URL/_up); do
    echo -n '.'
    sleep 0.1
  done
  echo "ok"
fi

curl --silent $COUCHDB_URL

