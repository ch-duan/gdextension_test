#!/bin/bash
cd godot-cpp
scons platform=android generate_bindings=yes ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT android_arch=arm64v8 android_api_level=32 target=debug
# scons platform=android generate_bindings=yes ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT android_arch=arm64v8 android_api_level=32 target=release
