#!/bin/sh

# generate a random token
function token {
  head -c 4096 /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
}

# generate random uuid
function uuid {
  head -c 4096 /dev/urandom | tr -dc 'a-f0-9' | fold -w 32 | head -n 1
}

# ask the system for a free port
function get_free_port {
  python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()'
}


echo Setting up Hello CouchDB:


CONFIG_FILENAME="$XDG_CONFIG_HOME/hello-couchdb.ini"
VM_ARGS_FILENAME="$XDG_CONFIG_HOME/vm.args"
INI_FILENAME="$XDG_CONFIG_HOME/local.ini"

HOST="127.0.0.1"
PORT=$(get_free_port)
USERNAME="admin"
PASSWORD="$(token)"

URL="http://$HOST:$PORT"
ADMIN_URL="http://$USERNAME:$PASSWORD@$HOST:$PORT"

NAME="$(uuid)@$HOST"
COOKIE="$(token)"
UUID="$(uuid)"
SECRET="$(token)"


echo * creating $CONFIG_FILENAME
cat << EOF > $CONFIG_FILENAME
# This is the configuration for Hello CouchDB.
# Created by $(basename $0) on $(date)

[couchdb]
# CouchDB server URL including port, eg http://localhost:5984
url = $URL
username = $USERNAME
password = $PASSWORD
EOF


echo * creating $VM_ARGS_FILENAME
cat << EOF > $VM_ARGS_FILENAME
-name $NAME
-setcookie $COOKIE
-kernel inet_dist_use_interface {127,0,0,1}
-kernel error_logger silent
-sasl sasl_error_logger false
+K true
+A 16
+Bd -noinput
-ssl session_lifetime 300
-couch_ini $INI_FILENAME
EOF


echo * creating $INI_FILENAME
cat << EOF > $INI_FILENAME
[couchdb]
uuid = $UUID
database_dir = $XDG_DATA_HOME/couchdb-data
view_index_dir = $XDG_DATA_HOME/couchdb-data
; 1mb = 1024*1024 bytes
max_document_size = 1048576
; 8mb = 8*1024*1024 bytes
max_attachment_size = 8388608

[admins]
$USERNAME = $PASSWORD

[cluster]
n = 1

[chttpd]
bind_address = $HOST
# let the os choose a free port
port = $PORT

[chttpd_auth]
same_site = strict
allow_persistent_cookies = true
secret = $SECRET

[log]
writer = file
file = $XDG_DATA_HOME/couchdb.log
EOF


echo -n "* starting CouchDB"

COUCHDB_ARGS_FILE="$VM_ARGS_FILENAME" /app/couchdb/bin/couchdb &

until $(curl --output /dev/null --silent --head --fail $URL/_up); do
  echo -n '.'
  sleep 0.1
done
echo "ok"

echo -n * creating _users database...
curl --silent -XPUT $ADMIN_URL/_users

echo -n * creating _replicator database...
curl --silent -XPUT $ADMIN_URL/_replicator


echo complete.
