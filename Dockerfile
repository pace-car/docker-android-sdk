FROM ubuntu:16.04
# ANDROID SDK DOCKER IMAGE
# Currently there is no known elegant way to have the following two vars dynamic.
# I started a SO question here: https://stackoverflow.com/questions/47528197/
ENV ANDROID_API_LEVELS android-26
ENV ANDROID_BUILD_TOOLS_VERSION 26.0.2

ENV ANDROID_SDK_HOME /opt/android-sdk
ENV ANDROID_NDK_HOME /opt/android-ndk
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH ${PATH}:${ANDROID_SDK_HOME}/tools:${ANDROID_SDK_HOME}/tools/bin:${ANDROID_SDK_HOME}/platform-tools
ENV PATH ${PATH}:${ANDROID_NDK_HOME}
ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap

# REQUIREMENTS
# support multiarch: i386 architecture
# install Java
# install essential tools
# install Qt
# install Ruby
# install build tools required by Fastlane
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libncurses5:i386 libc6:i386 libstdc++6:i386 lib32gcc1 lib32ncurses5 lib32z1 zlib1g:i386 && \
    apt-get install -y --no-install-recommends openjdk-8-jdk && \
    apt-get install -y git wget zip curl && \
    apt-get install -y qt5-default && \
    apt-get install -y ruby ruby-dev && \
    apt-get install -y cmake build-essential

# install Ruby:GEM:Fastlane
RUN gem install fastlane

# ANDROID
# install latest android sdk tools
RUN ANDROID_SDK_URL=$( \
  curl -s https://developer.android.com/studio/index.html | \
        grep 'https://dl.google.com/android/repository/sdk-tools-linux-[0-9]*[.zip]' | \
        head -n 1 | \
        cut -d '"' -f 2 \
  ) && \
  mkdir -p ${ANDROID_SDK_HOME} && cd ${ANDROID_SDK_HOME} && \
  wget -q ${ANDROID_SDK_URL} && \
  unzip *tools*linux*.zip && \
  rm *tools*linux*.zip  

# accept all licenses
# install android tools
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;${ANDROID_API_LEVELS}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"
RUN sdkmanager "extras;android;m2repository" "extras;google;m2repository" "extras;google;google_play_services"
RUN sdkmanager "extras;google;webdriver"

# install latest android ndk
RUN ANDROID_NDK_URL=$( \
  curl -s https://developer.android.com/ndk/downloads/index.html | \
        grep 'https://dl.google.com/android/repository/android-ndk-r[0-9]*-linux-x86_64[.zip]' | \
        head -n 1 | \
        cut -d '"' -f 2 \
  ) && \
  mkdir -p ${ANDROID_NDK_HOME} && cd ${ANDROID_NDK_HOME} && \
  wget -q ${ANDROID_NDK_URL} && \
  unzip *ndk*linux*.zip && \
  rm *ndk*linux*.zip && \
  mv ./android-ndk-r*/* .
