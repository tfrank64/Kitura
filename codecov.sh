#! /bin/bash

echo "Starting code coverage generation"
uname -a
xcodebuild -version
if [[ $? != 0 ]]; then
    echo "Skipping code coverage generation as xcodebuild not available"
    exit 1
fi

SDK=macosx
xcodebuild -version -sdk $SDK

PROJ_CMD="swift package generate-xcodeproj"
echo "Running $PROJ_CMD"
PROJ_OUTPUT=$(eval "$PROJ_CMD")
PROJ_EXIT_CODE=$?
echo "$PROJ_OUTPUT"
if [[ $PROJ_EXIT_CODE != 0 ]]; then
    exit 1
fi

PROJECT="${PROJ_OUTPUT##*/}"
SCHEME="${PROJECT%.xcodeproj}"

TEST_CMD="xcodebuild -project $PROJECT -scheme $SCHEME -sdk $SDK -enableCodeCoverage YES test"
echo "Running $TEST_CMD"
eval "$TEST_CMD"
if [[ $? != 0 ]]; then
    exit 1
fi

bash <(curl -s https://codecov.io/bash) -J "^${SCHEME}\$"
if [[ $? != 0 ]]; then
    echo "Error running codecov.io bash script"
    exit 1
fi

echo "Successfully generated codecov.io report"
