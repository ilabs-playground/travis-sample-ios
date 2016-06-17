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
OUTPUT_DIR="$PWD/build"

echo "Building $APP_NAME"
xcodebuild CODE_SIGN_IDENTITY="$DEVELOPER_NAME" PROVISIONING_PROFILE="$PROVISION_UUID" -project "$APP_NAME.xcodeproj" -scheme "$APP_NAME" archive -archivePath $ARCHIVE_DIR 

echo "Packaging $APP_NAME"
xcodebuild -exportArchive -archivePath $ARCHIVE_DIR -exportPath "$OUTPUT_DIR/$APP_NAME"

DSYM_FILE="$OUTPUT_DIR/$APP_NAME.app.dSYM.zip"

zip -r -9 "$DSYM_FILE" "$ARCHIVE_DIR/dSYMs/$APP_NAME.app.dSYM"

echo "Upload to hockeyapp."
curl https://rink.hockeyapp.net/api/2/apps/$HOCKEY_APP_ID/app_versions \
  -F status="2" \
  -F notify="0" \
  -F notes="Automated Build" \
  -F notes_type="0" \
	-F dsym_path="@$DSYM_FILE" \
  -F ipa="@$OUTPUT_DIR/$APP_NAME.ipa" \
  -H "X-HockeyAppToken: $HOCKEY_APP_TOKEN"

if [[ $? -ne 0 ]]
then
  echo "Error: Fail uploading to HockeyApp"
else
  echo "Success: Uploaded to Hockeyapp"
fi
