#! /bin/bash

uname -a
xcodebuild -version
XCODEBUILD_INSTALLED=$?

if [[ $XCODEBUILD_INSTALLED != 0 ]]; then
    echo "Skipping code coverage generation as xcodebuild not available on ${TRAVIS_OS_NAME}"
else
    echo "Starting code coverage generation on ${TRAVIS_OS_NAME}"
    XCODE_OUTPUT=`swift package generate-xcodeproj`
    echo "$XCODE_OUTPUT"

    PROJECT="${XCODE_OUTPUT##*/}"
    SCHEME="${PROJECT%%.xcodeproj}"

    TEST_CMD="xcodebuild -project $PROJECT -scheme $SCHEME -sdk macosx -enableCodeCoverage YES test"
    echo "Running ${TEST_CMD}"
    eval "${TEST_CMD}"

    bash <(curl -s https://codecov.io/bash) -J "^${SCHEME}\$"
    echo "Finished code coverage generation"
fi

