#!/bin/bash

KEYCHAIN_PATH=.travis/travis.keychain

security list-keychains -s "$KEYCHAIN_PATH"
security default-keychain -s "travis.keychain"
security unlock-keychain -p $MATCH_PASSWORD "travis.keychain"

