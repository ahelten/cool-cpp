# This CMake module tries to detect the current CPU architecture (x86, x86_64, etc) as well as the
# overall platform (rhel6, rhel7, windows, etc).
#
# This module sets the following variables:
#   * CPU_ARCH:  x86, x86_64, x64, etc
#   * PLATFORM_NAME:  rhel6, rhel7, ubuntu10, ubuntu12, etc
#
# If there is a problem with detection, these variables are not set.

macro(DetectBuildPlatform)

    if (UNIX AND NOT CYGWIN)
        execute_process(COMMAND uname -m OUTPUT_VARIABLE CPU_ARCH OUTPUT_STRIP_TRAILING_WHITESPACE)

        if (EXISTS /etc/redhat-release)
            file(READ /etc/redhat-release RAW_RELSTR)
            string(REGEX REPLACE "\n" "" RELSTR "${RAW_RELSTR}")
            if (   (RELSTR MATCHES "Red Hat Enterprise Linux .* release")
                OR (RELSTR MATCHES "CentOS Linux release*"))
                string(REGEX REPLACE "^.*release ([0-9]+).*" "\\1" VERNUM "${RELSTR}")
                set(PLATFORM_NAME "rhel${VERNUM}")
            elseif (RELSTR MATCHES "Red Hat Linux release")
                string(REGEX REPLACE "^.*release ([0-9]+).*" "\\1" VERNUM "${RELSTR}")
                set(PLATFORM_NAME "rh${VERNUM}")
            elseif (RELSTR MATCHES "Fedora .* release [0-9]+.*")
                string(REGEX REPLACE "^.*release ([0-9]+).*" "\\1" VERNUM "${RELSTR}")
                set(platform_shortname "fedora${VERNUM}")
            else()
                set(PLATFORM_NAME "rh_unknown")
                message(WARNING "RedHat-based distro '${RELSTR}' is not supported directly by RPM creation -- though it might still work!")
            endif()
        elseif (EXISTS /etc/issue.net)
            file(READ /etc/issue.net RAW_RELSTR)
            string(REGEX REPLACE "\n" "" RELSTR "${RAW_RELSTR}")
            string(REGEX REPLACE "Ubuntu ([0-9]+).*" "\\1" VERNUM "${RELSTR}")
            if (VERNUM)
                set(PLATFORM_NAME "ubuntu${VERNUM}")
            else()
                set(PLATFORM_NAME "ubuntu_unknown")
                message(WARNING "Ubuntu-based distro '${RELSTR}' is not supported directly by RPM creation -- though it might still work!")
            endif()
        else()
            message(WARNING "Unknown Linux distro is not supported directly by RPM creation -- though it might still work!")
            set(PLATFORM_NAME "unknown")
        endif()
    else()
        # Windows
        if (CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(CPU_ARCH x64)
        else()
            set(CPU_ARCH x86)
        endif()
        set(PLATFORM_NAME "${CMAKE_SYSTEM}")
    endif()

    message("                       CPU Architecture [CPU_ARCH]:  ${CPU_ARCH}")
    message("                    Build Platform [PLATFORM_NAME]:  ${PLATFORM_NAME}")

endmacro ()
