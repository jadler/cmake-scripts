FIND_PROGRAM (CTEST_COVERAGE_COMMAND NAMES gcov)
FIND_PROGRAM (CTEST_MEMORYCHECK_COMMAND NAMES valgrind)

## As variáveis CTEST_SOURCE_DIRECTORY e CTEST_BINARY_DIRECTORY
## devem ser definidas pela linha de comando.

## As variáveis MODULE_PATH e INSTALL_PREFIX devem ser definidas
## através da linha de comando, estas variáveis apontam para os locais
## aonde estão os módulos cmake e os artefatos instalados.
SET (CTEST_CMAKE_COMMAND "cmake -DCMAKE_BUILD_TYPE=Debug \
	-DCMAKE_MODULE_PATH=${MODULE_PATH} \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}")

SET (MODEL "Experimental")
SET (CTEST_COMMAND "ctest -D ${MODEL}Start -D ${MODEL}Configure -D ${MODEL}Build -D ${MODEL}Test")

SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)

SET (CTEST_ENVIRONMENT
	"GTEST_COLOR=1"
	"CTEST_OUTPUT_ON_FAILURE=1"
)
