#!/bin/bash

if [[ "$TRAVIS_BRANCH" == "development" ]]; then
    fastlane beta
    exit $?
else
    fastlane release
    exit $?
fi

