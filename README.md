# CMake Scripts

A collection of **modern, target-based CMake helper scripts** designed to minimize boilerplate while preserving **predictability**, **scalability**, and **alignment with official CMake best practices**.

This project follows a **convention-over-configuration** approach without introducing macros, DSLs, or hidden behavior.

---

## Goals

- Minimal project configuration
- Zero global include or link directories
- Fully target-based design
- Native support for:
  - `find_package`
  - `add_subdirectory`
  - `install` and `export`
  - CTest
  - CPack
- One test executable per target
- No extra `CMakeLists.txt` for tests
- Scales cleanly to multi-target projects

---

## Core Principles

- **Targets are the public API**
- Consumers link to targets, never variables
- `find_package()` exposes only imported targets
- Tests are automatic, isolated, and opt-in by presence
- Packaging reflects exactly what is installed

---

## Supported Project Types

- Static libraries
- Shared libraries
- Interface libraries
- Executables (build-only, not exported)

---

## Expected Project Layout

```text
.
├── CMakeLists.txt
├── include/
│   └── <public headers>
├── src/
│   └── <private sources>
└── test/
    └── <target-name>/
        └── src/
            └── <test sources>
````

---

## Basic Usage

### Minimal `CMakeLists.txt`

```cmake
cmake_minimum_required(VERSION 3.9)
project(MyLib VERSION 1.0.0 LANGUAGES C CXX)

add_library(MyLib)

include(CMake-config)
```

No include paths, no install rules, and no export logic are required in the project file.

---

## Source Handling

### Explicit by Default

Sources should normally be declared explicitly:

```cmake
target_sources(MyLib
    PRIVATE
        src/foo.cpp
        src/bar.cpp
)
```

### Optional Auto-Discovery

Automatic source discovery can be enabled explicitly:

```cmake
set(AUTO_SOURCES ON)
include(CMake-config)
```

This will collect:

* `src/*.c*`
* `src/<platform>/*.c*`

This behavior is **opt-in** and never implicit.

---

## Public Headers

* All headers under `include/` are public
* Installed to `${CMAKE_INSTALL_PREFIX}/include`
* Exposed via `target_include_directories`
* Consumers never need to add include paths manually

---

## Tests

### Zero-Boilerplate Test Model

* One test executable per target
* Tests live in:

```text
test/<target-name>/src
```

Example:

```text
test/MyLib/src/mylib_test.cpp
```

### Behavior

* If the directory exists, tests are built
* If it does not exist, nothing happens
* No test `CMakeLists.txt`
* No manual source lists

### Result

* Executable: `MyLibTest`
* Automatically registered with CTest
* Run with:

```bash
ctest
```

---

## Dependency Management

Dependencies are declared normally on targets:

```cmake
find_package(Foo REQUIRED)

target_link_libraries(MyLib
    PUBLIC Foo::Foo
)
```

When installed, dependencies are propagated via:

* `INTERFACE_LINK_LIBRARIES`
* `find_dependency()` in `<Project>Config.cmake`

Consumers only need:

```cmake
find_package(MyLib REQUIRED)
target_link_libraries(App PRIVATE MyLib::MyLib)
```

---

## Installation and Export

The following are handled automatically:

* `install(TARGETS …)`
* `install(EXPORT …)`
* `<Project>Config.cmake`
* `<Project>ConfigVersion.cmake`

Targets are exposed as:

```cmake
<Project>::<Target>
```

Example:

```cmake
MyLib::MyLib
```

---

## Packaging (CPack)

Component-based packaging is supported.

### Components

* `runtime` — executables
* `libraries` — compiled libraries
* `development` — headers
* `documentation` — optional documentation

Components are aligned with `install(... COMPONENT ...)` rules.

---

## GraphViz Support

Target dependency graphs can be generated via:

```bash
cmake --graphviz=graph.dot
```

Defaults:

* External libraries hidden
* Test targets excluded

---

## What This Project Is Not

* No macros or custom DSLs
* No global variables as API
* No implicit or heuristic-heavy behavior
* No framework or CI assumptions

---

## Design Summary

**Low effort for users, high predictability for the system.**
Everything is explicit where it matters and automatic only where it is safe.

---

## Status

All scripts are considered **finalized** and internally consistent.

---

