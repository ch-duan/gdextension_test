cmake_minimum_required(VERSION 3.6)
project(topiot_ai)

set(GODOT_GDEXTENSION_DIR ${CMAKE_CURRENT_SOURCE_DIR}/lib/godot-cpp/gdextension CACHE STRING "Path to GDExtension interface header directory")
set(CPP_BINDINGS_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lib/godot-cpp CACHE STRING "Path to C++ bindings")
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE INTERNAL "") # works

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(TARGET_PATH x11)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(TARGET_PATH win64)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(TARGET_PATH macos)
else()
  message(FATAL_ERROR "Not implemented support for ${CMAKE_SYSTEM_NAME}")
endif()

# Change the output directory to the bin directory
set(BUILD_PATH ${CMAKE_SOURCE_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${BUILD_PATH}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${BUILD_PATH}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${BUILD_PATH}")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${BUILD_PATH}")
SET(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${BUILD_PATH}")
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${BUILD_PATH}")
SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${BUILD_PATH}")
SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${BUILD_PATH}")
SET(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${BUILD_PATH}")

# Set the c++ standard to c++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(GODOT_COMPILE_FLAGS)
set(GODOT_LINKER_FLAGS)

set(inc)

option(USE_OPENCV "Use OpenCV" ON)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  # using Visual Studio C++
  set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /WX") # /GF /MP
  set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /DTYPED_METHOD_BIND")

  if(CMAKE_BUILD_TYPE MATCHES Debug)
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /MDd") # /Od /RTC1 /Zi
  else()
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /MD /O2") # /Oy /GL /Gy
    STRING(REGEX REPLACE "/RTC(su|[1su])" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    string(REPLACE "/RTC1" "" CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
  endif(CMAKE_BUILD_TYPE MATCHES Debug)

  # Disable conversion warning, truncation, unreferenced var, signed mismatch
  set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /wd4244 /wd4305 /wd4101 /wd4018 /wd4267")

  add_definitions(-DNOMINMAX)

# Unkomment for warning level 4
# if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
# string(REGEX REPLACE "/W[0-4]" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
# endif()
else()
  # set(GODOT_LINKER_FLAGS "-static-libgcc -static-libstdc++ -Wl,-R,'$$ORIGIN'")
  set(GODOT_LINKER_FLAGS "-static-libgcc -static-libstdc++ -Wl")

  set(GODOT_COMPILE_FLAGS "-fPIC -g -Wwrite-strings")

  if(CMAKE_BUILD_TYPE MATCHES Debug)
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -fno-omit-frame-pointer -O0")
  else()
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -O3")
  endif(CMAKE_BUILD_TYPE MATCHES Debug)
endif()

# Disable exception handling. Godot doesn't use exceptions anywhere, and this
# saves around 20% of binary size and very significant build time (GH-80513).
option(GODOT_DISABLE_EXCEPTIONS ON "Force disabling exception handling code")

if(GODOT_DISABLE_EXCEPTIONS)
  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -D_HAS_EXCEPTIONS=0")
  else()
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} -fno-exceptions")
  endif()
else()
  if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    set(GODOT_COMPILE_FLAGS "${GODOT_COMPILE_FLAGS} /EHsc")
  endif()
endif()

# Get Sources
file(GLOB_RECURSE SOURCES src/*.c**)
file(GLOB_RECURSE HEADERS include/*.h**)
list(APPEND HEADERS lib/dll_project.h)

add_subdirectory(lib/godot-cpp)

# add_custom_target(generate_sources ALL COMMAND generator ${CMAKE_CURRENT_SOURCE_DIR}/lib/godot-cpp)
if(USE_OPENCV)
  include_directories($ENV{OPENCV_PATH}/build/include)
  set(OPENCV_LIB_DIR $ENV{OPENCV_PATH}/build/x64/vc16/lib)
  message(STATUS "OPENCV_LIB_DIR: ${OPENCV_LIB_DIR}")

  if(CMAKE_BUILD_TYPE STREQUAL "Release")
    find_library(opencv_lib opencv_world490 ${OPENCV_LIB_DIR})
  endif()

  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    find_library(opencv_lib opencv_world490d ${OPENCV_LIB_DIR})
  endif()

  list(APPEND inc $ENV{OPENCV_PATH}/build/include)
  list(APPEND links ${opencv_lib})
endif()

# Define our godot-cpp library
add_library(${PROJECT_NAME} SHARED ${SOURCES} ${HEADERS})
add_dependencies(${PROJECT_NAME} godot-cpp)

message(STATUS "inc: ${inc}")

target_include_directories(${PROJECT_NAME}
  PUBLIC
  ${CPP_BINDINGS_PATH}/include
  ${CPP_BINDINGS_PATH}/gen/include
  ${CMAKE_CURRENT_SOURCE_DIR}/build/lib/godot-cpp/gen/include
  ${GODOT_GDEXTENSION_DIR}
  lib
  src
  ${inc}
)

set(links)

list(APPEND links TopAIEngine)

# Create the correct name (godot.os.build_type.system_bits)
# Synchronized with godot-cpp's CMakeLists.txt
set(BITS 32)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(BITS 64)
endif(CMAKE_SIZEOF_VOID_P EQUAL 8)

if(CMAKE_BUILD_TYPE MATCHES Debug)
  set(GODOT_CPP_BUILD_TYPE Debug)
else()
  set(GODOT_CPP_BUILD_TYPE Release)
endif()

string(TOLOWER ${CMAKE_SYSTEM_NAME} SYSTEM_NAME)
string(TOLOWER ${GODOT_CPP_BUILD_TYPE} BUILD_TYPE)

if(ANDROID)
  # Added the android abi after system name
  set(SYSTEM_NAME ${SYSTEM_NAME}.${ANDROID_ABI})
endif()

if(CMAKE_VERSION VERSION_GREATER "3.13")
  target_link_directories(${PROJECT_NAME}
    PRIVATE
    ${CPP_BINDINGS_PATH}/bin/
    ${CPP_BINDINGS_PATH}/build/bin/
    ${CMAKE_CURRENT_SOURCE_DIR}/bin
    lib
  )

  target_link_libraries(${PROJECT_NAME}
    godot-cpp.${SYSTEM_NAME}.${BUILD_TYPE}$<$<NOT:$<PLATFORM_ID:Android>>:.${BITS}>
    ${links}
  )
else()
  target_link_libraries(${PROJECT_NAME}
    ${CPP_BINDINGS_PATH}/bin/libgodot-cpp.${SYSTEM_NAME}.${BUILD_TYPE}$<$<NOT:$<PLATFORM_ID:Android>>:.${BITS}>.a
    ${links}
  )
endif()

# Add the compile flags
set_property(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY COMPILE_FLAGS ${GODOT_COMPILE_FLAGS})
set_property(TARGET ${PROJECT_NAME} APPEND_STRING PROPERTY LINK_FLAGS ${GODOT_LINKER_FLAGS})

set_property(TARGET ${PROJECT_NAME} PROPERTY OUTPUT_NAME "topiot_ai")

install(TARGETS ${PROJECT_NAME} DESTINATION test/lib)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/lib/TopAIEngine.dll DESTINATION test/lib)