INCLUDE_DIRECTORIES (${CMAKE_INSTALL_PREFIX}/include)

GET_TARGET_PROPERTY (_TYPE ${PROJECT_NAME} TYPE)
IF (NOT "${_TYPE}" STREQUAL "EXECUTABLE")
	MESSAGE (FATAL_ERROR "Test projects MUST be executable")
ENDIF()

AUX_SOURCE_DIRECTORY (${CMAKE_CURRENT_SOURCE_DIR}/src _SOURCES)
TARGET_SOURCES (${PROJECT_NAME} PRIVATE ${_SOURCES})

FIND_PACKAGE (GTest REQUIRED)
LINK_DIRECTORIES (${PROJECT_NAME} ${CMAKE_BINARY_DIR})
TARGET_LINK_LIBRARIES (${PROJECT_NAME} PRIVATE ${GTEST_BOTH_LIBRARIES})

TARGET_INCLUDE_DIRECTORIES (${PROJECT_NAME}
	PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/include
		${GTEST_INCLUDE_DIRS})

IF (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/resources")
	FILE (COPY "${CMAKE_CURRENT_SOURCE_DIR}/resources" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
ENDIF ()

#INSTALL (TARGETS ${PROJECT_NAME}
#	RUNTIME DESTINATION bin COMPONENT runtime)

ENABLE_TESTING ()
INCLUDE (CTest)
INCLUDE (GoogleTest)
GTEST_ADD_TESTS (TARGET ${PROJECT_NAME} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
