#! /usr/bin/env bash

# NOTE: On MacOS, the installed version of bash will not work, because
#       it's out of date. The version on homebrew *will* work, which is
#       why the shebang calls env instead of directly invoking bash.


# Cross-site Request Forgery
#============================

# Task 5
function test_task_5 {
    debug "====== Task 5 ======"
    if [ ! -f task5.html ]
    then
        log_score "[Error] No file task5.html found" -20
        return
    fi

	echo "Verified that task5.html exists."
}

test_task_5

echo "========================================================"
echo "Note: This script *only* verifies the file exists; it"
echo "does not test the script for correctness."
echo "See the README for instructions on the steps to test it."
echo "========================================================"
