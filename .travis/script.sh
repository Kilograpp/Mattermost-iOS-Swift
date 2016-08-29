#!/bin/bash

if [[ "$TRAVIS_BRANCH" == "development" ]]
    fastlane beta
    exit $?
else
    fastlane release
    exit $?
fi

