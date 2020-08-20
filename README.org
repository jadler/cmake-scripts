# CMake-Scripts

A set of cmake scripts to make it easier to build projects, whether they are modules, interface, executables or libraries.

## CMakeLists.txt

### Libraries

```cmake
CMAKE_MINIMUM_REQUIRED (VERSION 3.9 FATAL_ERROR)

PROJECT ("MyProject" VERSION 1.0.0 LANGUAGES C CXX)

# If TARGET_NAME is not set, the PROJECT_NAME will be used as the target
SET (TARGET_NAME mylib)

# Available values are MODULE, SHARED, STATIC, INTERFACE
ADD_LIBRARY (${TARGET_NAME} MODULE)

# For dependencies with namespace.
FIND_PACKAGE (Commons REQUIRED)
TARGET_LINK_LIBRARIES (${TARGET_NAME}
	PUBLIC
	jadl::Commons)

INCLUDE (CMake-config)
```

### Executables and tests

```cmake
CMAKE_MINIMUM_REQUIRED (VERSION 3.9 FATAL_ERROR)

PROJECT ("MyTest" VERSION 1.0.0 LANGUAGES C CXX)

# For test MUST be ADD_EXECUTABLE or an error will be thrown
ADD_EXECUTABLE (${PROJECT_NAME})

# INCLUDE (CMake-config) for executable
# INCLUDE (CTest-config) for test
```

## Project structure

```bash
project
+- CMakeLists.txt
+- src/
|  +- main.cpp
|  +- source1.cpp
|  +- source2.cpp
|  +- header1.hpp
+- include/
|  +- header1.hpp
|  +- header2.h
|  +- utils/
|     +- utils.hpp
+- test/
   +- src/
      +- main_test.cpp
      +- another_file.cpp
```

## Building

To build in a Linux environment, run the following command:

```bash
$ cmake -S <source_dir> -B <build_dir> -D NAMESPACE=jadl -D CMAKE_MODULE_PATH=<path_to_scripts>
$ DESTDIR=<path_to_install> cmake --build <build_dir> --config release --target install
```

On a Windows environment I believe it should be something like this:

```bash
C:/> cmake -H <source_dir> -B <build_dir> -D NAMESPACE=jadl -D CMAKE_MODULE_PATH=<path_to_scripts>
C:/> cmake --build <build_dir> --config release --target install
```

And for tests

```bash
$ ctest -S <path_to_scripts>/CTest-script.cmake -DCTEST_SOURCE_DIRECTORY="<source_dir>/test" -DCTEST_BINARY_DIRECTORY="<build_dir>" -V
```

or if the test was built along with the project

```bash
$ cd <build_dir>/test
$ ctest
```

The result of the install target will be:

```bash
+- lib
|  +- libmylib.so
|  +- mylib
|     +- cmake
|        +- mylibConfig.cmake
|        +- mylibConfigVersion.cmake
|        +- mylibTargets-release.cmake
|        +- mylibTargets.cmake
+- include
   +- header1.hpp
   +- header2.h
   +- utils/
      +- utils.hpp
```

The mylibConfig.cmake file contains project dependencies that will be loaded transiently.