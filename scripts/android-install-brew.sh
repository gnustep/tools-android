#!/bin/sh

brew tap caskroom/cask
brew install ant
brew install maven
brew cask install android-sdk
brew cask install android-ndk

sdkmanager "platform-tools" "platforms;android-23"
sdkmanager "build-tools;23.0.1"

echo "Initialize environment by executing env.sh"
exit 0
