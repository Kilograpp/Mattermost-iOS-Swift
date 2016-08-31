#!/bin/bash

KEYCHAIN=travis.keychain
PASSWORD=travis

security create-keychain -p $PASSWORD $KEYCHAIN
security default-keychain -s $KEYCHAIN
security unlock-keychain -p $PASSWORD $KEYCHAIN
security set-keychain-settings -t 10000 -u $KEYCHAIN

security import .travis/apple.cer -k $KEYCHAIN -T /usr/bin/codesign
security import .travis/dist.cer -k $KEYCHAIN -T /usr/bin/codesign
security import .travis/dist.p12 -k $KEYCHAIN -P $MATCH_PASSWORD -T /usr/bin/codesign

security list-keychains -s $KEYCHAIN
security list-keychains
