FROM        taig/scala:1.0.0

MAINTAINER  Niklas Klein "mail@taig.io"

ENV         ANDROID_SDK 24.4.1
ENV         ANDROID_BUILD_TOOLS 24.0.0
ENV         ANDROID_PLATFORM 23

WORKDIR     /root/

RUN         dpkg --add-architecture i386

RUN         apt-get update
RUN         apt-get upgrade -y
RUN         apt-get install -y --no-install-recommends \
                expect \
                git \
                libc6-i386 \
                lib32stdc++6 \
                lib32gcc1 \
                lib32ncurses5 \
                lib32z1
RUN         apt-get clean

# Install Android SDK
RUN         wget --output-document=android-sdk.tgz http://dl.google.com/android/android-sdk_r${ANDROID_SDK}-linux.tgz
RUN         tar xzf android-sdk.tgz
RUN         rm -f android-sdk.tgz
ENV         ANDROID_HOME /root/android-sdk-linux
ENV         PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Helper script to accept Android SDK installer licenses
COPY        ./accept-licenses.sh .
RUN         chmod +x ./accept-licenses.sh

# Install major Android SDK components
RUN         [ "./accept-licenses.sh", "android update sdk --no-ui --all --filter tools" ]
RUN         [ "./accept-licenses.sh", "android update sdk --no-ui --all --filter platform-tools" ]
RUN         eval ./accept-licenses.sh "'android update sdk --no-ui --all --filter build-tools-${ANDROID_BUILD_TOOLS}'"
RUN         eval ./accept-licenses.sh "'android update sdk --no-ui --all --filter android-${ANDROID_PLATFORM}'"
RUN         [ "./accept-licenses.sh", "android update sdk --no-ui --all --filter extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository" ]

# Install and test a sample project to cache the major dependencies
RUN         git clone https://github.com/taig/hello-scala.git
RUN         cd ./hello-scala && sbt test
RUN         rm -r ./hello-scala
