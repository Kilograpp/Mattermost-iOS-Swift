if [[ "$TRAVIS_BRANCH" == "development" ]]; then
    bundle exec pod repo update 
    fastlane beta
    exit $?
fi

if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    fastlane release
    exit $?
fi

