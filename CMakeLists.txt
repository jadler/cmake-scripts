CMAKE_MINIMUM_REQUIRED (VERSION 3.0)

#IF (NOT DEFINED BUILD_SHARED_LIBS)
#  SET (BUILD_SHARED_LIBS ON CACHE BOOL "Default library build type")
#  MESSAGE (WARNING "BUILD_SHARED_LIBS not defined, using default value: ${BUILD_SHARED_LIBS}")
#ENDIF()

IF (NOT DEFINED CMAKE_BUILD_TYPE)
  SET (CMAKE_BUILD_TYPE "Debug" CACHE STRING "Default build type")
  SET_PROPERTY (CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release RelWithDebInfo MinSizeRel)
  MESSAGE (WARNING "CMAKE_BUILD_TYPE not defined, using default value: ${CMAKE_BUILD_TYPE}")
ENDIF()

IF (NOT DEFINED TARGET_TYPE)
  SET (TARGET_TYPE "Library" CACHE STRING "Default artifact build type")
  SET_PROPERTY (CACHE TARGET_TYPE PROPERTY STRINGS Binary Library)
  MESSAGE (WARNING "TARGET_TYPE was not defined, using default value: ${TARGET_TYPE}")
ENDIF()

IF (NOT DEFINED BUILD_TESTS)
  SET (BUILD_TESTS OFF CACHE BOOL "Default build tests")
  MESSAGE (WARNING "BUILD_TESTS not defined, using default value: ${BUILD_TESTS}")
ENDIF()

#######
# Validar o compilador instalado
SET (CMAKE_C_COMPILER /usr/bin/gcc CACHE STRING "Default C compiler")
SET (CMAKE_CXX_COMPILER /usr/bin/g++ CACHE STRING "Default CXX compiler")

