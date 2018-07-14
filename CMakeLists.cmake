SET (INCLUDE_INSTALL_DIR include/ CACHE PATH "Installation directory for header files")
SET (LIBRARY_INSTALL_DIR lib/ CACHE PATH "Installation directory for libraries")
SET (RUNTIME_INSTALL_DIR bin/ CACHE PATH "Installation directory for binaries")
SET (SYSCONF_INSTALL_DIR bin/ CACHE PATH "Installation directory for configuration files")


IF (NOT DEFINED PROJECT_TYPES)
	SET (PROJECT_TYPES "Header Library" CACHE STRING "Default artifact build type")
	#SET_PROPERTY (CACHE PROJECT_TYPES PROPERTY STRINGS Header Library Binary)
	MESSAGE (WARN "PROJECT_TYPES not defined, setting default value: '${PROJECT_TYPES}'")
ENDIF ()

INCLUDE_DIRECTORIES (${CMAKE_SOURCE_DIR}/include)
INCLUDE_DIRECTORIES (${CMAKE_SOURCE_DIR}/src)

MESSAGE (STATUS "Building ${PROJECT_NAME} version ${PROJECT_VERSION} as a ${PROJECT_TYPES} project")
FOREACH (TYPE ${PROJECT_TYPES})
	STRING (TOLOWER ${TYPE} TYPE)
	INCLUDE (${CMAKE_CURRENT_LIST_DIR}/artifact-type/${TYPE}.cmake)
ENDFOREACH()

OPTION (SKIP_TESTS "Skip build tests for ${PROJECT_NAME} project" OFF)
IF (NOT SKIP_TESTS AND EXISTS ${CMAKE_SOURCE_DIR}/test)
	MESSAGE (STATUS "Buliding tests for ${PROJECT_NAME}")
	ENABLE_TESTING ()
	INCLUDE (CTest)
	INCLUDE (${CMAKE_CURRENT_LIST_DIR}/CTestConfig.cmake)
ENDIF ()

#INCLUDE (${CMAKE_CURRENT_LIST_DIR}/NSISCPackConfig.cmake) # Para
