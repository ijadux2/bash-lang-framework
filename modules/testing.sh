#!/usr/bin/bash

# Testing Framework - Unit testing for bash applications
module_version "testing" "1.0.0"

# Test state
declare -g TEST_CURRENT_SUITE=""
declare -g TEST_CURRENT_TEST=""
declare -g TEST_TOTAL=0
declare -g TEST_PASSED=0
declare -g TEST_FAILED=0
declare -g TEST_ERRORS=0
declare -g TEST_RESULTS=()

# Initialize TEST_COLORS if not already defined
if [[ ${#TEST_COLORS[@]} -eq 0 ]]; then
    declare -A TEST_COLORS=(
        ["pass"]="\033[32m"      # Green
        ["fail"]="\033[31m"      # Red
        ["error"]="\033[35m"     # Magenta
        ["info"]="\033[36m"      # Cyan
        ["reset"]="\033[0m"      # Reset
    )
fi

# Test suite
describe() {
    TEST_CURRENT_SUITE="$1"
    echo
    printc "cyan" "bold" "Test Suite: $TEST_CURRENT_SUITE"
    echo "$(repeat 50 "=")"
}

# Test case
it() {
    TEST_CURRENT_TEST="$1"
    ((TEST_TOTAL++))
    echo -n "  • $TEST_CURRENT_TEST ... "
}

# Assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$expected', got '$actual'}"
    
    if [[ "$expected" == "$actual" ]]; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_not_equals() {
    local not_expected="$1"
    local actual="$2"
    local message="${3:-Should not equal '$not_expected'}"
    
    if [[ "$not_expected" != "$actual" ]]; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local message="${2:-Expected true, got false}"
    
    if eval "$condition"; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-Expected false, got true}"
    
    if ! eval "$condition"; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected '$haystack' to contain '$needle'}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected '$haystack' not to contain '$needle'}"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_match() {
    local string="$1"
    local pattern="$2"
    local message="${3:-Expected '$string' to match '$pattern'}"
    
    if [[ "$string" =~ $pattern ]]; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File '$file' should exist}"
    
    if [[ -f "$file" ]]; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_file_not_exists() {
    local file="$1"
    local message="${2:-File '$file' should not exist}"
    
    if [[ ! -f "$file" ]]; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_command_success() {
    local command="$1"
    local message="${2:-Command should succeed: $command}"
    
    if eval "$command" >/dev/null 2>&1; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_command_failure() {
    local command="$1"
    local message="${2:-Command should fail: $command}"
    
    if ! eval "$command" >/dev/null 2>&1; then
        test_pass
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

# Test result handlers
test_pass() {
    echo -e "${TEST_COLORS[pass]}PASS${TEST_COLORS[reset]}"
    ((TEST_PASSED++))
    TEST_RESULTS+=("$TEST_CURRENT_SUITE:$TEST_CURRENT_TEST:PASS")
}

test_fail() {
    local message="$1"
    echo -e "${TEST_COLORS[fail]}FAIL${TEST_COLORS[reset]}"
    echo "    $message"
    ((TEST_FAILED++))
    TEST_RESULTS+=("$TEST_CURRENT_SUITE:$TEST_CURRENT_TEST:FAIL:$message")
}

test_error() {
    local message="$1"
    echo -e "${TEST_COLORS[error]}ERROR${TEST_COLORS[reset]}"
    echo "    $message"
    ((TEST_ERRORS++))
    TEST_RESULTS+=("$TEST_CURRENT_SUITE:$TEST_CURRENT_TEST:ERROR:$message")
}

# Before/after hooks
before_each() {
    local setup_function="$1"
    if declare -f "$setup_function" > /dev/null; then
        "$setup_function"
    fi
}

after_each() {
    local cleanup_function="$1"
    if declare -f "$cleanup_function" > /dev/null; then
        "$cleanup_function"
    fi
}

# Mock functions
mock() {
    local function_name="$1"
    local return_value="${2:-0}"
    local output="${3:-}"
    
    # Save original function
    if declare -f "$function_name" > /dev/null; then
        eval "ORIGINAL_$function_name() { $(declare -f "$function_name" | tail -n +2); }"
    fi
    
    # Create mock
    eval "$function_name() { echo '$output'; return $return_value; }"
}

unmock() {
    local function_name="$1"
    
    # Restore original function if exists
    if declare -f "ORIGINAL_$function_name" > /dev/null; then
        eval "$function_name() { $(declare -f "ORIGINAL_$function_name" | tail -n +2); }"
        unset -f "ORIGINAL_$function_name"
    else
        unset -f "$function_name"
    fi
}

# Test runner
run_test_file() {
    local test_file="$1"
    
    if [[ ! -f "$test_file" ]]; then
        echo "Test file not found: $test_file"
        return 1
    fi
    
    echo "Running tests from: $test_file"
    echo "$(repeat 60 "-")"
    
    # Reset counters
    TEST_TOTAL=0
    TEST_PASSED=0
    TEST_FAILED=0
    TEST_ERRORS=0
    TEST_RESULTS=()
    
    # Source test file in subshell
    (
        source "$test_file"
        
        # Print summary
        echo
        printc "cyan" "bold" "Test Summary:"
        echo "  Total: $TEST_TOTAL"
        echo -e "  Passed: ${TEST_COLORS[pass]}$TEST_PASSED${TEST_COLORS[reset]}"
        echo -e "  Failed: ${TEST_COLORS[fail]}$TEST_FAILED${TEST_COLORS[reset]}"
        echo -e "  Errors: ${TEST_COLORS[error]}$TEST_ERRORS${TEST_COLORS[reset]}"
        
        # Return appropriate exit code
        if [[ $TEST_FAILED -gt 0 ]] || [[ $TEST_ERRORS -gt 0 ]]; then
            exit 1
        else
            exit 0
        fi
    )
}

# Run all test files
run_all_tests() {
    local test_dir="${1:-tests}"
    
    if [[ ! -d "$test_dir" ]]; then
        echo "Test directory not found: $test_dir"
        return 1
    fi
    
    local total_passed=0
    local total_failed=0
    local total_errors=0
    local total_files=0
    
    echo "Running all tests in: $test_dir"
    echo "$(repeat 80 "=")"
    
    for test_file in "$test_dir"/test_*.sh; do
        if [[ -f "$test_file" ]]; then
            ((total_files++))
            echo
            
            if run_test_file "$test_file"; then
                ((total_passed++))
            else
                ((total_failed++))
            fi
        fi
    done
    
    echo
    echo "$(repeat 80 "=")"
    printc "cyan" "bold" "Overall Summary:"
    echo "  Test files: $total_files"
    echo "  Passed: $total_passed"
    echo "  Failed: $total_failed"
    
    if [[ $total_failed -eq 0 ]]; then
        echo -e "${TEST_COLORS[pass]}All tests passed!${TEST_COLORS[reset]}"
        return 0
    else
        echo -e "${TEST_COLORS[fail]}Some tests failed!${TEST_COLORS[reset]}"
        return 1
    fi
}

# Generate test report
generate_report() {
    local output_file="${1:-test_report.txt}"
    
    {
        echo "Test Report - $(date)"
        echo "$(repeat 50 "=")"
        echo
        
        echo "Test Summary:"
        echo "  Total Tests: $TEST_TOTAL"
        echo "  Passed: $TEST_PASSED"
        echo "  Failed: $TEST_FAILED"
        echo "  Errors: $TEST_ERRORS"
        echo
        
        if [[ ${#TEST_RESULTS[@]} -gt 0 ]]; then
            echo "Detailed Results:"
            echo "$(repeat 50 "-")"
            
            for result in "${TEST_RESULTS[@]}"; do
                IFS=':' read -r suite test status message <<< "$result"
                echo "$suite :: $test :: $status"
                if [[ -n "$message" ]]; then
                    echo "  └─ $message"
                fi
            done
        fi
        
    } > "$output_file"
    
    echo "Test report generated: $output_file"
}

# Helper function for colored output
printc() {
    local color="$1"
    local style="$2"
    local text="$3"
    
    echo -e "${TEST_COLORS[$color]}$text${TEST_COLORS[reset]}"
}

# Export functions
export_module "testing" describe it assert_equals assert_not_equals assert_true assert_false assert_contains assert_not_contains assert_match assert_file_exists assert_file_not_exists assert_command_success assert_command_failure before_each after_each mock unmock run_test_file run_all_tests generate_report