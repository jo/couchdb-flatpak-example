# CouchDB Flatpak Example
Example [Flatpak](https://flatpak.org/) application with CouchDB included. 

There can be multiple such applications each with their own couches on the same system, so on first start the couch

* gets its own random free port
* a uuid
* a node name
* an admin account

and the configuration gets stored in an ini file in `XDG_CONFIG_HOME`.

The Flatpak comes with modules for
* ICU 71
* Erlang OTP 24
* Spidermonkey 91
* CouchDB 3.2.2


The app is a [little bash script](hello-couchdb.sh), which
* checks for the existence of a file containing the CouchDB URL
* if that does not exist, it [configures CouchDB](configure-couchdb.sh) with unique secret, cookie, node name, uuid and an admin account and chooses a random free port
* starts CouchDB if not running and waits until its up
* requests CouchDB server info and prints it to console


## Setup
Make sure to install the required platforms and extensions:
```sh
flatpak install flathub org.freedesktop.Platform//22.08 \
  org.freedesktop.Sdk//22.08 \
  org.freedesktop.Sdk.Extension.rust-stable//22.08 \
  org.freedesktop.Sdk.Extension.llvm14//22.08
```


## Build 'n' Install
To build the archive and install it in one go, run
```sh
flatpak-builder --user --install --force-clean build-dir com.example.HelloCouchDB.yml
```

Read more at [Flatpak's documentation](https://docs.flatpak.org/en/latest/index.html).


## Run
Now run the app with `flatpak run com.example.HelloCouchDB`


## Kill
Since the app keeps runing CouchDB in the background, you might want to kill it at some point:

```sh
flatpak kill com.example.HelloCouchDB
```

## TODO
* We should include a [cleanup](https://docs.flatpak.org/en/latest/manifests.html#cleanup) step to remove unneeded files from the bundle.
* Spidermonkey and Erlang could maybe compiled with some optimisations?
* Currently CouchDB logs to a file in the user data directory (`~/.var/app/<app-id>/data/couchdb.log`) - we should rotate this somehow or use syslog.


(c) 2022 Johannes J. Schmidt
