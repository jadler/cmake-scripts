SET (INCLUDE_INSTALL_DIR include/ CACHE PATH "Installation directory for header files")
SET (LIBRARY_INSTALL_DIR lib/ CACHE PATH "Installation directory for libraries")
SET (RUNTIME_INSTALL_DIR bin/ CACHE PATH "Installation directory for binaries")
SET (SYSCONF_INSTALL_DIR etc/ CACHE PATH "Installation directory for configuration files")
SET (LIBRARIES_FILES "" CACHE STRING "Define empty set of libraries for ${PROJECT_NAME}")

IF (NOT DEFINED PROJECT_TYPES)
	SET (PROJECT_TYPES "Header Library" CACHE STRING "Default artifact build type")
	#SET_PROPERTY (CACHE PROJECT_TYPES PROPERTY STRINGS Header Library Binary)
	MESSAGE (WARN "PROJECT_TYPES not defined, setting default value: '${PROJECT_TYPES}'")
ENDIF ()

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/include)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/src)

MESSAGE (STATUS "Building ${PROJECT_NAME} version ${PROJECT_VERSION} as a ${PROJECT_TYPES} project")
FOREACH (TYPE ${PROJECT_TYPES})
	STRING (TOLOWER ${TYPE} TYPE)
	INCLUDE (${CMAKE_CURRENT_LIST_DIR}/artifact-type/${TYPE}.cmake)
ENDFOREACH()

SET (PROJECT_CONFIG_FILE "${CMAKE_BINARY_DIR}/${PROJECT_NAME}Config.cmake")
SET (PROJECT_VERSION_FILE "${CMAKE_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake")

IF (NOT EXISTS ${PROJECT_CONFIG_FILE} OR NOT EXISTS ${PROJECT_VERSION_FILE})
	INCLUDE (CMakePackageConfigHelpers)
	CONFIGURE_PACKAGE_CONFIG_FILE (
		"${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in"
		"${PROJECT_CONFIG_FILE}"
		INSTALL_DESTINATION ${LIBRARY_INSTALL_DIR}/${PROJECT_NAME}/cmake
		PATH_VARS
		INCLUDE_INSTALL_DIR
		LIBRARY_INSTALL_DIR
		SYSCONF_INSTALL_DIR
		RUNTIME_INSTALL_DIR)

	WRITE_BASIC_PACKAGE_VERSION_FILE (
		"${PROJECT_VERSION_FILE}"
		COMPATIBILITY SameMajorVersion)

	INSTALL (FILES
		"${PROJECT_CONFIG_FILE}"
		"${PROJECT_VERSION_FILE}"
		DESTINATION ${LIBRARY_INSTALL_DIR}/${PROJECT_NAME}/cmake)

ENDIF ()

OPTION (SKIP_TESTS "Skip build tests for ${PROJECT_NAME} project" OFF)
IF (NOT SKIP_TESTS AND EXISTS ${CMAKE_SOURCE_DIR}/test)
	MESSAGE (STATUS "Buliding tests for ${PROJECT_NAME}")
	ENABLE_TESTING ()
	INCLUDE (CTest)
	INCLUDE (${CMAKE_CURRENT_LIST_DIR}/CTestConfig.cmake)
ENDIF ()

#INCLUDE (${CMAKE_CURRENT_LIST_DIR}/NSISCPackConfig.cmake) # Para
