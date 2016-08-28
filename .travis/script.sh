if [[ "$TRAVIS_BRANCH" == "development" ]]; then
    bundle exec pod repo update 
    fastlane beta
    exit $?
fi

if [[ "$TRAVIS_BRANCH" == "master" ]]; then
    bundle exec pod repo update
    fastlane release
    exit $?
fi

