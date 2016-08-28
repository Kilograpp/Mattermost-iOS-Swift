#!/bin/bash

if [[ "$TRAVIS_BRANCH" == "development" ]]
    bundle exec pod setup
    bundle exec pod repo update 
    fastlane beta
    exit $?
else
    bundle exec pod setup
    bundle exec pod repo update
    fastlane release
    exit $?
fi

