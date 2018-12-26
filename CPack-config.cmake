SET (CPACK_PACKAGE_NAME "${PROJECT_NAME}" CACHE STRING "Default project name")
SET (CPACK_PACKAGE_VERSION "${PROJECT_VERSION}" CACHE STRING "")
SET (CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
SET (CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
SET (CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
SET (CPACK_PACKAGE_VENDOR "BioLogica Sistemas S.A.")
SET (CPACK_PACKAGE_DESCRIPTION_SUMMARY "A short description for ${CPACK_PACKAGE_NAME}")
SET (CPACK_PACKAGE_INSTALL_DIRECTORY "BioLogica Sistemas") # MAYBE FOR NSIS
SET (CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}")

INCLUDE (CPack)

#################
# INSTALL TYPES #
#################
CPACK_ADD_INSTALL_TYPE (
	Application
	Developer)

##########
# GROUPS #
##########
CPACK_ADD_COMPONENT_GROUP (
	Runtime
	DESCRIPTION "Runtime application for demonstration porpose")

CPACK_ADD_COMPONENT_GROUP(
	Development
	EXPANDED
	DESCRIPTION "All of the tools you'll ever need to develop software")

##############
# COMPONENTS #
##############
CPACK_ADD_COMPONENT (runtime
	DISPLAY_NAME "${CPACK_PCKAGE_NAME} Application"
	DESCRIPTION "An extremely useful application that makes use of ${CPACK_PACKAGE_NAME}"
	GROUP Runtime
	INSTALL_TYPES Application Full)

CPACK_ADD_COMPONENT (documentation
	DISPLAY_NAME "${CPACK_PACKAGE_NAME} Documentation"
	DESCRIPTION "The extensive suite of ${CPACK_PACKAGE_NAME} documentation files"
	GROUP Development
	INSTALL_TYPES Developer Full)

CPACK_ADD_COMPONENT (libraries
	DISPLAY_NAME "Libraries"
	DESCRIPTION "Libraries used to build programs with ${CPACK_PACKAGE_NAME}"
	GROUP Development
	INSTALL_TYPES Application Developer Full)

CPACK_ADD_COMPONENT (development
	DISPLAY_NAME "C/C++ Headers"
	DESCRIPTION "C/C++ header files for use with ${CPACK_PACKAGE_NAME}"
	GROUP Development
	DEPENDS libraries
	INSTALL_TYPES Developer Full)

#ADD_CUSTOM_COMMAND (TARGET ${PROJECT_TEST_NAME}
#	POST_BUILD
#	COMMAND ${CMAKE_CPACK_COMMAND} -C $<CONFIGURATION>
#	COMMENT "Generating package ${CPACK_GENERATOR} for ${PROJECT_NAME}"
#	WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

#FILE (UPLOAD "${PROJECT_NAME}-${PROJECT_VERSION}.7z" file:///home/jaguar/Desktop)
