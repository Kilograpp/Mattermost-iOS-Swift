#!/bin/bash

KEYCHAIN_PATH=.travis/travis.keychain

security list-keychains -s "$PWD/$KEYCHAIN_PATH"
security default-keychain -s "$PWD/$KEYCHAIN_PATH"
security unlock-keychain -p $MATCH_PASSWORD "$PWD/$KEYCHAIN_PATH"


security list-keychains
