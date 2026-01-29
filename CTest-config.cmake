# ------------------------------------------------------------
# CTest-config.cmake (multi-target)
# One test executable per source file
# ------------------------------------------------------------

include(CTest)

# PACKAGE_TARGETS must be defined by the project
if (NOT DEFINED PACKAGE_TARGETS)
    message(FATAL_ERROR "PACKAGE_TARGETS is not defined (required for tests)")
endif ()

foreach(t IN LISTS PACKAGE_TARGETS)

    # --------------------------------------------------------
    # Expected test source directory
    # test/<target>/src
    # --------------------------------------------------------
    set(TEST_SOURCE_DIR
        "${CMAKE_CURRENT_SOURCE_DIR}/test/${t}/src"
    )

    set(TEST_RESOURCES_DIR
        "${CMAKE_CURRENT_SOURCE_DIR}/test/${t}/resources"
    )

    set(TEST_RUNTIME_DIR
        "${CMAKE_CURRENT_BINARY_DIR}/test/${t}.d"
    )

    # If no test directory, silently skip
    if (NOT EXISTS "${TEST_SOURCE_DIR}")
        continue()
    endif ()

    # --------------------------------------------------------
    # Collect test sources
    # --------------------------------------------------------
    file(GLOB_RECURSE TEST_SOURCES
        "${TEST_SOURCE_DIR}/*.c"
        "${TEST_SOURCE_DIR}/*.cc"
        "${TEST_SOURCE_DIR}/*.cpp"
        "${TEST_SOURCE_DIR}/*.cxx"
    )

    # If no source files, skip
    if (TEST_SOURCES STREQUAL "")
        continue()
    endif ()

    foreach(TEST_FILE IN LISTS TEST_SOURCES)

        # ----------------------------------------------------
        # Extract file name and remove only last extension
        # ----------------------------------------------------
        get_filename_component(TEST_FILE_NAME "${TEST_FILE}" NAME)
        string(REGEX REPLACE "\\.[^.]+$" "" TEST_BIN_NAME "${TEST_FILE_NAME}")

        # ----------------------------------------------------
        # Prefix with target to avoid collisions/reserved names
        # ----------------------------------------------------
        set(TEST_BIN_NAME "${t}_${TEST_BIN_NAME}")

        # ----------------------------------------------------
        # Create test executable
        # ----------------------------------------------------
        add_executable("${TEST_BIN_NAME}")

        set_target_properties("${TEST_BIN_NAME}" PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY "${TEST_RUNTIME_DIR}"
        )

        target_sources("${TEST_BIN_NAME}" PRIVATE "${TEST_FILE}")
        
        add_custom_command(
            TARGET "${TEST_BIN_NAME}" POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory "${TEST_RUNTIME_DIR}"
        )

        if (EXISTS "${TEST_RESOURCES_DIR}")
            add_custom_command(
                TARGET "${TEST_BIN_NAME}" POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_directory
                "${TEST_RESOURCES_DIR}"
                "${TEST_RUNTIME_DIR}"
            )
        endif ()

        # ----------------------------------------------------
        # Include public headers (if any)
        # ----------------------------------------------------
        if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
            target_include_directories("${TEST_BIN_NAME}"
                PRIVATE
                    "${CMAKE_CURRENT_SOURCE_DIR}/include"
            )
        endif ()

        # ----------------------------------------------------
        # Link test target with the library under test
        # ----------------------------------------------------
        target_link_libraries("${TEST_BIN_NAME}" PRIVATE "${t}")

        # Ensure correct build order
        add_dependencies("${TEST_BIN_NAME}" "${t}")

        # ----------------------------------------------------
        # Register with CTest
        # ----------------------------------------------------
        add_test(
            NAME "${TEST_BIN_NAME}.test"
            WORKING_DIRECTORY "${TEST_RUNTIME_DIR}"
            COMMAND "${TEST_BIN_NAME}"
        )

    endforeach ()

endforeach ()
