FIND_PROGRAM (CTEST_COVERAGE_COMMAND NAMES gcov)
FIND_PROGRAM (CTEST_MEMORYCHECK_COMMAND NAMES valgrind)
#FIND_PROGRAM (CTEST_GIT_COMMAND NAMES git)

#SET (CTEST_SOURCE_DIRECTORY "/path/to/project")
SET (CTEST_BINARY_DIRECTORY "${CTEST_SOURCE_DIRECTORY}/build")

#IF (NOT EXISTS "${CTEST_SOURCE_DIRECTORY}")
#	SET (CTEST_CHECKOUT_COMMAND "${CTEST_GIT_COMMAND} clone git://git.server/project.git ${CTEST_SOURCE_DIRECTORY}")
#ENDIF ()

#SET (CTEST_UPDATE_COMMAND "${CTEST_GIT_COMMAND}")

SET (_INSTALL_PREFIX "/home/jaguar/Desktop/projects/modules")
LIST (APPEND CMAKE_MODULE_PATH ${_INSTALL_PREFIX} "/home/jaguar/Desktop/projects/cmake")

SET (CTEST_CMAKE_COMMAND 
	"cmake \
	-DCMAKE_BUILD_TYPE=Debug \
	-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH} \
	-DCMAKE_INSTALL_PREFIX=${_INSTALL_PREFIX}")

SET (MODEL "Experimental")
SET (CTEST_COMMAND "ctest -D ${MODEL}Start -D ${MODEL}Configure -D ${MODEL}Build -D ${MODEL}Test")

SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)

SET (CTEST_ENVIRONMENT
	"GTEST_COLOR=1"
	"CTEST_OUTPUT_ON_FAILURE=1"
)
