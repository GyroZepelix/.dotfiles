# Android SDK from the Homebrew android-commandlinetools cask (macOS), loaded
# by ~/.scripts/env.sh (POSIX sh, silent). sdkmanager installs packages
# (platform-tools, emulator, build-tools, images) next to cmdline-tools/ here.
# $OSTYPE avoids forking uname in bash and zsh; plain sh falls back to uname.
case "${OSTYPE:-$(uname -s)}" in
  [Dd]arwin*)
    if [ -d /opt/homebrew/share/android-commandlinetools ]; then
      export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
      ANDROID_BUILD_TOOLS_VERSION="37.0.0"   # zipalign, apksigner; bump after installing newer
      # Prepend in reverse so the final order is platform-tools, emulator, build-tools.
      path_prepend "$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION"
      path_prepend "$ANDROID_HOME/emulator"
      path_prepend "$ANDROID_HOME/platform-tools"
    fi
    ;;
esac
