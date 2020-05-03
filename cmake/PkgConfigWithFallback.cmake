include(CMakeParseArguments)

function(find_pkg_config_with_fallback name)
    cmake_parse_arguments(ARGS "" "PKG_CONFIG_NAME" "LIB_NAMES;LIB_DIR_HINTS;INCLUDE_NAMES;INCLUDE_DIR_PATHS;INCLUDE_DIR_HINTS;INCLUDE_DIR_SUFFIXES;DEPENDS" ${ARGN})
    set(${name}_PKG_CONFIG_NAME ${ARGS_PKG_CONFIG_NAME} PARENT_SCOPE)
    find_package(PkgConfig)

    if(PKG_CONFIG_FOUND)
        pkg_search_module(${name}_PKG_CONFIG QUIET ${ARGS_PKG_CONFIG_NAME})
    endif(PKG_CONFIG_FOUND)

    if (${name}_PKG_CONFIG_FOUND)
        # Found via pkg-config, using its result values
        set(${name}_FOUND ${${name}_PKG_CONFIG_FOUND})

        if(MINGW)
            list(FILTER ${name}_PKG_CONFIG_LIBRARIES EXCLUDE REGEX "(ole32)|(gdi32)|(imm32)|(shell32)|(winmm)|(dwmapi)|(setupapi)|(cfgmgr32)|(ws2_32)")
        endif(MINGW)

        # Try to find real file name of libraries
        foreach(lib ${${name}_PKG_CONFIG_LIBRARIES})
            find_library(${name}_${lib}_LIBRARY ${lib} HINTS ${${name}_PKG_CONFIG_LIBRARY_DIRS})
            mark_as_advanced(${name}_${lib}_LIBRARY)
            if(NOT ${name}_${lib}_LIBRARY)
                message(${name} ": " ${lib} " library not found")
                unset(${name}_FOUND)
            endif(NOT ${name}_${lib}_LIBRARY)
        endforeach(lib)
        if(${name}_FOUND)
            set(${name}_LIBRARIES "")
            foreach(lib ${${name}_PKG_CONFIG_LIBRARIES})
                list(APPEND ${name}_LIBRARIES ${${name}_${lib}_LIBRARY})
            endforeach(lib)
            list(REMOVE_DUPLICATES ${name}_LIBRARIES)
            set(${name}_LIBRARIES ${${name}_LIBRARIES} PARENT_SCOPE)
            list(GET ${name}_LIBRARIES "0" ${name}_LIBRARY)

            set(${name}_FOUND ${${name}_FOUND} PARENT_SCOPE)
            set(${name}_INCLUDE_DIRS ${${name}_PKG_CONFIG_INCLUDE_DIRS} PARENT_SCOPE)
            set(${name}_LIBRARIES ${${name}_PKG_CONFIG_LIBRARIES} PARENT_SCOPE)
            set(${name}_LIBRARY ${${name}_LIBRARY} PARENT_SCOPE)
            set(${name}_VERSION ${${name}_PKG_CONFIG_VERSION} PARENT_SCOPE)

            if(NOT TARGET ${ARGS_PKG_CONFIG_NAME})
                add_library(${ARGS_PKG_CONFIG_NAME} INTERFACE IMPORTED)
                set_property(TARGET ${ARGS_PKG_CONFIG_NAME} PROPERTY INTERFACE_COMPILE_OPTIONS "${${name}_PKG_CONFIG_CFLAGS_OTHER}")
                set_property(TARGET ${ARGS_PKG_CONFIG_NAME} PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${${name}_PKG_CONFIG_INCLUDE_DIRS}")
                set_property(TARGET ${ARGS_PKG_CONFIG_NAME} PROPERTY INTERFACE_LINK_LIBRARIES "${${name}_LIBRARIES}")
            endif(NOT TARGET ${ARGS_PKG_CONFIG_NAME})
        endif(${name}_FOUND)
    else(${name}_PKG_CONFIG_FOUND)
        # No success with pkg-config, try via find_library on all lib_names
        set(${name}_FOUND "1")
        foreach(lib ${ARGS_LIB_NAMES})
            find_library(${name}_${lib}_LIBRARY ${ARGS_LIB_NAMES} HINTS ${ARGS_LIB_DIR_HINTS})
            mark_as_advanced(${name}_${lib}_LIBRARY)

            if(NOT ${name}_${lib}_LIBRARY)
                unset(${name}_FOUND)
            endif(NOT ${name}_${lib}_LIBRARY)
        endforeach(lib)

        foreach(inc ${ARGS_INCLUDE_NAMES})
            find_path(${name}_${inc}_INCLUDE_PATH ${inc} HINTS ${ARGS_INCLUDE_DIR_HINTS} PATHS ${ARGS_INCLUDE_DIR_PATHS} PATH_SUFFIXES ${ARGS_INCLUDE_DIR_SUFFIXES})
            mark_as_advanced(${name}_${inc}_INCLUDE_PATH)

            if(NOT ${name}_${inc}_INCLUDE_PATH)
                unset(${name}_FOUND)
            endif(NOT ${name}_${inc}_INCLUDE_PATH)
        endforeach(inc)

        if(${name}_FOUND)
            set(${name}_LIBRARIES "")
            set(${name}_INCLUDE_DIRS "")
            foreach(lib ${ARGS_LIB_NAMES})
                list(APPEND ${name}_LIBRARIES ${${name}_${lib}_LIBRARY})
            endforeach(lib)
            foreach(inc ${ARGS_INCLUDE_NAMES})
                list(APPEND ${name}_INCLUDE_DIRS ${${name}_${inc}_INCLUDE_PATH})
            endforeach(inc)
            list(GET ${name}_LIBRARIES "0" ${name}_LIBRARY)

            foreach(dep ${ARGS_DEPENDS})
                find_package(${dep} ${${dep}_GLOBAL_VERSION} QUIET)

                if(${dep}_FOUND)
                    list(APPEND ${name}_INCLUDE_DIRS ${${dep}_INCLUDE_DIRS})
                    list(APPEND ${name}_LIBRARIES ${${dep}_LIBRARIES})
                else(${dep}_FOUND)
                    unset(${name}_FOUND)
                endif(${dep}_FOUND)
            endforeach(dep)

            set(${name}_FOUND ${${name}_FOUND} PARENT_SCOPE)
            set(${name}_INCLUDE_DIRS ${${name}_INCLUDE_DIRS} PARENT_SCOPE)
            set(${name}_LIBRARIES ${${name}_LIBRARIES} PARENT_SCOPE)
            set(${name}_LIBRARY ${${name}_LIBRARY} PARENT_SCOPE)
            unset(${name}_VERSION PARENT_SCOPE)

            if(NOT TARGET ${ARGS_PKG_CONFIG_NAME})
                add_library(${ARGS_PKG_CONFIG_NAME} INTERFACE IMPORTED)
                set_property(TARGET ${ARGS_PKG_CONFIG_NAME} PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${${name}_INCLUDE_DIRS}")
                set_property(TARGET ${ARGS_PKG_CONFIG_NAME} PROPERTY INTERFACE_LINK_LIBRARIES "${${name}_LIBRARIES}")
            endif(NOT TARGET ${ARGS_PKG_CONFIG_NAME})
        endif(${name}_FOUND)
    endif(${name}_PKG_CONFIG_FOUND)
endfunction()
