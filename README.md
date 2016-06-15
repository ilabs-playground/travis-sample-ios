1. Open up the Manage Schemes sheet by selecting the Product → Schemes → Manage Schemes… menu option.
2. Locate the target you want to use for testing in the list. Ensure that the Shared checkbox in the far right hand column of the sheet is checked.
3. If your target include cross-project dependencies such as CocoaPods, then you will need to ensure that they have been configured as explicit dependencies. To do so:
4. Highlight your application target and hit the Edit… button to open the Scheme editing sheet.
5. Click the Build tab in the left-hand panel of the Scheme editor.
6. Click the + button and add each dependency to the project. CocoaPods will appear as a static library named Pods.
7. Drag the dependency above your test target so it is built first.
8. You will now have a new file in the xcshareddata/xcschemes directory underneath your Xcode project. This is the shared Scheme that you just configured. Check this file into your repository and xctool will be able to find and execute your tests.


Deploy an app automatically to testflight using travis ci.

1. Copy the .travis.yml into your repo (replace app name, developer name and provisionin profile uuid)
2. Create the folder "scripts/travis"
3. Export the following things from the Keychain app
    * "Apple Worldwide Developer Relations Certification Authority" into scripts/travis/apple.cer
    * Your iPhone Distribution certificate into scripts/travis/dist.cer
    * Your iPhone Distribution private key into scripts/travis/dist.p12 (choose a password)
4. Execute travis encrypt "KEY_PASSWORD=YOUR_KEY_PASSWORD" --add
5. Execute travis encrypt "TEAM_TOKEN=TESTFLIGHT_TEAM_TOKEN" --add
6. Execute travis encrypt "API_TOKEN=TESTFLIGHT_API_TOKEN" --add
7. Copy add-key.sh, remove-key.sh and testflight.sh into scripts/travis
8. Commit
