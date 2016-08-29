#!/bin/bash

security list-keychains -s ".travis/fastlane.keychain"
security default-keychain -s ".travis/fastlane.keychain"
security unlock-keychain -p $MATCH_PASSWORD ".travis/fastlane.keychain"