SET (CMAKE_CXX_STANDARD 17)
# set_property(TARGET tgt PROPERTY CXX_STANDARD 11)
SET (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

SET (EXTRA_DEBUG_FLAGS "${EXTRA_DEBUG_FLAGS} -Wall -ansi -O0 -fprofile-arcs -ftest-coverage")
SET (CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG} ${EXTRA_DEBUG_FLAGS}")
SET (CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG} ${EXTRA_DEBUG_FLAGS}")

SET (CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} ${EXTRA_DEBUG_FLAGS}")
SET (CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} ${EXTRA_DEBUG_FLAGS}")
SET (CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS_DEBUG} ${EXTRA_DEBUG_FLAGS}")

SET (VERSION_MAJOR 1 CACHE STRING "Default major version")
SET (VERSION_MINOR 0 CACHE STRING "Default minor version")
SET (VERSION_PATCH 0 CACHE STRING "Default patch version")
SET (VERSION_TWEAK 0 CACHE STRING "Default tweak version")

SET (VERSION_SHORT "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")
SET (VERSION_FULL "${VERSION_SHORT}-${VERSION_TWEAK}")
SET (GENERIC_LIB_VERSION ${VERSION_SHORT})
STRING (SUBSTRING ${VERSION_SHORT} 0 1 GENERIC_LIB_SOVERSION)

# Atribui o nome do diretório à variável ${PROJECT_NAME}, esta variável
# é criada pala macro PROJECT().
GET_FILENAME_COMPONENT (PROJECT_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
SET (PROJECT_NAME ${PROJECT_NAME} CACHE STRING "Default project name")

SET (RUNTIME_DIR bin CACHE PATH "Installation directory for binaries")
SET (LIBRARY_DIR lib CACHE PATH "Installation directory for libraries")
SET (INCLUDE_DIR include CACHE PATH "Installation directory for header files")

OPTION (CMAKE_INCLUDE_CURRENT_DIR "Add the source and build directories to the include path" ON)

# Carrega todos os arquivos do diretório src em SOURCE
FILE (GLOB SOURCES "src/*.c*")
INCLUDE_DIRECTORIES (${CMAKE_SOURCE_DIR}/include)
INCLUDE_DIRECTORIES (${CMAKE_SOURCE_DIR}/src)
INCLUDE_DIRECTORIES (${CMAKE_SOURCE_DIR}/resources)

IF (EXISTS "${CMAKE_SOURCE_DIR}/resources")
  FILE (COPY "resources" DESTINATION "${CMAKE_BINARY_DIR}")
ENDIF ()

PROJECT (${PROJECT_NAME} C CXX)

################################################################################
################################################################################
################################################################################
################################################################################

IF (EXISTS "${CMAKE_SOURCE_DIR}/Dependencies.cmake")
  MESSAGE (STATUS "Dependencies.cmake found")
  INCLUDE (Dependencies.cmake)
ENDIF()

MESSAGE (STATUS "Building project as ${TARGET_TYPE}")
MESSAGE (STATUS "Sources: ${SOURCES}")

IF (TARGET_TYPE STREQUAL "Library")
  ADD_LIBRARY(${PROJECT_NAME} "${SOURCES}")
ELSE ()
  ADD_EXECUTABLE (${PROJECT_NAME} "${SOURCES}")
ENDIF ()

TARGET_LINK_LIBRARIES (${PROJECT_NAME} ${EXTRA_ARGS})
IF (UNIX)
  SET_TARGET_PROPERTIES (${PROJECT_NAME} PROPERTIES
    OUTPUT_NAME ${PROJECT_NAME}
    VERSION ${GENERIC_LIB_VERSION}
    SOVERSION ${GENERIC_LIB_SOVERSION})
ENDIF()
################################################################################
################################################################################
################################################################################
################################################################################

INSTALL (
  TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}Targets
  # RUNTIME refers to the runtime piece of the target. Runtime piece only applies to executable targets and DLL (Windows) style shared libraries
  RUNTIME DESTINATION ${RUNTIME_DIR}
  # LIBRARY refers to all the other (non DLL) shared libraries and modules.
  LIBRARY DESTINATION ${LIBRARY_DIR}
  # ARCHIVE refers to the static libraries and the import parts of DLL libraries (LIB files).
  ARCHIVE DESTINATION ${LIBRARY_DIR})

INSTALL (
  DIRECTORY ${CMAKE_SOURCE_DIR}/include/
  DESTINATION ${INCLUDE_DIR}
  FILES_MATCHING PATTERN "*.h*")

INSTALL (
  EXPORT ${PROJECT_NAME}Targets
  FILE "${PROJECT_NAME}Targets.cmake"
  DESTINATION lib/${PROJECT_NAME})

INCLUDE (${CMAKE_SOURCE_DIR}/Configure.cmake)
CONFIGURE_PACKAGE_CONFIG_FILE(
  "${CMAKE_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  INSTALL_DESTINATION ${LIB_INSTALL_DIR}/${PROJECT_NAME}
  PATH_VARS
  INCLUDE_DIR
  LIBRARY_DIR
  RUNTIME_DIR)

INSTALL (
  FILES "${CMAKE_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  DESTINATION lib/${PROJECT_NAME})

WRITE_BASIC_PACKAGE_VERSION_FILE(
  ${CMAKE_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  VERSION ${VERSION_SHORT}
  COMPATIBILITY SameMajorVersion)

INSTALL (
  FILES "${CMAKE_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION lib/${PROJECT_NAME})

IF (BUILD_TESTS AND NOT BS_BUILD MATCHES "EXECUTABLE")
  #################
  #			CTEST			#
  #################
  SET (PROJECT_TEST_NAME ${PROJECT_NAME}Test CACHE STRING "Default project test name")
  SET_PROPERTY (DIRECTORY PROPERTY COMPILE_DEFINITIONS __TEST_CLASS__=${PROJECT_TEST_NAME})
  SET (EXTRA_TEST_ARGS ${EXTRA_TEST_ARGS} ${PROJECT_NAME})

  ENABLE_TESTING ()
  FIND_PACKAGE (GTest REQUIRED)
  INCLUDE_DIRECTORIES (${GTEST_INCLUDE_DIRS})
  SET (EXTRA_TEST_ARGS ${EXTRA_TEST_ARGS} ${GTEST_BOTH_LIBRARIES} ${EXTRA_ARGS})

  # FIND_PACKAGE (GMock REQUIRED)
  # INCLUDE_DIRECTORIES (${GMOCK_INCLUDE_DIRS})
  # SET (EXTRA_TEST_ARGS ${EXTRA_TEST_ARGS} ${GMOCK_BOTH_LIBRARIES})

  #Carrega todos os arquivos de código fonte em SOURCE
  FILE (GLOB TESTS_SOURCES "test/src/*.c*")

  IF (EXISTS "test/resources")
    FILE (COPY "test/resources" DESTINATION "${CMAKE_BINARY_DIR}")
  ENDIF ()

  ADD_EXECUTABLE (${PROJECT_TEST_NAME} ${TESTS_SOURCES})
  TARGET_LINK_LIBRARIES (${PROJECT_TEST_NAME} ${EXTRA_TEST_ARGS} ${PROJECT_NAME})

#Cria uma entrada com o mesmo nome ${PROJECT_TEST_NAME} para ser executado pelo comando make test
ADD_TEST (${PROJECT_TEST_NAME} ${PROJECT_TEST_NAME})

INCLUDE (CTest)
ENDIF()

# Configurações de empacotamento do projeto
OPTION (PACKAGE "Enable generate installer" OFF)
IF (PACKAGE)
  #################
  #			CPACK			#
  #################
  IF (NOT DEFINED CPACK_GENERATOR)

    MESSAGE (AUTHOR_WARNING "No generator specified, package option will be disabled")

  ELSE ()

    SET (CPACK_PACKAGE_VERSION "${VERSION_FULL}")
    SET (CPACK_PACKAGE_VERSION_MAJOR "${VERSION_MAJOR}")
    SET (CPACK_PACKAGE_VERSION_MINOR "${VERSION_MINOR}")
    SET (CPACK_PACKAGE_VERSION_PATCH "${VERSION_PATCH}")
    SET (CPACK_PACKAGE_NAME "${PROJECT_NAME}" CACHE STRING "Default package name")
    SET (CPACK_PACKAGE_VENDOR "BioLogica Sistemas S.A" CACHE STRING "Default package vendor name")
    SET (CPACK_PACKAGE_DESCRIPTION_SUMMARY "" CACHE STRING "Short description summary")
    SET (CPACK_PACKAGE_INSTALL_DIRECTORY "BioLogica Sistemas" CACHE STRING "Default installation directory")
    SET (CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${VERSION_FULL}" CACHE STRING "Package file name without extension")

    MESSAGE (STATUS "cpack generator: ${CPACK_GENERATOR}")

    ##############################################################################
    #  - Bloco de configurações para empacotamento NSIS                          #
    #  - Não usado no momento                                                    #
    ##############################################################################
    #IF (CPACK_GENERATOR MATCHES "NSIS")
    #  INCLUDE (UseBSNSIS)
    #ENDIF()

    ##############################################################################
    #  - Deve ser chamado sempre após as configurações terem sido carregadas     #
    ##############################################################################
    INCLUDE (CPack)

    # Instalation types
    CPACK_ADD_INSTALL_TYPE (Developer)

    # Component groups
    CPACK_ADD_COMPONENT_GROUP (
      Runtime)

    CPACK_ADD_COMPONENT_GROUP (
      Development
      EXPANDED
      DESCRIPTION "All of the tools you'll ever need to develop software")

    # Components
    CPACK_ADD_COMPONENT (applications
      DISPLAY_NAME "${PROJECT_NAME} Application"
      DESCRIPTION "An extremely useful application that makes use of ${PROJECT_NAME}"
      GROUP Runtime
      INSTALL_TYPES Full)

    CPACK_ADD_COMPONENT (documentation
      DISPLAY_NAME "${PROJECT_NAME} Documentation"
      DESCRIPTION "The extensive suite of ${PROJECT_NAME} Application documentation files"
      GROUP Runtime
      INSTALL_TYPES Full)

    CPACK_ADD_COMPONENT (libraries
      DISPLAY_NAME "Libraries"
      DESCRIPTION "Static libraries used to build programs with ${PROJECT_NAME}"
      GROUP Development
      INSTALL_TYPES Developer Full)

    CPACK_ADD_COMPONENT (headers
      DISPLAY_NAME "C++ Headers"
      DESCRIPTION "C/C++ header files for use with ${PROJECT_NAME}"
      GROUP Development
      DEPENDS libraries
      INSTALL_TYPES Developer Full)

  ENDIF()
ENDIF()
