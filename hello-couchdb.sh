#!/bin/sh

CONFIG_FILENAME="$XDG_CONFIG_HOME/hello-couchdb.ini"

# configure if needed
if [ ! -f $CONFIG_FILENAME ]; then
  setup-hello-couchdb
fi

# load configuration
source <(grep = <(grep -A5 '\[couchdb\]' $CONFIG_FILENAME) | sed 's/ *= */=/g')

# start if not running
if [[ "$(curl --write-out %{http_code} --silent --output /dev/null $url/_up)" -ne 200 ]] ; then
  echo -n "Starting CouchDB"
  
  COUCHDB_ARGS_FILE="$XDG_CONFIG_HOME/vm.args" /app/couchdb/bin/couchdb &

  until $(curl --output /dev/null --silent --head --fail $url/_up); do
    echo -n '.'
    sleep 0.1
  done
  echo "ok"
fi

# use couch
curl --silent $url
