CMAKE_MINIMUM_REQUIRED (VERSION 3.0)

MACRO(FIND_AND_INCLUDE _PACKAGE)
	FIND_PACKAGE (${_PACKAGE})
	SET (EXTRA_ARGS ${EXTRA_ARGS} ${${_PACKAGE}_LIBS})
	INCLUDE_DIRECTORIES (${${_PACKAGE}_INCLUDE_DIRS})
ENDMACRO()

IF (NOT DEFINED CMAKE_BUILD_TYPE)
  SET (CMAKE_BUILD_TYPE "Debug" CACHE STRING "Default build type")
  SET_PROPERTY (CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release RelWithDebInfo MinSizeRel)
  MESSAGE (WARNING "CMAKE_BUILD_TYPE not defined, using default value: ${CMAKE_BUILD_TYPE}")
ENDIF()

#######
# Validar o compilador instalado
SET (CMAKE_C_COMPILER /usr/bin/gcc CACHE STRING "Default C compiler")
SET (CMAKE_CXX_COMPILER /usr/bin/g++ CACHE STRING "Default CXX compiler")

SET (CMAKE_CXX_STANDARD 17)
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

PROJECT (${PROJECT_NAME} C CXX)

IF (EXISTS "${CMAKE_SOURCE_DIR}/resources")
  FILE (COPY "${CMAKE_SOURCE_DIR}/resources" DESTINATION "${CMAKE_BINARY_DIR}")
  INCLUDE_DIRECTORIES ("${CMAKE_SOURCE_DIR}/resources")
ENDIF ()

IF (EXISTS "${CMAKE_SOURCE_DIR}/Dependencies.cmake")
  MESSAGE (STATUS "${CMAKE_SOURCE_DIR}/Dependencies.cmake found")
  INCLUDE (Dependencies.cmake)
ENDIF()

INCLUDE_DIRECTORIES ("${CMAKE_SOURCE_DIR}/include")

# Carrega todos os arquivos do diretório src em SOURCE
FILE (GLOB SOURCES "${CMAKE_SOURCE_DIR}/src/*.c*")

# Cria a lista de projetos que podem ser definidos para serem criados
SET_PROPERTY (CACHE PROJECT_TYPE PROPERTY STRINGS Binary Library Header)

# Verifica se o diretório ${CMAKE_SOURCE_DIR}/src/ esta vazio
# Se o diretório estiver vazio então define o projeto como sendo do tipo
# que vai conter apenas headers
# Este trecho desconsidera a opção passada pela linha de comando caso o
# diretório esteja vazio
LIST (LENGTH SOURCES SOURCES_LENGTH)
IF (${SOURCES_LENGTH} EQUAL 0)
  SET (PROJECT_TYPE "Header")
ELSE ()
  INCLUDE_DIRECTORIES ("${CMAKE_SOURCE_DIR}/src")
  MESSAGE (STATUS "Sources: ${SOURCES}")
ENDIF()

# Caso não tenha sido definido ainda, define como Library para projetos e
# lança uma mensagem de aviso informando o ocorrido
IF (NOT DEFINED PROJECT_TYPE)
  SET (PROJECT_TYPE "Library" CACHE STRING "Default artifact build type")
  MESSAGE (WARNING "PROJECT_TYPE was not defined, using default value: ${PROJECT_TYPE}")
ENDIF()

MESSAGE (STATUS "Building project as ${PROJECT_TYPE}")
IF (PROJECT_TYPE STREQUAL "Header")
  ADD_LIBRARY(${PROJECT_NAME} INTERFACE)
ELSEIF (PROJECT_TYPE STREQUAL "Library")
  ADD_LIBRARY(${PROJECT_NAME} "${SOURCES}")
  IF (UNIX)
    SET_TARGET_PROPERTIES (${PROJECT_NAME} PROPERTIES
      OUTPUT_NAME ${PROJECT_NAME}
      VERSION ${GENERIC_LIB_VERSION}
      SOVERSION ${GENERIC_LIB_SOVERSION})
  ENDIF()
ELSE (PROJECT_TYPE STREQUAL "Binary")
  ADD_EXECUTABLE (${PROJECT_NAME} "${SOURCES}")
ENDIF ()

TARGET_LINK_LIBRARIES (${PROJECT_NAME} ${EXTRA_ARGS})

INSTALL (
  TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}Targets
  # RUNTIME refers to the runtime piece of the target. Runtime piece only applies to executable targets and DLL (Windows) style shared libraries
  RUNTIME DESTINATION ${RUNTIME_DIR}
  # LIBRARY refers to all the other (non DLL) shared libraries and modules.
  LIBRARY DESTINATION ${LIBRARY_DIR}
  # ARCHIVE refers to the static libraries and the import parts of DLL libraries (LIB files).
  ARCHIVE DESTINATION ${LIBRARY_DIR})

# INSTALL (
#   DIRECTORY ${CMAKE_SOURCE_DIR}/include/
#   DESTINATION ${INCLUDE_DIR}/${PROJECT_NAME}-${VERSION_SHORT}
#   FILES_MATCHING PATTERN "*.h*")

INSTALL (
  DIRECTORY ${CMAKE_SOURCE_DIR}/include/
  DESTINATION ${INCLUDE_DIR}/${PROJECT_NAME}
  FILES_MATCHING PATTERN "*.h*")

INSTALL (
  EXPORT ${PROJECT_NAME}Targets
  FILE "${PROJECT_NAME}Targets.cmake"
  DESTINATION lib/${PROJECT_NAME}-${VERSION_SHORT})

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
        "${CMAKE_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION lib/${PROJECT_NAME}-${VERSION_SHORT})

WRITE_BASIC_PACKAGE_VERSION_FILE(
  ${CMAKE_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  VERSION ${VERSION_SHORT}
  COMPATIBILITY SameMajorVersion)

IF(EXISTS ${CMAKE_SOURCE_DIR}/test)
  ENABLE_TESTING()
  INCLUDE (CTest)
ENDIF()
