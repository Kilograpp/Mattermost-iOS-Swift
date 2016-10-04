#!/bin/bash

if [[ "$TRAVIS_BRANCH" == "development" ]]; then
    bundle exec fastlane beta
    exit $?
else
    bundle exec fastlane release
    exit $?
fi

