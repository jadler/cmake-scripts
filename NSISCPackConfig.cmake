# Configurações de empacotamento do projeto

SET (CPACK_GENERATOR "NSIS")
SET (CPACK_NSIS_MODIFY_PATH OFF)
SET (CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)

SET (CPACK_PACKAGE_VERSION "${VERSION_FULL}")
SET (CPACK_PACKAGE_VERSION_MAJOR "${VERSION_MAJOR}")
SET (CPACK_PACKAGE_VERSION_MINOR "${VERSION_MINOR}")
SET (CPACK_PACKAGE_VERSION_PATCH "${VERSION_PATCH}")
SET (CPACK_PACKAGE_NAME "${PROJECT_NAME}" CACHE STRING "Default package name")
SET (CPACK_PACKAGE_VENDOR "BioLogica Sistemas S.A" CACHE STRING "Default package vendor name")
SET (CPACK_PACKAGE_DESCRIPTION_SUMMARY "" CACHE STRING "Short description summary")
SET (CPACK_PACKAGE_INSTALL_DIRECTORY "BioLogica Sistemas" CACHE STRING "Default installation directory")
SET (CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${VERSION_FULL}" CACHE STRING "Package file name without extension")

##############################################################################
#  - Deve ser chamado sempre após as configurações terem sido definidas      #
##############################################################################
INCLUDE (CPack)

# Instalation types
CPACK_ADD_INSTALL_TYPE (
  Developer
  Full
)

# # Component groups
# CPACK_ADD_COMPONENT_GROUP (
#   Runtime
# )
#
# CPACK_ADD_COMPONENT_GROUP (
#   Development
#   EXPANDED
#   DESCRIPTION "All of the tools you'll ever need to develop software"
# )

# Components
CPACK_ADD_COMPONENT (applications
  DISPLAY_NAME "${PROJECT_NAME} Application"
  DESCRIPTION "An extremely useful application that makes use of ${PROJECT_NAME}"
  INSTALL_TYPES Full
)

CPACK_ADD_COMPONENT (documentation
  DISPLAY_NAME "${PROJECT_NAME} Documentation"
  DESCRIPTION "The extensive suite of ${PROJECT_NAME} Application documentation files"
  INSTALL_TYPES Developer Full
)

CPACK_ADD_COMPONENT (libraries
  DISPLAY_NAME "${PROJECT_NAME} Libraries"
  DESCRIPTION "Static libraries used to build programs with ${PROJECT_NAME}"
  INSTALL_TYPES Developer Full
)

CPACK_ADD_COMPONENT (headers
  DISPLAY_NAME "${PROJECT_NAME} Headers"
  DESCRIPTION "C/C++ header files for use with ${PROJECT_NAME}"
  DEPENDS libraries
  INSTALL_TYPES Developer Full
)
