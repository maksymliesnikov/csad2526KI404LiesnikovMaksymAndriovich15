@echo off
REM ci.cmd - Windows CMD CI helper
REM Steps:
REM  - create build directory
REM  - enter build
REM  - configure with CMake
REM  - build
REM  - run tests with CTest

REM Move to script directory
SET "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo == Creating build directory
if not exist build (
	mkdir build
)

cd build

echo == Configuring project with CMake
cmake ..

echo == Building project
cmake --build . --config Release

echo == Running tests (CTEST)
ctest --output-on-failure -C Release

if errorlevel 1 (
	echo Tests FAILED
	exit /b 1
)

echo == ci.cmd finished
exit /b 0

