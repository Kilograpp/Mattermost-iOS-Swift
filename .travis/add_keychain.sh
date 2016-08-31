#!/bin/bash

KEYCHAIN=ios-build.keychain
security create-keychain -p travis $KEYCHAIN
security default-keychain -s $KEYCHAIN
security unlock-keychain -p travis $KEYCHAIN
security set-keychain-settings -t 10000 $KEYCHAIN
security import ./travis/apple.cer -k ~/Library/Keychains/$KEYCHAIN -T /usr/bin/codesign
security import ./travis/dist.p12 -k ~/Library/Keychains/$KEYCHAIN -P $MATCH_PASSWORD -T /usr/bin/codesign

security list-keychains

security find-identity -p codesigning ~/Library/Keychains/$KEYCHAIN
