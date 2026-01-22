# ------------------------------------------------------------
# Package metadata
# ------------------------------------------------------------
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}" CACHE STRING "")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}" CACHE STRING "")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}" CACHE STRING "")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}" CACHE STRING "")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}" CACHE STRING "")
set(CPACK_PACKAGE_FILE_NAME
    "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}"
    CACHE STRING ""
)

include(CPack)

# ------------------------------------------------------------
# Install types
# ------------------------------------------------------------
# Mantidos apenas os tipos efetivamente usados
CPACK_ADD_INSTALL_TYPE(Application)
CPACK_ADD_INSTALL_TYPE(Development)

# ------------------------------------------------------------
# Component groups
# ------------------------------------------------------------
CPACK_ADD_COMPONENT_GROUP(
    Runtime
    DESCRIPTION "Runtime application components"
)

CPACK_ADD_COMPONENT_GROUP(
    Develop
    EXPANDED
    DESCRIPTION "Development files and libraries"
)

# ------------------------------------------------------------
# Components
# ------------------------------------------------------------

CPACK_ADD_COMPONENT(runtime
    DISPLAY_NAME "${CPACK_PACKAGE_NAME} Runtime"
    DESCRIPTION "Runtime binaries for ${CPACK_PACKAGE_NAME}"
    GROUP Runtime
    INSTALL_TYPES Application
)

CPACK_ADD_COMPONENT(libraries
    DISPLAY_NAME "Libraries"
    DESCRIPTION "Libraries for building against ${CPACK_PACKAGE_NAME}"
    GROUP Develop
    INSTALL_TYPES Application Development
)

CPACK_ADD_COMPONENT(development
    DISPLAY_NAME "C/C++ Headers"
    DESCRIPTION "Header files for ${CPACK_PACKAGE_NAME}"
    GROUP Develop
    DEPENDS libraries
    INSTALL_TYPES Development
)

# Opcional: só faz sentido se houver install() associado em outro lugar
CPACK_ADD_COMPONENT(documentation
    DISPLAY_NAME "${CPACK_PACKAGE_NAME} Documentation"
    DESCRIPTION "Documentation files for ${CPACK_PACKAGE_NAME}"
    GROUP Develop
    INSTALL_TYPES Development
)
