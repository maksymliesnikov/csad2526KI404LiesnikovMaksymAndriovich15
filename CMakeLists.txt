cmake_minimum_required(VERSION 3.10)

# Project name
project(HelloWorld)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add executable
add_executable(HelloWorld main.cpp)

# Set output directory
set_target_properties(HelloWorld PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Compiler-specific options
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    target_compile_options(HelloWorld PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Debug/Release configurations
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_definitions(HelloWorld PRIVATE DEBUG)
    target_compile_options(HelloWorld PRIVATE -g -O0)
else()
    target_compile_options(HelloWorld PRIVATE -O2)
endif()

# ---------------------------
# GoogleTest and unit tests
# ---------------------------
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/heads/main.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

# Create unit_tests executable
add_executable(unit_tests
    tests/unit_tests.cpp
    math_operations.cpp
)

target_include_directories(unit_tests PRIVATE ${CMAKE_SOURCE_DIR})
target_link_libraries(unit_tests PRIVATE gtest_main)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    target_compile_options(unit_tests PRIVATE -Wall -Wextra -Wpedantic)
endif()

add_test(NAME unit_tests COMMAND unit_tests)

set_target_properties(unit_tests PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)
