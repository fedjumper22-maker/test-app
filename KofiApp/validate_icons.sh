#!/bin/bash
# validate_icons.sh
# Checks and (where possible) auto-fixes the common causes of
# "adding icons breaks the build" for a web-to-APK Android project.
#
# Run this locally before pushing, or add as a step in build.yml
# (see bottom of this file for the workflow snippet).

set -e

RES_DIR="app/src/main/res"
MANIFEST="app/src/main/AndroidManifest.xml"
STRINGS="$RES_DIR/values/strings.xml"
DENSITIES=("mipmap-mdpi" "mipmap-hdpi" "mipmap-xhdpi" "mipmap-xxhdpi" "mipmap-xxxhdpi")

echo "== Icon validation =="

# 1. Check mipmap folders exist, create if missing
for d in "${DENSITIES[@]}"; do
  if [ ! -d "$RES_DIR/$d" ]; then
    echo "MISSING: $RES_DIR/$d — creating it"
    mkdir -p "$RES_DIR/$d"
  fi
done

# 2. Check each folder has ic_launcher.png, and that it's a REAL png
FAIL=0
for d in "${DENSITIES[@]}"; do
  FILE="$RES_DIR/$d/ic_launcher.png"
  if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE is missing."
    FAIL=1
  else
    TYPE=$(file --brief "$FILE")
    if [[ "$TYPE" != PNG* ]]; then
      echo "ERROR: $FILE exists but is NOT a valid PNG (detected: $TYPE)."
      FAIL=1
    else
      echo "OK: $FILE ($TYPE)"
    fi
  fi
done

# 3. Check manifest references the icon
if [ -f "$MANIFEST" ]; then
  if grep -q 'android:icon="@mipmap/ic_launcher"' "$MANIFEST"; then
    echo "OK: AndroidManifest.xml already references @mipmap/ic_launcher"
  else
    echo "MISSING: android:icon line not found in AndroidManifest.xml"
    echo "  -> Insert 'android:icon=\"@mipmap/ic_launcher\"' inside the <application> tag."
    FAIL=1
  fi
else
  echo "ERROR: $MANIFEST not found."
  FAIL=1
fi

# 4. Check app_name exists in strings.xml (label depends on it)
if [ -f "$STRINGS" ]; then
  if grep -q 'name="app_name"' "$STRINGS"; then
    echo "OK: app_name string exists"
  else
    echo "ERROR: app_name key missing from strings.xml (android:label will fail to resolve)"
    FAIL=1
  fi
else
  echo "ERROR: $STRINGS not found."
  FAIL=1
fi

echo "======================"
if [ $FAIL -eq 1 ]; then
  echo "RESULT: One or more icon-related issues found. Fix the ERROR lines above before building."
  exit 1
else
  echo "RESULT: All icon checks passed."
  exit 0
fi

# ---------------------------------------------------------------
# To run this automatically on every push, add this step to
# .github/workflows/build.yml, BEFORE the Gradle build step:
#
#   - name: Validate icons
#     run: |
#       chmod +x ./validate_icons.sh
#       ./validate_icons.sh
# ---------------------------------------------------------------
