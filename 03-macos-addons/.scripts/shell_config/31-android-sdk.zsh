# Android SDK from the Homebrew android-commandlinetools cask.
# sdkmanager installs packages (platform-tools, emulator, build-tools, images)
# next to cmdline-tools/ in this directory.
if [[ "$(uname -s)" == "Darwin" && -d /opt/homebrew/share/android-commandlinetools ]]; then
  export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
  ANDROID_BUILD_TOOLS_VERSION="37.0.0"   # zipalign, apksigner; bump after installing newer
  typeset -U path   # idempotent when re-sourced
  path=(
    "$ANDROID_HOME/platform-tools"
    "$ANDROID_HOME/emulator"
    "$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION"
    $path
  )
fi
