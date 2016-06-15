#!/bin/sh

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No deployment will be done."
  exit 0
fi

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
OUTPUTDIR="$PWD/build/Release-iphoneos"

#echo "Building $APP_NAME"
#xcodebuild -workspace "$APP_NAME.xcworkspace" -scheme "$APP_NAME" clean build

echo "Packaging $APP_NAME"
xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

echo "Upload to hockeyapp."
curl https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_ID/app_versions \
  -F status="2" \
  -F notify="0" \
  -F notes="Automated Build" \
  -F notes_type="0" \
  -F ipa="@$OUTPUT_DIR/$APP_NAME.ipa" \
  -H "X-HockeyAppToken: $HOCKEY_APP_TOKEN"

if [[ $? -ne 0 ]]
then
  echo "Error: Fail uploading to HockeyApp"
else
  echo "Success: Uploaded to Hockeyapp"
fi
