#!/bin/bash

# Android or iOS
target=$1
# Arch
arch=$2
NDK_PATH=$3
# Check if parameters are provided
if [ -z "$target" ]
then
  echo "Please provide target platform."
  exit 1
fi

if [ -z "$arch" ]
then
  echo "Please provide target arch."
  # exit 1
fi


# if [ "$target" != "iOS"] || ["$target" != "Android"]
# then
#   echo "Not a validate target platform."
#   exit 1
# fi
# pip install "conan>=1.40.3"

# mkdir -p work
# cd work
mkdir -p build
# cd build
# cmake --build . --target clean

# Check if name is "John"
if [ "$target" = "iOS" ]; then
  echo "iOS BUILD"

  # cmake .. -DCMAKE_BUILD_TYPE=Debug .
  # cmake --build . --target install

  # mkdir -p build/ios
  # cd build/ios
  # cmake -GXcode -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=OS64COMBINED -DLIB_TYPE:STRING=STATIC -Bbuild
  mkdir -p build
  cmake -Bbuild -G Xcode -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS="-Wno-shorten-64-to-32" -DENABLE_BITCODE=FALSE -DPLATFORM=OS64
  # cmake --build . --config Release
  # cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_IOS_TOOLCHAIN -DLIB_TYPE:STRING=STATIC ../..

  # cmake -Bbuild -GXcode \
  #   -DCMAKE_SYSTEM_NAME=iOS \
  #   "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" \
  #   -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  #   -DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
  #   -DCMAKE_IOS_INSTALL_COMBINED=YES \
  #   -DCMAKE_CXX_FLAGS="-Wno-shorten-64-to-32"
    # -sdk iphonesimulator
    # -DCMAKE_INSTALL_PREFIX=`pwd`/_install \
  # cmake --build build --config Release --target install -- CODE_SIGNING_ALLOWED=NO -- -UseModernBuildSystem=NO
  cmake --build build --config Debug --target install -- CODE_SIGNING_ALLOWED=NO -- -UseModernBuildSystem=NO

  # cd build
  # make -j7

  cp build/compile_commands.json ../compile_commands.json
  # * _OS_ - to build for iOS (armv7, armv7s, arm64) **DEPRECATED in favour of OS64**
  # * _OS64_ - to build for iOS (arm64 only)
  # * _OS64COMBINED_ - to build for iOS & iOS Simulator (FAT lib) (arm64, x86_64)
  # * _SIMULATOR_ - to build for iOS simulator 32 bit (i386) **DEPRECATED**
  # * _SIMULATOR64_ - to build for iOS simulator 64 bit (x86_64)
  # * _SIMULATORARM64_ - to build for iOS simulator 64 bit (arm64)
  # * _TVOS_ - to build for tvOS (arm64)
  # * _TVOSCOMBINED_ - to build for tvOS & tvOS Simulator (arm64, x86_64)
  # * _SIMULATOR_TVOS_ - to build for tvOS Simulator (x86_64)
  # * _WATCHOS_ - to build for watchOS (armv7k, arm64_32)
  # * _WATCHOSCOMBINED_ - to build for watchOS & Simulator (armv7k, arm64_32, i386)
  # * _SIMULATOR_WATCHOS_ - to build for watchOS Simulator (i386)
  # * _MAC_ - to build for macOS (x86_64)
  # * _MAC_ARM64_ - to build for macOS on Apple Silicon (arm64)
  # * _MAC_UNIVERSAL_ - to build for macOS on x86_64 and Apple Silicon (arm64) combined
  # * _MAC_CATALYST_ - to build iOS for Mac (Catalyst, x86_64)
  # * _MAC_CATALYST_ARM64_ - to build iOS for Mac on Apple Silicon (Catalyst, arm64)

  # cd build
  # cmake .. -G Xcode -DCMAKE_TOOLCHAIN_FILE=ios.toolchain.cmake -DPLATFORM=OS64
  # cmake --build . --config Release


elif [ "$target" = "Android" ]; then
 if [ -z "$NDK_PATH" ]
  then
    echo "Please provide android ndk path"
    exit 1
  fi
  echo "Android BUILD"
  echo $NDK_PATH
  ### ANDROID_ABI = armeabi-v7a | arm64-v8a | x86 | x86_64
  ### ANDROID_PLATFORM = android-16 | android-21 | android-24 | android-28 | android-29 | android-30
  ### ANDROID_STL = c++_static | c++_shared | gnustl_static | gnustl_shared | stlport_static | stlport_shared | system | none
  ### ANDROID_CPP_FEATURES = exceptions | rtti | exceptions,rtti
  ### https://developer.android.com/ndk/guides/abis?hl=zh-cn

  mkdir -p build/Android
  cd build/Android
  cmake -DPLATFORM=Android \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_TOOLCHAIN_FILE=$NDK_PATH/build/cmake/android.toolchain.cmake \
    -DANDROID_NDK=$NDK_PATH \
    -DANDROID_ABI="$arch"  \
    -DANDROID_PLATFORM=android-28 \
    -Bbuild \
    -G "Unix Makefiles" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_MAKE_PROGRAM=$NDK_PATH/prebuilt/windows-x86_64/bin/make.exe \
    ../..
  cmake --build build --target install -j8
  cp build/compile_commands.json ../compile_commands.json
fi
