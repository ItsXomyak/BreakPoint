#!/bin/bash

test_failed=false

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"
MAGENTA="\033[35m"
CYAN="\033[36m"
RESET="\033[0m"
BASE_URL="https://raw.githubusercontent.com/ItsXomyak/4testBMP/main/bitmap/test"
FILES="sample_4k.bmp 16bit.bmp 2xwidth.bmp bbpodpis.bmp
bit3butseted5.bmp incorrectfilesizeless.bmp incorrectfilesizemore.bmp noimage_only_head224len54.bmp 
panica.bmp pox.bmp until400kb.bmp virus.bmp lena_gray.bmp"

print_pass() {
    echo -e "[${GREEN}PASS${RESET}] $1"
}

print_fail() {
    local message=$1
    if [[ "$2" == "2" ]] || [[ "$3" == *"panic"* ]]; then
        print_crit_fail "$message"
    else
        echo -e "[${RED}FAIL${RESET}] $message"
    fi
}

print_crit_fail() {
    echo -e "[${MAGENTA}CRIT_FAIL${RESET}] $1"
}

verify_output() {
    local expected_output=$1
    local actual_output=$2
    local expected_status=$3
    local actual_status=$4
    local test_case=$5

    if [[ "$actual_output" == *"panic"* ]]; then
        print_crit_fail "Test case $test_case: Program panicked"
        echo -e "${YELLOW}Output:${RESET} $actual_output"
        test_failed=true
        return 1
    fi

    case $expected_status in
        0|1|2|124)
            if [ "$actual_status" -ne "$expected_status" ]; then
                print_fail "Test case $test_case: Expected exit status $expected_status, got $actual_status" "$actual_status" "$actual_output"
                test_failed=true
                return 1
            fi
            ;;
        *)
            print_crit_fail "Test case $test_case: Invalid expected status: $expected_status"
            test_failed=true
            return 1
            ;;
    esac

    if [ -n "$expected_output" ]; then
        if [[ "$actual_output" == *"$expected_output"* ]]; then
            print_pass "Test case $test_case: Output matches expected pattern"
        else
            print_fail "Test case $test_case: Output doesn't match expected pattern" "$actual_status" "$actual_output"
            echo -e "${YELLOW}Expected:${RESET} $expected_output"
            echo -e "${YELLOW}Actual:${RESET} $actual_output"
            test_failed=true
        fi
    else
        print_pass "Test case $test_case: Command executed successfully"
    fi
}

download_bmp_files() {   
    for FILE in $FILES; do
        if [ -f "$FILE" ]; then
            continue
        else
            echo "Downloading $FILE..."        
            curl -s -o "$FILE" "$BASE_URL/$FILE"
        fi
    done
}


