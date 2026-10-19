#!/bin/sh
# Signs dist/Profiley.app with a Developer ID, notarizes it and staples the ticket, then rezips.
# Needs: a "Developer ID Application" certificate in the keychain, and notarytool credentials
# saved once with: xcrun notarytool store-credentials profiley --apple-id YOU --team-id TEAM --password APP_SPECIFIC_PASSWORD
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"
APP="$SRC/dist/Profiley.app"
"$SRC/release.sh"
codesign --force --options runtime --timestamp -s "Developer ID Application" "$APP"
ditto -c -k --keepParent "$APP" "$SRC/dist/upload.zip"
xcrun notarytool submit "$SRC/dist/upload.zip" --keychain-profile profiley --wait
xcrun stapler staple "$APP"
rm "$SRC/dist/upload.zip" "$SRC/dist/Profiley.zip"
ditto -c -k --keepParent "$APP" "$SRC/dist/Profiley.zip"
spctl -a -vv "$APP"
echo "Notarized $SRC/dist/Profiley.zip"
