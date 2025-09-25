#! /usr/bin/env bash

# NOTE: On MacOS, the installed version of bash will not work, because
#       it's out of date. The version on homebrew *will* work, which is
#       why the shebang calls env instead of directly invoking bash.

# SQL Injection
#===============

# Task 1
function test_task_1 {
    if [ ! -f task1.txt ]
    then
		echo "[Error] No task1.txt found (-15)"
        return
    fi

    local login=""
    local passwd=""
    local line_no=0
    while read line
    do
        if [ -z "${line}" ]
        then
            continue
        fi
        line_no=$(( ${line_no} + 1 ))
        if [ 1 -eq ${line_no} ]
        then
            login=$(echo ${line} | sed -E -n 's/login[[:space:]]*=[[:space:]]*"(.+)"/\1/p')
        elif [ 2 -eq ${line_no} ]
        then
            password=$(echo ${line} | sed -E -n 's/password[[:space:]]*=[[:space:]]*"(.+)"/\1/p')
        else
            break
        fi
    done < task1.txt
    echo "Login is [${login}]"
    echo "Password is [${password}]"
	echo ""
    if ( echo "${login}${password}" | grep '[^a-zA-Z0-9]' > /dev/null )
    then
		if ( echo "${login}${password}" | grep '#' > /dev/null )
		then
			echo "[Error] '#' is not a permitted form of comment (-5)"
		fi
    else
		echo "[Error] Task 1: No SQL injection present (-15)"
    fi

}

test_task_1
echo "========================================================"
echo "Note: This script *only* verifies the file exists checks formatting;"
echo "it does not test the script for correctness."
echo "See the README for instructions on the steps to test it."
echo "========================================================"
