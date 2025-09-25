#! /usr/bin/env bash

# Cross-site Scripting
#======================

# Task 3
function test_task_3 {
    if [ ! -f task3.txt ]
    then
		echo "[Error] No task3.txt found (-10)"
        return
    fi

	echo "Verified task3.txt exists."
	echo ""
	echo "All of the following text (between the '---' lines) would be"
	echo "entered in to Alice's \"brief description\" field:"
	echo "------"
	cat task3.txt
	echo "------"
}

test_task_3
echo ""
echo "========================================================"
echo "Note: This script *only* verifies the file exists and shows its contents;"
echo "it does not test the script for correctness."
echo "See the README for instructions on the steps to test it."
echo "========================================================"