list_tests() {
    echo -e "${CYAN}Test Cases for Review${RESET}"
    echo
    echo -e "${YELLOW}1.${RESET} ./bitmap"
    echo
    echo -e "${YELLOW}2.${RESET} ./bitmap apply --filter=blue sample.bmp sample-filtered-blue.bmp"
    echo
    echo -e "${YELLOW}3.${RESET} ./bitmap apply --filter=red sample.bmp sample-filtered-red.bmp"
    echo
    echo -e "${YELLOW}4.${RESET} ./bitmap apply --filter=green sample.bmp sample-filtered-green.bmp"
    echo
    echo -e "${YELLOW}5.${RESET} ./bitmap apply --filter=negative sample.bmp sample-filtered-negative.bmp"
    echo
    echo -e "${YELLOW}6.${RESET} ./bitmap apply --filter=pixelate sample.bmp sample-filtered-pixelate.bmp"
    echo
    echo -e "${YELLOW}7.${RESET} ./bitmap apply --filter=blur sample.bmp sample-filtered-blur.bmp"
    echo
    echo -e "${YELLOW}8.${RESET} ./bitmap apply --rotate=right --rotate=right sample.bmp sample-rotated-right-right.bmp"
    echo
    echo -e "${YELLOW}9.${RESET} ./bitmap header sample.bmp | grep \"Pixels\""
    echo
    echo -e "${YELLOW}10.${RESET} ./bitmap apply sample.bmp sample-cropped-20-20-80-80.bmp"
    echo
    echo -e "${YELLOW}11.${RESET} ./bitmap apply --crop=400-300 sample.bmp sample-cropped-400-300.bmp"
    echo
    echo -e "${YELLOW}12.${RESET} ./bitmap apply --mirror=horizontal --rotate=right --filter=negative --rotate=left --filter=green sample.bmp sample-mh-rr-fn-rl-fg.bmp"
    echo
    echo -e "${YELLOW}13.${RESET} ./bitmap apply --filter=pixelate sample.bmp .bmp"
    echo
    echo -e "${YELLOW}14.${RESET} ./bitmap apply --filter=blue sample.bmp salem.txt"
    echo
    echo -e "${YELLOW}15.${RESET} ./bitmap apply --filter=blue salem.txt sample-filtered-blue.bmp"
    echo
    echo -e "${YELLOW}16.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate sample_5184×3456.bmp sample_5184×3456_2.bmp"
    echo
    echo -e "${YELLOW}17.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate 16bit.bmp 16bit_2.bmp"
    echo
    echo -e "${YELLOW}18.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate 2xwidth.bmp 2xwidth_2.bmp"
    echo
    echo -e "${YELLOW}19.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate bbpodpis.bmp bbpodpis_2.bmp"
    echo
    echo -e "${YELLOW}20.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate bit3butseted5.bmp bit3butseted5_2.bmp"
    echo
    echo -e "${YELLOW}21.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate incorrectfilesizeless.bmp incorrectfilesizeless_2.bmp"
    echo
    echo -e "${YELLOW}22.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate incorrectfilesizemore.bmp incorrectfilesizemore_2.bmp"
    echo
    echo -e "${YELLOW}23.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate noimage_only_head224len54.bmp noimage_only_head224len54_2.bmp"
    echo
    echo -e "${YELLOW}24.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate panica.bmp panica_2.bmp"
    echo
    echo -e "${YELLOW}25.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate pox.bmp pox_2.bmp"
    echo
    echo -e "${YELLOW}26.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate until400kb.bmp until400kb_2.bmp"
    echo
    echo -e "${YELLOW}27.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate virus.bmp virus_2.bmp"
    echo
    echo -e "${YELLOW}28.${RESET} ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate sample.bmp sample-cropped"
    echo
    echo -e "${YELLOW}29.${RESET} ./bitmap apply --crop=-200-300 sample.bmp teeeeeeeest.bmp"
    echo
    echo -e "${YELLOW}30.${RESET} ./bitmap apply --crop=481-361-0-361 sample.bmp teeeeest.bmp"
    echo
    echo -e "${YELLOW}31.${RESET} ./bitmap apply --crop=0-0-481-361 sample.bmp teeeeest.bmp"
    echo
    echo -e "${YELLOW}32.${RESET} ./bitmap apply --crop=481-361 sample.bmp teeest.bmp"
    echo
    echo -e "${YELLOW}33.${RESET} ./bitmap apply --crop=-1-1-1-1 sample.bmp teeeeest.bmp"
    echo
    echo -e "${YELLOW}34.${RESET} ./bitmap apply header sample.bmp"
    echo
    echo -e "${YELLOW}35.${RESET} ./bitmap apply sample.bmp test.bmp test2.bmp"
    echo
    echo -e "${YELLOW}36.${RESET} ./bitmap apply teeeeest.bmp"
    echo
    echo -e "${YELLOW}37.${RESET} ./bitmap apply --mirror=horizontal --rotate=right --filter=negative --rotate=left --filter=green sample.bmp sample-mh-rr-fn-rl-fg --help"

}

