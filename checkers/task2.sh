#! /usr/bin/env bash

# NOTE: On MacOS, the installed version of bash will not work, because
#       it's out of date. The version on homebrew *will* work, which is
#       why the shebang calls env instead of directly invoking bash.

export PYTHONUNBUFFER=on
export QT_QPA_PLATFORM=offscreen

checkers_dir=$(pwd)/checkers
t2params=${checkers_dir}/check_task2_params.py

# SQL Injection
#===============

# Task 2
function test_task_2 {
    if [ ! -f task2.txt ]
    then
		echo "[Error] No task2.txt found (-30)"
        return
    fi

    local new_passwd=""
    local target_user=""
    local line_no=0
    set -f

    while read line
    do
        line_no=$(( ${line_no} + 1 ))

        if [ 3 -eq ${line_no} ]
        then
			echo "The provided parameters are between the "---" lines:"
			echo "------"
		fi

        if [ 1 -eq ${line_no} ]
        then
            new_passwd=${line//\"}
			echo "The provided new password is [${new_passwd}]"
        elif [ 2 -eq ${line_no} ]
        then
            target_user=$(echo ${line} | tr 'A-Z' 'a-z')
			echo "The provided target user is [${target_user}]"
        elif [ -n "${line}" ]
        then
			python3 ${t2params} "${line}"
        else
            break
        fi
    done < task2.txt
    set +f

	echo "------"
	echo ""


    # The original password for bob is "bob". Make sure it's being changed!
    if [ "${new_passwd}" = "bob" ]
    then
		echo "[Error] The new password is the same as the original. (-30)"
        return
    fi

    # Make sure the user and password don't contain injections.
    if ( echo "${target_user}${new_passwd}" | grep '[^a-zA-Z0-9_ @!" ]' )
    then
		echo "[Error] Injection should be in the profile parameters, not in the username/passwd (-30)"
        return
    fi

	if ( grep '#' task2.txt )
	then
		echo "[Warning] '#' is not a permitted form of comment (-10)"
	fi
}

test_task_2

echo "========================================================"
echo "Note: This script *only* verifies the file exists checks formatting;"
echo "it does not test the script for correctness."
echo "See the README for instructions on the steps to test it."
echo "========================================================"
