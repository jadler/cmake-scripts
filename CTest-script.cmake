# ------------------------------------------------------------
# CTest dashboard / CI script
# ------------------------------------------------------------

find_program(CTEST_COVERAGE_COMMAND     NAMES gcov)
find_program(CTEST_MEMORYCHECK_COMMAND  NAMES valgrind)

# ------------------------------------------------------------
# Build configuration
# ------------------------------------------------------------

if(NOT DEFINED CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

set(CTEST_CMAKE_COMMAND
    "cmake
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_MODULE_PATH=${CMAKE_CURRENT_LIST_DIR}
        --no-warn-unused-cli"
)

# ------------------------------------------------------------
# Dashboard model
# ------------------------------------------------------------

if(NOT DEFINED CTEST_MODEL)
    set(CTEST_MODEL Experimental)
endif()

set(CTEST_COMMAND
    "ctest
        -M ${CTEST_MODEL}
        -T start
        -T configure
        -T build
        -T test"
)

# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------

set(CTEST_ENVIRONMENT
    "CTEST_OUTPUT_ON_FAILURE=1"
)