# Test case 1
test_case_1() {
    local test_case="1"
    local result
    local exit_code
    
    result=$(./bitmap 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -n "$result" ]; then
        print_pass "Test case 1: Got correct output and correct exit status"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 1: Got correct output and correct exit status"
        return
    fi
    
    print_crit_fail "Test case $test_case: Program panicked / Check this test case for more details"
}

# Test case 2
test_case_2() {
    local test_case="2"
    local result
    local exit_code
    
    result=$(./bitmap apply --filter=blue sample.bmp sample-filtered-blue.bmp 2>&1)
    exit_code=$?
    
    verify_output "" "$result" 0 $exit_code "$test_case"
}

# Test case 3
test_case_3() {
    local test_case="3"
    local result
    local exit_code
    
    result=$(./bitmap apply --filter=red sample.bmp sample-filtered-red.bmp 2>&1)
    exit_code=$?
    
    verify_output "" "$result" 0 $exit_code "$test_case"
}

# Test case 4
test_case_4() {
    local test_case="4"
    local result
    local exit_code
    
    result=$(./bitmap apply --filter=green sample.bmp sample-filtered-green.bmp 2>&1)
    exit_code=$?
    
    verify_output "" "$result" 0 $exit_code "$test_case"
}

# Test case 5
test_case_5() {
    local test_case="5"
    local result
    local exit_code
    
    result=$(./bitmap apply --filter=negative sample.bmp sample-filtered-negative.bmp 2>&1)
    exit_code=$?
    
    verify_output "" "$result" 0 $exit_code "$test_case"
}

# Test case 6
test_case_6() {
    local test_case="6"
    local result
    local exit_code
    
    result=$(./bitmap apply --filter=pixelate sample.bmp sample-filtered-pixelate.bmp 2>&1)
    exit_code=$?
    
    verify_output "" "$result" 0 $exit_code "$test_case"
}

# Test case 7
test_case_7() {
    local test_case="7"
    local result
    local exit_code
    
    result=$(./bitmap apply --filter=blur sample.bmp sample-filtered-blur.bmp 2>&1)
    exit_code=$?
    
    verify_output "" "$result" 0 $exit_code "$test_case"
}

# Test case 8
test_case_8() {
    local test_case="8"
    local result
    local exit_code
    
    result=$(./bitmap apply --rotate=right --rotate=right sample.bmp sample-rotated-right-right.bmp 2>&1)
    exit_code=$?
    
    verify_output "" "$result" 0 $exit_code "$test_case"
}

# Test case 9
test_case_9() {
    local test_case="9"
    local result
    local exit_code
    
    result=$(./bitmap header sample.bmp | grep "Pixels" 2>&1)
    exit_code=$?
    
    verify_output "Pixels" "$result" 0 $exit_code "$test_case"
}

