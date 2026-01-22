#
# CMake-config.cmake (multi-target, package-first, instalação isolada)
#

# --------------------------------------------------------------------
# Package name
# --------------------------------------------------------------------
if (NOT DEFINED PACKAGE_NAME)
    set(PACKAGE_NAME "${PROJECT_NAME}")
endif ()

# --------------------------------------------------------------------
# Package targets (must be defined by the project)
# --------------------------------------------------------------------
if (NOT DEFINED PACKAGE_TARGETS)
    message(FATAL_ERROR "PACKAGE_TARGETS is not defined")
endif ()

foreach(t IN LISTS PACKAGE_TARGETS)
    if (NOT TARGET "${t}")
        message(FATAL_ERROR "Target '${t}' listed in PACKAGE_TARGETS does not exist")
    endif ()
endforeach ()

# --------------------------------------------------------------------
# Infer public dependencies from all targets
# --------------------------------------------------------------------
include(CMakePackageConfigHelpers)

set(PROJECT_DEPENDENCIES "")

foreach(t IN LISTS PACKAGE_TARGETS)

    get_target_property(_LINK_LIBS "${t}" INTERFACE_LINK_LIBRARIES)
    if (NOT _LINK_LIBS)
        continue()
    endif ()

    foreach(lib IN LISTS _LINK_LIBS)

        if (TARGET "${lib}")
            get_target_property(_IMPORTED "${lib}" IMPORTED)

            if (_IMPORTED AND lib MATCHES "^([^:]+)::")
                set(_PKG "${CMAKE_MATCH_1}")
                string(APPEND PROJECT_DEPENDENCIES
                    "find_dependency(${_PKG} REQUIRED)\n"
                )
            endif ()
        endif ()

    endforeach ()

endforeach ()

# Remove duplicates
string(REPLACE "\n" ";" _DEP_LIST "${PROJECT_DEPENDENCIES}")
list(REMOVE_DUPLICATES _DEP_LIST)
string(REPLACE ";" "\n" PROJECT_DEPENDENCIES "${_DEP_LIST}")

# Allow manual override / extension
set(PROJECT_DEPENDENCIES "${PROJECT_DEPENDENCIES}" CACHE STRING
    "Extra find_dependency() calls"
)

# --------------------------------------------------------------------
# Export all targets together
# --------------------------------------------------------------------
if (NOT DEFINED NAMESPACE)
    set(NAMESPACE "${PACKAGE_NAME}")
endif ()

# --------------------------------------------------------------------
# Install prefix isolado
# --------------------------------------------------------------------
if (NOT DEFINED INSTALL_PREFIX)
    set(INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
endif()

# --------------------------------------------------------------------
# Config + version files
# --------------------------------------------------------------------
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}ConfigVersion.cmake"
    COMPATIBILITY SameMajorVersion
)

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}Config.cmake"
    @ONLY
)

# --------------------------------------------------------------------
# Runtime instalation
# --------------------------------------------------------------------
install(TARGETS ${PACKAGE_TARGETS}
    EXPORT ${PACKAGE_NAME}Targets
    LIBRARY DESTINATION ${INSTALL_PREFIX}/lib COMPONENT runtime
    ARCHIVE DESTINATION ${INSTALL_PREFIX}/lib COMPONENT runtime
    RUNTIME DESTINATION ${INSTALL_PREFIX}/bin COMPONENT runtime
)

# --------------------------------------------------------------------
# Development instalation
# Headers, configs and export files
# --------------------------------------------------------------------
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}Config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}ConfigVersion.cmake"
    DESTINATION "${INSTALL_PREFIX}/cmake/${PACKAGE_NAME}"
    COMPONENT development
)

install(EXPORT ${PACKAGE_NAME}Targets
    FILE ${PACKAGE_NAME}Targets.cmake
    NAMESPACE ${NAMESPACE}::
    DESTINATION ${INSTALL_PREFIX}/cmake/${PACKAGE_NAME}
    COMPONENT development
)

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
    install(DIRECTORY include/
        DESTINATION ${INSTALL_PREFIX}/include
        COMPONENT development
    )
endif ()

# --------------------------------------------------------------------
# Testes automáticos
# --------------------------------------------------------------------
option(SKIP_TESTING "Skips the test building phase." OFF)

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/test" AND NOT SKIP_TESTING)
    include(CTest)

    # Inclui CTest-config do toolkit multi-target
    # Assume que PACKAGE_TARGETS está definido
    include("${CMAKE_CURRENT_LIST_DIR}/CTest-config.cmake")
endif()

# --------------------------------------------------------------------
# Empacotamento com CPack
# --------------------------------------------------------------------
if (NOT "${CPACK_GENERATOR}" STREQUAL "")
    include("${CMAKE_CURRENT_LIST_DIR}/CPack-config.cmake")
endif()

