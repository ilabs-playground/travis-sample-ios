#!/bin/sh

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
  echo "Testing on a branch other than master. No deployment will be done."
  exit 0
fi

ARCHIVE_DIR="$PWD/build/archive/$APP_NAME.xcarchive"
OUTPUT_DIR="$PWD/build/ipa"

echo "Building $APP_NAME"
xcodebuild CODE_SIGN_IDENTITY="$DEVELOPER_NAME" PROVISIONING_PROFILE="$PROVISION_UUID" -workspace "$APP_NAME.xcworkspace" -scheme "$APP_NAME" archive -archivePath $ARCHIVE_DIR 

echo "Packaging $APP_NAME"
xcodebuild -exportArchive -archivePath $ARCHIVE_DIR -exportPath $OUTPUT_DIR
#xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

zip -r -9 "$OUTPUT_DIR/$APP_NAME.app.dSYM.zip" "$ARCHIVE_DIR/dSYMs/$APP_NAME.app.dSYM"

echo "Upload to hockeyapp."
curl https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_ID/app_versions \
  -F status="2" \
  -F notify="0" \
  -F notes="Automated Build" \
	-F dsym_path="@$OUTPUT_DIR/$APP_NAME.app.dSYM.zip" \
  -F notes_type="0" \
  -F ipa="@$OUTPUT_DIR/$APP_NAME.ipa" \
  -H "X-HockeyAppToken: $HOCKEY_APP_TOKEN"

if [[ $? -ne 0 ]]
then
  echo "Error: Fail uploading to HockeyApp"
else
  echo "Success: Uploaded to Hockeyapp"
fi