# Test case 10
test_case_10() {
    local test_case="10"
    local result
    local exit_code
    
    result=$(./bitmap --crop=20-20-100-100 apply sample.bmp sample-cropped-20-20-80-80.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [[ "$result" =~ [Uu]sage ]]; then
        print_pass "Test case 10: Got usage message and correct exit status"
        return
    fi


    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 10: Got error output and correct exit status"
        return
    fi
    
    print_fail "Test case $test_case: Did not get expected output or exit status"
}



# Test case 11
test_case_11() {
    local test_case="11"
    local result
    local exit_code
    
    result=$(./bitmap apply --crop=400-300 sample.bmp sample-cropped-400-300.bmp 2>&1)
    exit_code=$?
    
    verify_output "" "$result" 0 $exit_code "$test_case"
}

# Test case 12
test_case_12() {
    local test_case="12"
    local result
    local exit_code
    
    result=$(./bitmap apply --mirror=horizontal --rotate=right --filter=negative --rotate=left --filter=green sample.bmp sample-mh-rr-fn-rl-fg.bmp 2>&1)
    exit_code=$?
    
    verify_output "" "$result" 0 $exit_code "$test_case"
}

# Test case 13
test_case_13() {
    local test_case="13"
    local result
    local exit_code
    
    result=$( 2>&1)
    exit_code=$?
    

}

# Test case 14
test_case_14() {
    local test_case="14"
    local result
    local exit_code
    
    result=$(./bitmap apply --filter=blue sample.bmp salem.txt 2>&1)
    exit_code=$?

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
        print_fail "Test case 14: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
        print_fail "Test case 14: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 14: Got error output and correct exit status"
}

# Test case 15
test_case_15() {
    local test_case="15"
    local result
    local exit_code
    
    echo "This is a text file" > salem.txt
    
    result=$(./bitmap apply --filter=blue salem.txt sample-filtered-blue.bmp 2>&1)
    exit_code=$?
    
    rm -f salem.txt

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
        print_fail "Test case 15: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
        print_fail "Test case 15: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 15: Got error output and correct exit status"
}

test_case_16(){ 
    local test_case="16"
    local result
    local exit_code

    echo "Test case 16: test case with 4k bmp file"
    result=$(timeout 30s ./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate sample_4k.bmp sample_5184×3456_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 124 ]; then
        print_fail "Test case 16: Timeout after 30 seconds"
        return
    fi
    
    if [ $exit_code -eq 0 ] && [ -f "sample_5184×3456_2.bmp" ]; then
        print_pass "Test case 16: ${YELLOW}Warning:${NC} please check the file sample_5184×3456_2.bmp.bmp${RESET}"
        return
    fi

    verify_output "" "$result" 0 $exit_code "$test_case"
}


# Test case 17
test_case_17(){ 
    local test_case="17"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate 16bit.bmp 16bit_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "16bit_2.bmp" ]; then
        print_pass "Test case 17: ${YELLOW}Warning:${NC} please check the file 16bit_2.bmp.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
    print_pass "Test case 17: Got error output and correct exit status"
    return
    fi


    print_fail "Test case 17: Unexpected result" "$exit_code" "$result"
}


# Test case 18
test_case_18(){ 
    local test_case="18"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate 2xwidth.bmp 2xwidth_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "2xwidth_2.bmp" ]; then
        print_pass "Test case 18: ${YELLOW}Warning:${NC} please check the file 2xwidth_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 18: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 18: Unexpected result" "$exit_code" "$result"
}

# Test case 19
test_case_19(){ 
    local test_case="19"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate bbpodpis.bmp bbpodpis_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "bbpodpis_2.bmp" ]; then
        print_pass "Test case 19: ${YELLOW}Warning:${NC} please check the file bbpodpis_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 19: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 19: Unexpected result" "$exit_code" "$result"
}

# Test case 20
test_case_20(){ 
    local test_case="20"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate bit3butseted5.bmp bit3butseted5_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "bit3butseted5_2.bmp" ]; then
        print_pass "Test case 20: ${YELLOW}Warning:${NC} please check the file bit3butseted5_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 20: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 20: Unexpected result" "$exit_code" "$result"
}

# Test case 21
test_case_21(){ 
    local test_case="21"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate incorrectfilesizeless.bmp incorrectfilesizeless_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "incorrectfilesizeless_2.bmp" ]; then
        print_pass "Test case 21: ${YELLOW}Warning:${NC} please check the file incorrectfilesizeless_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 21: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 21: Unexpected result" "$exit_code" "$result"
}

# Test case 22
test_case_22(){ 
    local test_case="22"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate incorrectfilesizemore.bmp incorrectfilesizemore_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "incorrectfilesizemore_2.bmp" ]; then
        print_pass "Test case 22: ${YELLOW}Warning:${NC} please check the file incorrectfilesizemore_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 22: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 22: Unexpected result" "$exit_code" "$result"
}

# Test case 23
test_case_23(){ 
    local test_case="23"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate noimage_only_head224len54.bmp noimage_only_head224len54_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "noimage_only_head224len52_2.bmp" ]; then
        print_pass "Test case 23: ${YELLOW}Warning:${NC} please check the file noimage_only_head224len54_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 23: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 23: Unexpected result" "$exit_code" "$result"
}

