SET (CPACK_PACKAGE_NAME "${PROJECT_NAME}" CACHE STRING "")
SET (CPACK_PACKAGE_VERSION "${PROJECT_VERSION}" CACHE STRING "")
SET (CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}" CACHE STRING "")
SET (CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}" CACHE STRING "")
SET (CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}" CACHE STRING "")
SET (CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}" CACHE STRING "")

INCLUDE (CPack)

#################
# INSTALL TYPES #
#################
CPACK_ADD_INSTALL_TYPE (
	Application
	Development)

##########
# GROUPS #
##########
CPACK_ADD_COMPONENT_GROUP (
	Runtime
	DESCRIPTION "Runtime application for demonstration porpose")

CPACK_ADD_COMPONENT_GROUP(
	Develop
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
	GROUP Develop
	INSTALL_TYPES Development Full)

CPACK_ADD_COMPONENT (libraries
	DISPLAY_NAME "Libraries"
	DESCRIPTION "Libraries used to build programs with ${CPACK_PACKAGE_NAME}"
	GROUP Develop
	INSTALL_TYPES Application Development Full)

CPACK_ADD_COMPONENT (development
	DISPLAY_NAME "C/C++ Headers"
	DESCRIPTION "C/C++ header files for use with ${CPACK_PACKAGE_NAME}"
	GROUP Develop
	DEPENDS libraries
	INSTALL_TYPES Development Full)
