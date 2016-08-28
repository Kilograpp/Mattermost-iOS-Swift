#!/bin/bash

if [[ "$TRAVIS_BRANCH" == "development" ]]; then
    bundle exec pod repo update 
    fastlane beta
    exit $?
else
    bundle exec pod repo update
    fastlane release
    exit $?
fi