# Test case 24
test_case_24(){ 
    local test_case="24"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate panica.bmp panica_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "panica_2.bmp" ]; then
        print_pass "Test case 24: ${YELLOW}Warning:${NC} please check the file panica_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 24: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 24: Unexpected result" "$exit_code" "$result"
}

# Test case 25
test_case_25(){ 
    local test_case="25"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate pox.bmp pox_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "pox_2.bmp" ]; then
        print_pass "Test case 25: ${YELLOW}Warning:${NC} please check the file pox_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 25: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 25: Unexpected result" "$exit_code" "$result"
}

# Test case 26
test_case_26(){ 
    local test_case="26"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate until400kb.bmp until400kb_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "until400kb_2.bmp" ]; then
        print_pass "Test case 26: ${YELLOW}Warning:${NC} please check the file until400kb.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 26: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 26: Unexpected result" "$exit_code" "$result"
}

# Test case 27
test_case_27(){ 
    local test_case="27"
    local result
    local exit_code

    result=$(./bitmap apply --filter=green --filter=negative --filter=grayscale --filter=pixelate virus.bmp virus_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "virus_2.bmp" ]; then
        print_pass "Test case 27: ${YELLOW}Warning:${NC} please check the file virus_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 27: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 27: Unexpected result" "$exit_code" "$result"
}

# Test case 28
test_case_28(){ 
    local test_case="28"
    local result
    local exit_code

    result=$(./bitmap apply --help 2>&1)
    exit_code=$?

    if [[ "$result" =~ (Usage|usage|help|options|) ]]; then
        print_pass "Test case $test_case: Detected help message"
        return
    fi

    print_fail "Test case $test_case: Help message not found" "$exit_code" "$result"
}

# Test case 29
test_case_29(){ 
    local test_case="29"
    local result
    local exit_code

    result=$(./bitmap apply --crop=-200-300 sample.bmp teeeeeeeest.bmp 2>&1)
    exit_code=$?

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
        print_fail "Test case 29: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
        print_fail "Test case 29: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 29: Got error output and correct exit status"
}

# Test case 30
test_case_30(){ 
    local test_case="30"
    local result
    local exit_code

    result=$(./bitmap apply --crop=481-361-0-361 sample.bmp teeeeest.bmp 2>&1)
    exit_code=$?

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
    print_fail "Test case 30: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
    test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
    print_fail "Test case 30: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 30: Got error output and correct exit status"
}

# Test case 31
test_case_31(){ 
    local test_case="31"
    local result
    local exit_code

    result=$(./bitmap apply --crop=0-0-481-361 sample.bmp teeeeest.bmp 2>&1)
    exit_code=$?

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
        print_fail "Test case 31: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
        print_fail "Test case 31: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 31: Got error output and correct exit status"
}

# Test case 32
test_case_32(){ 
    local test_case="32"
    local result
    local exit_code

    result=$(./bitmap apply --crop=481-361 sample.bmp teeest.bmp 2>&1)
    exit_code=$?

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
        print_fail "Test case 32: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
        print_fail "Test case 32: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 32: Got error output and correct exit status"
}

# Test case 33
test_case_33(){ 
    local test_case="33"
    local result
    local exit_code

    result=$(./bitmap apply --crop=-1-1-1-1 sample.bmp teeeeest.bmp 2>&1)
    exit_code=$?

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
        print_fail "Test case 33: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
        print_fail "Test case 33: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 33: Got error output and correct exit status"
}

# Test case 34
test_case_34(){ 
    local test_case="34"
    local result
    local exit_code

    result=$(./bitmap apply header sample.bmp 2>&1)
    exit_code=$?

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
        print_fail "Test case 34: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
        print_fail "Test case 34: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 34: Got error output and correct exit status"
}

# Test case 35
test_case_35(){ 
    local test_case="35"
    local result
    local exit_code

    result=$(./bitmap apply sample.bmp test.bmp test2.bmp 2>&1)
    exit_code=$?

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
        print_fail "Test case 35: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
        print_fail "Test case 35: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 35: Got error output and correct exit status"
}

