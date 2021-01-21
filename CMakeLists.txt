list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/build-support/")

cmake_minimum_required(VERSION 3.0)

project(cool-cpp)

include(Colors)
include(DirectoryBasedBuildType)
include(DetectVirtualMachine)
include(DetectBuildPlatform)

InitBuildType() # This sets PROJ_OS_LIBS to some common libraries
DetectBuildPlatform()
DetectVirtualMachine()

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


add_executable(DisplayTypes DisplayTypes.cpp)
add_executable(EnumSizes EnumSizes.cpp)
#target_compile_options(EnumSizes PRIVATE "-Wno-conversion")
