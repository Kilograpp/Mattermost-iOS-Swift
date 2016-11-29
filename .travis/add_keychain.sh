#!/bin/bash

KEYCHAIN=travis.keychain
PASSWORD=travis

security create-keychain -p $PASSWORD $KEYCHAIN
security default-keychain -s $KEYCHAIN
security unlock-keychain -p $PASSWORD $KEYCHAIN
security set-keychain-settings -t 10000 -u $KEYCHAIN

security import .travis/apple.cer -k ~/Library/Keychains/$KEYCHAIN -A
security import .travis/dist.cer -k ~/Library/Keychains/$KEYCHAIN -A
security import .travis/dev.cer -k ~/Library/Keychains/$KEYCHAIN -A
security import .travis/dist.p12 -k ~/Library/Keychains/$KEYCHAIN -P $MATCH_PASSWORD -A
security import .travis/dev.p12 -k ~/Library/Keychains/$KEYCHAIN -P $MATCH_PASSWORD -A

security set-key-partition-list -S apple-tool:,apple: -s -k $PASSWORD $KEYCHAIN

security find-identity -v -p codesigning
