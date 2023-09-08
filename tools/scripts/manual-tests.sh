#!/bin/bash
set -e # Bail on first error
source "$(dirname "$0")/_lib.sh"

function run_test () {
    test_name="$1"
    print_info "Execute Test: ${1}"
    read_enter
}

print_header "Login / Register Tests"

run_test "Check login page doesn't allow empty email and password"
run_test "Check login page doesn't allow non-existing email and password"
run_test "Login with valid user"
run_test "Check email is confirmed"
run_test "Check user data matches"
run_test "Logout user"
run_test "Check user is logged out"
run_test "Check register page doesn't allow empty email and password"
run_test "Check register page doesn't allow existing email and password"
run_test "Register user"
run_test "Check user data matches"
run_test "Check email is unconfirmed"
run_test "Logout user"
run_test "Login with another user"
run_test "Confirm email"
run_test "Confirm email twice shouldn't work"
run_test "Check user data still matches other user"
run_test "Logout user"
run_test "Login with new user"
run_test "Check email is confirmed"
run_test "Change password"
run_test "Logout user"
run_test "Check original password is wrong"
run_test "Login with new password"
run_test "Logout user"
run_test "Reset password"
run_test "Login with new password"

print_header "Manual Tests"

run_test "Check drag and drop works"