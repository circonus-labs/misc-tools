#!/usr/bin/bash

# compress, gpg encrypt and send to Google nearline storage
xz -T 0 --stdout $1 | gpg -e -r "somerecipient" --always-trust | gsutil cp - gs://destinationbucket/$1.xz.gpg

