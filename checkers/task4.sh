#! /usr/bin/env bash

# NOTE: On MacOS, the installed version of bash will not work, because
#       it's out of date. The version on homebrew *will* work, which is
#       why the shebang calls env instead of directly invoking bash.


# Cross-site Scripting
#======================

# Task 4
function test_task_4 {
    if [ ! -f HTTPSimpleForge.java ]
    then
		echo "[Error] Task 4: No HTTPSimpleForge.java found (-25)"
        return
    fi

    javac --release=8 HTTPSimpleForge.java
    if [ 0 != $? ]
    then
		echo "[Error] Task 4: Could not build HTTPSimpleForge (-25)"
        return
    fi

	echo "Task 4: Verified HTTPSimpleForge.java exists and compiles."
	echo "See the README for instructions on the steps to test it."
}

test_task_4

echo "========================================================"
echo "Note: This script *only* verifies the file exists and compiles; it"
echo "does not test the script for correctness."
echo "See the README for instructions on the steps to test it."
echo "========================================================"