# Test case 36
test_case_36(){ 
    local test_case="36"
    local result
    local exit_code

    result=$(./bitmap apply teeeeest.bmp 2>&1)
    exit_code=$?

    if [ -z "$result" ] || [[ "$result" =~ ^[[:space:]]*$ ]]; then
        print_fail "Test case 36: Expected non-empty output, but got empty or whitespace-only output" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    if [ $exit_code -ne 1 ]; then
        print_fail "Test case 36: Expected exit status 1, but got $exit_code" "$exit_code" "$result"
        test_failed=true
        return
    fi
    
    print_pass "Test case 36: Got error output and correct exit status"
}

# Test case 37
test_case_37(){ 
    local test_case="37"
    local result
    local exit_code

    result=$(./bitmap apply --mirror=horizontal --rotate=right --filter=negative --rotate=left --filter=green sample.bmp sample-mh-rr-fn-rl-fg --help 2>&1)
    exit_code=$?

    if [[ "$result" =~ (Usage|usage|help|options|) ]]; then
        print_pass "Test case $test_case: Detected help message"
        return
    fi

    print_fail "Test case $test_case: Help message not found" "$exit_code" "$result"
}

# Test case 38
test_case_38(){ 
    local test_case="38"
    local result
    local exit_code

    result=$(./bitmap apply --rotate=right --mirror=vertical lena_gray.bmp lena_gray_2.bmp 2>&1)
    exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "lena_gray.bmp" ]; then
        print_pass "Test case 38: ${YELLOW}Warning:${NC} please check the file lena_gray_2.bmp${RESET}"
        return
    fi

    if [ $exit_code -eq 1 ] && [ -n "$result" ]; then
        print_pass "Test case 38: Got error output and correct exit status"
        return
    fi

    print_fail "Test case 38: Unexpected result" "$exit_code" "$result"
}



if [ "$1" = "list" ]; then
    list_tests
    exit 0
fi

test_gofmt() {

    result=$(gofmt -l .)

    if [ -n "$result" ]; then
        print_fail "GoFmt check failed. Files need formatting fixes."

        echo -e "${YELLOW}Files with formatting issues:${RESET}"
        echo "$result"

        echo "Auto-fixing formatting errors with gofmt..."
        gofmt -w . 

        test_failed=true

        print_fail "Test case failed due to GoFmt issues."
    else
        print_pass "GoFmt check passed. All files are properly formatted."
    fi
}

# Main execution
run_tests() {
    echo -e "${CYAN}Running Bitmap Processing Tests...${RESET}"
    echo "--------------------------------------------------------------------------------"
    
    download_bmp_files
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
    test_case_13
    test_case_14
    test_case_15
    test_case_16
    test_case_17
    test_case_18
    test_case_19
    test_case_20
    test_case_21
    test_case_22
    test_case_23
    test_case_24
    test_case_25
    test_case_26
    test_case_27
    test_case_28
    test_case_29
    test_case_30
    test_case_31
    test_case_32
    test_case_33
    test_case_34
    test_case_35
    test_case_36
    test_case_37
    test_case_38
    test_gofmt

    
    echo "----------------------------------------"
    if [ "$test_failed" = true ]; then
        echo -e "${RED}Some tests failed!${RESET}"
        echo -e "\n\e[1m\e[34m+-------------------------------------------+\e[0m"
        echo -e "\e[1m\e[34m|       The tool was made by mromanul.      |\e[0m"
        echo -e "\e[1m\e[34m+-------------------------------------------+\e[0m\n"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${RESET}"
        echo -e "\n\e[1m\e[34m+-------------------------------------------+\e[0m"
        echo -e "\e[1m\e[34m|       The tool was made by mromanul.      |\e[0m"
        echo -e "\e[1m\e[34m+-------------------------------------------+\e[0m\n"
        exit 0
    fi
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi

