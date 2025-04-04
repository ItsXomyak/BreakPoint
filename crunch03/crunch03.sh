#!/bin/bash

test_failed=false

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
RESET="\033[0m"

print_pass() {
    echo -e "[${GREEN}PASS${RESET}] $1"
    [ -n "$2" ] && echo -e "${YELLOW}Output:${RESET} $2"
}

print_fail() {
    echo -e "[${RED}FAIL${RESET}] $1"
    [ -n "$2" ] && echo -e "${YELLOW}Output:${RESET} $2"
}

print_crit_fail() {
    echo -e "[${MAGENTA}CRIT_FAIL${RESET}] $1"
    [ -n "$2" ] && echo -e "${YELLOW}Output:${RESET} $2"
}

check_result() {
    local test_case="$1"
    local result="$2"
    local exit_code="$3"
    local timeout_sec="$4"
    local show_output="${5:-false}" 

    # Успех: статус 0 или 1 с непустым выводом
    if { [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 1 ]; } && [ -n "$result" ]; then
        if [ "$show_output" = true ]; then
            print_pass "Test case $test_case: Program completed with status $exit_code and non-empty output" "$result"
        else
            print_pass "Test case $test_case: Program completed with status $exit_code and non-empty output"
        fi
        return 0
    fi

    # Паника: статус 2
    if [ "$exit_code" -eq 2 ]; then
        print_crit_fail "Test case $test_case: Program panicked unexpectedly" "$result"
        test_failed=true
        return 1
    fi

    # Таймаут: статус 124
    if [ "$exit_code" -eq 124 ]; then
        print_fail "Test case $test_case: Program ran for too long (over ${timeout_sec}s)" "$result"
        test_failed=true
        return 1
    fi

    print_crit_fail "Test case $test_case: Unexpected exit status $exit_code or empty output" "$result"
    test_failed=true
    return 1
}

# Test case 1
test_case_1() {
    local test_case="1"
    local result
    local exit_code

    touch 123.txt

    echo -e "1\n" | timeout 0.1s go run main.go --random=5x5 --file=123.txt > output.txt 2>&1
    exit_code=$?
    result=$(cat output.txt)
    
    if { [ $exit_code -eq 0 ] || [ $exit_code -eq 1 ]; } && [ -n "$result" ]; then
        print_pass "Test case $test_case: Program completed quickly with status $exit_code and non-empty output"
        return
    fi
    
    # Проверяем длительную работу 
    echo -e "1\n" | timeout 2s go run main.go --random=5x5 --file=123.txt > output.txt 2>&1
    exit_code=$?
    result=$(cat output.txt)
    
    # Если статус 2 
    if [ $exit_code -eq 2 ]; then
        print_crit_fail "Test case $test_case: Program panicked unexpectedly"
        test_failed=true
        return
    fi
    
    # Если статус 0 (работает слишком долго)
    if [ $exit_code -eq 0 ]; then
        print_fail "Test case $test_case: Program ran for too long (up to 2s) with status 0, expected quick exit"
        test_failed=true
        return
    fi
    
    # Если статус 1 с непустым выводом  — успех
    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case $test_case: Program completed with status 1 and non-empty output"
        return
    fi
    
    # Если timeout сработал 
    if [ $exit_code -eq 124 ]; then
        print_fail "Test case $test_case: Program did not complete quickly enough (timeout triggered)"
        test_failed=true
        return
    fi
    
    print_crit_fail "Test case $test_case: Unexpected exit status $exit_code or empty output"
    test_failed=true
}

# Test case 2
test_case_2() {
    local test_case="2"
    echo -e "1\n" | timeout 2s go run main.go --file=123.txt > output.txt 2>&1
    check_result "$test_case" "$(cat output.txt)" "$?" "2"
}

# Test case 3
test_case_3() {
    local test_case="3"
    echo -e "1\n" | timeout 2s go run main.go --random=2x2 > output.txt 2>&1
    check_result "$test_case" "$(cat output.txt)" "$?" "2" "true"
}

# Test case 4
test_case_4() {
    local test_case="4"
    echo -e "1\n" | timeout 2s go run main.go --delay-ms=-100 > output.txt 2>&1
    local exit_code=$?
    local result=$(cat output.txt)
    
    if [ "$exit_code" -eq 2 ]; then
        print_crit_fail "Test case $test_case: Program panicked unexpectedly" "$result"
        test_failed=true
    fi
}

# Test case 5
test_case_5() {
    local test_case="5"
    echo -e "1\n" | timeout 2s go run main.go --colored --colored > output.txt 2>&1
    check_result "$test_case" "$(cat output.txt)" "$?" "2" "true"
}

# Test case 6
test_case_6() {
    local test_case="6"
    cat << EOF > lorem.txt
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
lorem ipsum dolor sit amet, consectetur adipiscing  elit
EOF
    echo -e "1\n" | timeout 2s go run main.go --file=lorem.txt > output.txt 2>&1
    check_result "$test_case" "$(cat output.txt)" "$?" "2"
}

# Test case 7
test_case_7() {
    local test_case="7"
    {
        echo "6 6"
        echo "......"
        echo "..##.."
        echo ".##..."
        echo "..##.."
        echo "..##.."
        echo "......"
    } | timeout 2s go run main.go --verbose > output.txt 2>&1
    check_result "$test_case" "$(cat output.txt)" "$?" "2"
}

# Test case 8
test_case_8() {
    local test_case="8"
    {
        echo "6 6"
        echo "......"
        echo "..##.."
        echo ".##..."
        echo "..##.."
        echo "..##.."
        echo "...."
    } | timeout 1s go run main.go --verbose > output.txt 2>&1
    check_result "$test_case" "$(cat output.txt)" "$?" "2"
}

test_case_9() {
    local test_case="9"
    local result
    local exit_code

    echo -e "..\n##" > some.txt

    echo -e "1\n" | timeout 2s go run main.go --delay-ms=10 --file=some.txt --verbose > output.txt 2>&1
    exit_code=$?
    result=$(cat output.txt)
    
    if { [ $exit_code -eq 0 ] || [ $exit_code -eq 1 ]; } && [ -n "$result" ]; then
        print_pass "Test case $test_case: Program completed quickly with status $exit_code and non-empty output"
        return
    fi
    
    # Проверяем длительную работу 
    echo -e "1\n" | timeout 2s go run main.go --random=5x5 --file=123.txt > output.txt 2>&1
    exit_code=$?
    result=$(cat output.txt)
    
    # Если статус 2 
    if [ $exit_code -eq 2 ]; then
        print_crit_fail "Test case $test_case: Program panicked unexpectedly"
        test_failed=true
        return
    fi
    
    # Если статус 0 (работает слишком долго)
    if [ $exit_code -eq 0 ]; then
        print_fail "Test case $test_case: Program ran for too long (up to 2s) with status 0, expected quick exit"
        test_failed=true
        return
    fi
    
    # Если статус 1 с непустым выводом  — успех
    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case $test_case: Program completed with status 1 and non-empty output"
        return
    fi
    
    # Если timeout сработал 
    if [ $exit_code -eq 124 ]; then
        print_fail "Test case $test_case: Program did not complete quickly enough (timeout triggered)"
        test_failed=true
        return
    fi
    
    print_crit_fail "Test case $test_case: Unexpected exit status $exit_code or empty output"
    test_failed=true
}

test_case_10() {
    local test_case="10"
    local exit_code

    # Create the problematic file
    echo -e "\n\n\n\n\n\n\n...\n\n\n\n.\n\n\n...\n###\n..#" > filename.txt

    # Run the program and capture its output
    echo -e "1\n" | go run main.go --delay-ms=10 --file=filename.txt --verbose > test_output_10.txt 2>&1
    exit_code=$?
    
    # Check if the output contains "panic:" which indicates a panic occurred
    if grep -q "panic:" test_output_10.txt; then
        print_crit_fail "Test case $test_case: Program panicked with invalid grid file (see test_output_10.txt for details)"
        test_failed=true
        return
    fi
    
    # If we get here, the program didn't panic as expected
    print_fail "Test case $test_case: Program did not panic with invalid grid file as expected (exit code: $exit_code)"
    test_failed=true
}

test_case_11() {
    local test_case="11"
    local result
    local exit_code

    echo -e "\0" > some2.txt

    echo -e "1\n" | timeout 0.1s go run main.go --delay-ms=10 --file=some2.txt --verbose > output.txt 2>&1
    exit_code=$?
    result=$(cat output.txt)
    
    if { [ $exit_code -eq 0 ] || [ $exit_code -eq 1 ]; } && [ -n "$result" ]; then
        print_pass "Test case $test_case: Program completed quickly with status $exit_code and non-empty output"
        return
    fi
    
    # Проверяем длительную работу 
    echo -e "1\n" | timeout 2s go run main.go --delay-ms=10 --file=some2.txt --verbose > output.txt 2>&1
    exit_code=$?
    result=$(cat output.txt)
    
    # Если статус 2 
    if [ $exit_code -eq 2 ]; then
        print_crit_fail "Test case $test_case: Program panicked unexpectedly"
        test_failed=true
        return
    fi
    
    # Если статус 0 (работает слишком долго)
    if [ $exit_code -eq 0 ]; then
        print_fail "Test case $test_case: Program ran for too long (up to 2s) with status 0, expected quick exit"
        test_failed=true
        return
    fi
    
    # Если статус 1 с непустым выводом  — успех
    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case $test_case: Program completed with status 1 and non-empty output"
        return
    fi
    
    # Если timeout сработал 
    if [ $exit_code -eq 124 ]; then
        print_fail "Test case $test_case: Program did not complete quickly enough (timeout triggered)"
        test_failed=true
        return
    fi
    
    print_crit_fail "Test case $test_case: Unexpected exit status $exit_code or empty output"
    test_failed=true
}

test_case_12() {
    local test_case="12"
    local result
    local exit_code

    echo -e "1\n" | timeout 0.1s go run main.go - > output.txt 2>&1
    exit_code=$?
    result=$(cat output.txt)
    
    if { [ $exit_code -eq 0 ] || [ $exit_code -eq 1 ]; } && [ -n "$result" ]; then
        print_pass "Test case $test_case: Program completed quickly with status $exit_code and non-empty output"
        return
    fi
    
    # Проверяем длительную работу 
    echo -e "1\n" | timeout 2s go run main.go - > output.txt 2>&1
    exit_code=$?
    result=$(cat output.txt)
    
    # Если статус 2 
    if [ $exit_code -eq 2 ]; then
        print_crit_fail "Test case $test_case: Program panicked unexpectedly"
        test_failed=true
        return
    fi
    
    # Если статус 0 (работает слишком долго)
    if [ $exit_code -eq 0 ]; then
        print_fail "Test case $test_case: Program ran for too long (up to 2s) with status 0, expected quick exit"
        test_failed=true
        return
    fi
    
    # Если статус 1 с непустым выводом  — успех
    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case $test_case: Program completed with status 1 and non-empty output"
        return
    fi
    
    # Если timeout сработал 
    if [ $exit_code -eq 124 ]; then
        print_fail "Test case $test_case: Program did not complete quickly enough (timeout triggered)"
        test_failed=true
        return
    fi
    
    print_crit_fail "Test case $test_case: Unexpected exit status $exit_code or empty output"
    test_failed=true
}

run_tests() {
    echo -e "${YELLOW}Running Game of Life Tests...${RESET}"
    echo "--------------------------------------------------------------------------------"
    
    test_case_1
    test_case_2
    test_case_3
    test_case_4
    test_case_5
    test_case_6
    test_case_7
    test_case_8
    test_case_9
    test_case_10
    test_case_11
    test_case_12

    
    
    echo "----------------------------------------"
    if [ "$test_failed" = true ]; then
        echo -e "${RED}Some tests failed!${RESET}"
        echo -e "\n\e[1m\e[34m+-------------------------------------------+\e[0m"
        echo -e "\e[1m\e[34m|       The tool was made by mromanul       |\e[0m"
        echo -e "\e[1m\e[34m+-------------------------------------------+\e[0m\n"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${RESET}"
        echo -e "\n\e[1m\e[34m+-------------------------------------------+\e[0m"
        echo -e "\e[1m\e[34m|       The tool was made by mromanul       |\e[0m"
        echo -e "\e[1m\e[34m+-------------------------------------------+\e[0m\n"
        exit 0
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi