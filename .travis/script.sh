if [[ "$TRAVIS_BRANCH" == "development" ]]; then
    fastlane beta
    exit $?
fi

if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    fastlane release
    exit $?
fi

