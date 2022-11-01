#!/bin/sh

function token {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
}

function get_free_port {
  python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()'
}


echo Configuring CouchDB


URL_CONFIG_FILENAME="$XDG_CONFIG_HOME/couchdb.url"
VM_ARGS_FILENAME="$XDG_CONFIG_HOME/vm.args"
INI_FILENAME="$XDG_CONFIG_HOME/local.ini"

HOST="127.0.0.1"
PORT=$(get_free_port)
USERNAME="admin"
PASSWORD="$(token)"

URL="http://$USERNAME:$PASSWORD@$HOST:$PORT"

NAME="$(token)@$HOST"
COOKIE="$(token)"
UUID="$(token)"
SECRET="$(token)"


echo Writing $URL_CONFIG_FILENAME...
cat << EOF > $URL_CONFIG_FILENAME
$URL
EOF


echo Writing $VM_ARGS_FILENAME...
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


echo Writing $INI_FILENAME...
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
