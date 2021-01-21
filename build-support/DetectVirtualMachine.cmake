# This CMake module tries to detect if the build is occurring on a VM. This is for use when
# it is desirabled to enable VM-specific changes to the build or to test-setup, for example, we
# frequently have failures in timing-related tests when running on a VM. So to avoid excessive
# failures in those tests, either disable them on a VM or increase the fudge-factor that determines
# failure.
#
# This module sets VIRTUAL_MACHINE_DETECTED to TRUE if it appears we are running on a VM. It also
# sets VIRTUAL_MACHINE_NAME to the name of the virtual machine or to "unknown" if it cannot
# determine the name.
# 

macro(DetectVirtualMachine)

   set(VIRTUAL_MACHINE_NAME "unknown")

   # 1. Try 'hostnamectl status':
   find_program(hostnamectl_executable
      NAMES hostnamectl2 hostnamectl
      DOC "hostnamectl program for detecting an underlying virtual machine"
      )
   if (hostnamectl_executable)
      execute_process(COMMAND ${hostnamectl_executable} status
         OUTPUT_VARIABLE hostnamectl_output
         OUTPUT_STRIP_TRAILING_WHITESPACE)

      if (${hostnamectl_output} MATCHES "Virtualization: [^\n\r]+")
         set(VIRTUAL_MACHINE_DETECTED TRUE)
         string(REPLACE "Virtualization: " "" VIRTUAL_MACHINE_NAME "${CMAKE_MATCH_0}")
      endif ()
   else ()
      # 2. Now try 'systemd-detect-virt -v':
      find_program(systemd_virt_executable
         NAMES "systemd-detect-virt"
         DOC "systemd-detect-virt program for detecting an underlying virtual machine"
         )
      if (systemd_virt_executable)
         execute_process(COMMAND ${systemd_virt_executable} -v
            OUTPUT_VARIABLE systemdvirt_output
            OUTPUT_STRIP_TRAILING_WHITESPACE)

         if (NOT ${systemdvirt_output} MATCHES "none")
            set(VIRTUAL_MACHINE_DETECTED TRUE)
            set(VIRTUAL_MACHINE_NAME "${systemdvirt_output}")
         endif ()
      endif ()
   endif ()

   if (VIRTUAL_MACHINE_DETECTED)
      message("        Virtual Machine [VIRTUAL_MACHINE_DETECTED]:  ${BoldYellow}Yes; ${VIRTUAL_MACHINE_NAME}${NoColor}")
   else ()
      message("        Virtual Machine [VIRTUAL_MACHINE_DETECTED]:  ${BoldGreen}No${NoColor}")
   endif ()
endmacro ()
