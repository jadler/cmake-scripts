# Carrega todos os arquivos do diretório src em SOURCE
FILE (GLOB SOURCES "${CMAKE_SOURCE_DIR}/src/*.c*")

# Cria a lista de projetos que podem ser definidos para serem criados
#SET_PROPERTY (CACHE PROJECT_TYPE PROPERTY STRINGS Binary Library Header)

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
ENDIF ()

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

