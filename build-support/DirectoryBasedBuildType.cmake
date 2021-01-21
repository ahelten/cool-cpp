# This CMake module provides directory-recognition feature for setting CMAKE_BUILD_TYPE. This
# module is fully-documented in doc/BUILD.md

get_filename_component(builddir_nopath "${CMAKE_CURRENT_BINARY_DIR}" NAME_WE)
string(TOLOWER "${builddir_nopath}" builddir_nopath_lowercase)


####################################################################################################
# Detect/configure CMAKE_BUILD_TYPE: Debug, Release, RelWithDebInfo, Coverage, Profiler, etc
#
macro(InitBuildType)

if (NOT CMAKE_BUILD_TYPE)
    if (CMAKE_BUILD_TYPE_DEFAULT)
        set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE_DEFAULT}")
    else ()
        if (builddir_nopath_lowercase MATCHES ".*coverage.*")
            set(CMAKE_BUILD_TYPE Coverage)
            add_definitions(-DCOVERAGE_BUILD)
        elseif (builddir_nopath_lowercase MATCHES ".*profile.*")
            set(CMAKE_BUILD_TYPE Profiler)
            add_definitions(-DPROFILE_BUILD)
            add_definitions(-DDEBUG_BUILD) # It's both debug and profiler
        elseif ((builddir_nopath_lowercase MATCHES ".*rel.*") AND (builddir_nopath_lowercase MATCHES ".*deb.*"))
            set(CMAKE_BUILD_TYPE RelWithDebInfo)
            add_definitions(-DRELEASE_BUILD)
        elseif (builddir_nopath_lowercase MATCHES ".*debug.*")
            set(CMAKE_BUILD_TYPE Debug)
            add_definitions(-DDEBUG_BUILD)
        else()
            # The default build type is set here
            if (UNIX)
                set(CMAKE_BUILD_TYPE Release)
                add_definitions(-DRELEASE_BUILD)
            else()
                # Windows default *must* be Debug at this point in time!
                set(CMAKE_BUILD_TYPE Debug)
                add_definitions(-DDEBUG_BUILD)
            endif()
        endif()
    endif()
endif()

if (CMAKE_BUILD_TYPE MATCHES Release)
    set(buildtype_color BoldGreen)
else()
    set(buildtype_color BoldYellow)
endif()

message("                     Build type [CMAKE_BUILD_TYPE]:  ${${buildtype_color}}${CMAKE_BUILD_TYPE}${NoColor}")


if (CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(compilerid_color BoldGreen)
    execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpversion
        OUTPUT_VARIABLE cxx_ver OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(COMPILER_VER "${cxx_ver}")

    # This *is* the gcc compiler so "equivalent 4.5" version is "4.5"
    set(EQUIVALENT_GCC45 "4.5")
elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(compilerid_color BoldYellow)
    execute_process(COMMAND ${CMAKE_CXX_COMPILER} --version
        OUTPUT_VARIABLE cxx_ver OUTPUT_STRIP_TRAILING_WHITESPACE)

    string(REGEX MATCH "^clang version .*$" version_line ${cxx_ver})
    string(REGEX MATCH "^clang version ([0-9\.]+) .*$" version_only ${version_line})
    set(COMPILER_VER "${CMAKE_MATCH_1}")

    # Which Clang compiler version is equivalent to gcc 4.5? Not sure but is definitely newer than
    # the version 3.4.2 provided in RHEL 7.4
    set(EQUIVALENT_GCC45 "3.5")
else()
    set(compilerid_color BoldRed)
    set(COMPILER_VER "0.0")
    set(EQUIVALENT_GCC45 "0.0.1") # Just make it larger than COMPILER_VER
endif()


message("                  Compiler [CMAKE_CXX_COMPILER_ID]:  ${${compilerid_color}}${CMAKE_CXX_COMPILER_ID}${NoColor}")
message("                   Compiler Version [COMPILER_VER]:  ${COMPILER_VER}")

if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
   # These flags are prepended to CMAKE_CXX_FLAGS_DEBUG (and possibly the other
   # CMAKE_CXX_FLAGS_xxx variables)
   #
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wall")
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wconversion")
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Werror=overflow")
   #set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wextra")
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wunused-variable")
   #set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wunused-parameter")
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wunused-function")
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wunused")
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wno-system-headers")
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wno-deprecated")
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Woverloaded-virtual")
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -Wwrite-strings")
   # strict-aliasing checks are enabled in -O builds but not -g debug builds (Why? Don't know.)
   set(PROJ_COMMON_FLAGS "${PROJ_COMMON_FLAGS} -fstrict-aliasing -Wstrict-aliasing")

   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${PROJ_COMMON_FLAGS} -D__STDC_LIMIT_MACROS")
   set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${PROJ_COMMON_FLAGS} -D__STDC_LIMIT_MACROS")

   # -g is already included in xxx_DEBUG flags
   set(CMAKE_C_FLAGS_DEBUG   "${CMAKE_C_FLAGS_DEBUG} -O0")
   set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0")

   # -O3 is already included in xxx_RELEASE flags
   #set(CMAKE_C_FLAGS_RELEASE   "${CMAKE_C_FLAGS_RELEASE}")
   #set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")

   # -O2 and -g are already included in xxx_RELWITHDEBINFO flags
   #set(CMAKE_C_FLAGS_RELWITHDEBINFO   "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
   #set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")

   # Use compiler flag '-pg' to enable creation of gmon.out files for profiling with 'gprof'
   set(CMAKE_C_FLAGS_PROFILER   "${CMAKE_C_FLAGS_DEBUG} -pg")
   set(CMAKE_CXX_FLAGS_PROFILER "${CMAKE_CXX_FLAGS_DEBUG} -pg")
endif ()

if ((CMAKE_BUILD_TYPE MATCHES Release) OR (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo))
   # Disable POSIX asserts
   # -DNDEBUG is already defined in Release and RelWithDebInfo flags
   #add_definitions(-DNDEBUG)

   # Add define to allow some custom code configurations
   add_definitions(-DRELEASE_BUILD)
endif ()

# Setup some unix/linux specific libraries. Add others here as necessary:
#
if (UNIX)
   set(LINUX TRUE)
   set(PROJ_OS_LIBS ${PROJ_OS_LIBS} pthread dl rt)
endif()

endmacro()
