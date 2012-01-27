## A bunch of helpful CMake macros.
##
## Author: Vladimir Volodko


##  Resource files compilation.
##  Usage:
##    add_rc(mytarget_RC myresource1.rc myresource2.rc)
##    add_executable(mytarget ${mytarget_SOURCES} ${mytarget_RC})
macro (add_rc rc_var)
    if (MSVC)
        list(APPEND ${rc_var} ${ARGN})
    elseif (MINGW)
        foreach (rc_arg ${ARGN})
            set(rc_obj "${CMAKE_CURRENT_BINARY_DIR}/${rc_arg}.obj")
            add_custom_command(OUTPUT ${rc_obj}
                COMMAND windres.exe -I ${CMAKE_CURRENT_SOURCE_DIR}
                -i ${CMAKE_CURRENT_SOURCE_DIR}/${rc_arg} -o ${rc_obj})
            list(APPEND ${rc_var} ${rc_obj})
        endforeach (rc_arg)
    endif (MSVC)
endmacro (add_rc)


##  Add precompiled header files to the ${SourcesVar}.
##
##  Usage:
##    add_pch (mytarget_SOURCES "StdAfx.h" "StdAfx.cpp")
##
##  TODO: Consider non-MSVC compilers.
macro (add_pch SourcesVar PrecompiledHeader PrecompiledSource)
    if (MSVC)
        get_filename_component(PrecompiledBasename ${PrecompiledHeader} NAME_WE)
        set(PrecompiledBinary "${CMAKE_CURRENT_BINARY_DIR}/${PrecompiledBasename}.pch")
        set(Sources ${${SourcesVar}})

        set_source_files_properties(${PrecompiledSource} PROPERTIES
            COMPILE_FLAGS "/Yc\"${PrecompiledHeader}\" /Fp\"${PrecompiledBinary}\""
            OBJECT_OUTPUTS "${PrecompiledBinary}"
        )
        set_source_files_properties(${Sources} PROPERTIES
            COMPILE_FLAGS "/Yu\"${PrecompiledHeader}\" /FI\"${PrecompiledHeader}\" /Fp\"${PrecompiledBinary}\""
            OBJECT_DEPENDS "${PrecompiledBinary}"
        )  
    endif (MSVC)

    # Add precompiled header to SourcesVar
    list(APPEND ${SourcesVar} ${PrecompiledSource})
endmacro (add_pch)


##  Use static C runtime library for MSVC compiler.
macro (use_static_vc_runtime)
    if (MSVC)
        foreach(flags
                CMAKE_CXX_FLAGS
                CMAKE_CXX_FLAGS_DEBUG
                CMAKE_CXX_FLAGS_RELEASE
                CMAKE_CXX_FLAGS_MINSIZEREL
                CMAKE_CXX_FLAGS_RELWITHDEBINFO
                CMAKE_C_FLAGS
                CMAKE_C_FLAGS_DEBUG
                CMAKE_C_FLAGS_RELEASE
                CMAKE_C_FLAGS_MINSIZEREL
                CMAKE_C_FLAGS_RELWITHDEBINFO)
            if(${flags} MATCHES "/MD")
                string(REGEX REPLACE "/MD" "/MT" ${flags} "${${flags}}")
            endif(${flags} MATCHES "/MD")
            if(${flags} MATCHES "/MDd")
                string(REGEX REPLACE "/MDd" "/MTd" ${flags} "${${flags}}")
            endif(${flags} MATCHES "/MDd")
        endforeach(flags)
    endif (MSVC)
endmacro (use_static_vc_runtime)
