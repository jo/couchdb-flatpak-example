# CouchDB Flatpak Example
Example application with CouchDB included and packaged with [Flatpak](https://flatpak.org/).


The Flatpak comes with modules for
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


(c) 2022 Johannes J. Schmidt
