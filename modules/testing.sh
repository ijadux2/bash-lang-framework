#!/bin/bash

# Testing Module
# Provides comprehensive testing framework for Bash scripts

module_version testing 1.0.0

# Test framework globals
declare -a TEST_RESULTS=()
declare -a TEST_NAMES=()
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0
declare -i TESTS_TOTAL=0
declare -i TESTS_SKIPPED=0
declare -i TESTS_ERRORS=0
declare -i CURRENT_TEST_INDEX=0
declare -i VERBOSE_TESTS=0
declare -i STOP_ON_FAILURE=0
declare -i TEST_TIMEOUT=30

# Test state (for compatibility)
declare -g TEST_CURRENT_SUITE=""
declare -g TEST_CURRENT_TEST=""

# Test result codes
readonly TEST_PASS=0
readonly TEST_FAIL=1
readonly TEST_SKIP=2
readonly TEST_ERROR=3

# Colors for test output
declare -A TEST_COLORS=(
    ["pass"]="\033[32m"    # Green
    ["fail"]="\033[31m"    # Red
    ["skip"]="\033[33m"    # Yellow
    ["error"]="\033[35m"   # Magenta
    ["info"]="\033[36m"    # Cyan
    ["reset"]="\033[0m"    # Reset
    ["bold"]="\033[1m"     # Bold
)

# Initialize TEST_COLORS if not already defined (for compatibility)
if [[ ${#TEST_COLORS[@]} -eq 0 ]]; then
    declare -A TEST_COLORS=(
        ["pass"]="\033[32m"      # Green
        ["fail"]="\033[31m"      # Red
        ["error"]="\033[35m"     # Magenta
        ["info"]="\033[36m"      # Cyan
        ["reset"]="\033[0m"      # Reset
    )
fi

# Initialize test framework
init_tests() {
    local verbose="${1:-0}"
    local stop_on_fail="${2:-0}"
    local timeout="${3:-30}"
    
    TESTS_PASSED=0
    TESTS_FAILED=0
    TESTS_ERRORS=0
    TESTS_TOTAL=0
    TESTS_SKIPPED=0
    CURRENT_TEST_INDEX=0
    TEST_RESULTS=()
    TEST_NAMES=()
    
    VERBOSE_TESTS=$verbose
    STOP_ON_FAILURE=$stop_on_fail
    TEST_TIMEOUT=$timeout
    
    if [[ $VERBOSE_TESTS -eq 1 ]]; then
        echo -e "${TEST_COLORS[info]}${TEST_COLORS[bold]}Initializing test framework${TEST_COLORS[reset]}"
        echo "Verbose: $VERBOSE_TESTS"
        echo "Stop on failure: $STOP_ON_FAILURE"
        echo "Test timeout: ${TEST_TIMEOUT}s"
        echo
    fi
}

# Test suite (for compatibility)
describe() {
    TEST_CURRENT_SUITE="$1"
    echo
    printc "info" "bold" "Test Suite: $TEST_CURRENT_SUITE"
    echo "$(repeat_str "=" 50)"
}

# Test case (for compatibility)
it() {
    TEST_CURRENT_TEST="$1"
    ((TESTS_TOTAL++))
    echo -n "  • $TEST_CURRENT_TEST ... "
}

# Test assertion functions
assert_true() {
    local condition="$1"
    local message="${2:-Expected true}"
    
    if eval "$condition"; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-Expected false}"
    
    if ! eval "$condition"; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected values to be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_not_equals() {
    local not_expected="$1"
    local actual="$2"
    local message="${3:-Expected values to be different}"
    
    if [[ "$not_expected" != "$actual" ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected string to contain substring}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected string not to contain substring}"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_match() {
    local string="$1"
    local pattern="$2"
    local message="${3:-Expected string to match pattern}"
    
    if [[ "$string" =~ $pattern ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_matches() {
    assert_match "$@"
}

assert_file_exists() {
    local file="$1"
    local message="${2:-Expected file to exist}"
    
    if [[ -f "$file" ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_file_not_exists() {
    local file="$1"
    local message="${2:-Expected file not to exist}"
    
    if [[ ! -f "$file" ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_dir_exists() {
    local dir="$1"
    local message="${2:-Expected directory to exist}"
    
    if [[ -d "$dir" ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_dir_not_exists() {
    local dir="$1"
    local message="${2:-Expected directory not to exist}"
    
    if [[ ! -d "$dir" ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_command_success() {
    local command="$1"
    local message="${2:-Expected command to succeed}"
    
    if eval "$command" >/dev/null 2>&1; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_command_failure() {
    local command="$1"
    local message="${2:-Expected command to fail}"
    
    if ! eval "$command" >/dev/null 2>&1; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

assert_exit_code() {
    local expected="$1"
    local command="$2"
    local message="${3:-Expected specific exit code}"
    
    eval "$command" >/dev/null 2>&1
    local actual=$?
    
    if [[ $actual -eq $expected ]]; then
        test_pass
        return $TEST_PASS
    else
        test_fail "$message"
        return $TEST_FAIL
    fi
}

# Test result handlers
test_pass() {
    if [[ -n "$TEST_CURRENT_TEST" ]]; then
        echo -e "${TEST_COLORS[pass]}PASS${TEST_COLORS[reset]}"
    fi
    ((TESTS_PASSED++))
    TEST_RESULTS+=("$TEST_CURRENT_SUITE:$TEST_CURRENT_TEST:PASS")
}

test_fail() {
    local message="$1"
    if [[ -n "$TEST_CURRENT_TEST" ]]; then
        echo -e "${TEST_COLORS[fail]}FAIL${TEST_COLORS[reset]}"
        echo "    $message"
    fi
    ((TESTS_FAILED++))
    TEST_RESULTS+=("$TEST_CURRENT_SUITE:$TEST_CURRENT_TEST:FAIL:$message")
}

test_error() {
    local message="$1"
    if [[ -n "$TEST_CURRENT_TEST" ]]; then
        echo -e "${TEST_COLORS[error]}ERROR${TEST_COLORS[reset]}"
        echo "    $message"
    fi
    ((TESTS_ERRORS++))
    TEST_RESULTS+=("$TEST_CURRENT_SUITE:$TEST_CURRENT_TEST:ERROR:$message")
}

# Test runner functions
run_test() {
    local test_name="$1"
    local test_function="$2"
    local timeout="${3:-$TEST_TIMEOUT}"
    
    ((TESTS_TOTAL++))
    CURRENT_TEST_INDEX=$TESTS_TOTAL
    TEST_CURRENT_TEST="$test_name"
    
    local start_time=$(date +%s)
    local result=$TEST_PASS
    local output=""
    local error_output=""
    
    if [[ $VERBOSE_TESTS -eq 1 ]]; then
        echo -e "${TEST_COLORS[info]}Running test $CURRENT_TEST_INDEX/$TESTS_TOTAL: $test_name${TEST_COLORS[reset]}"
    fi
    
    # Run test with timeout
    if command -v timeout >/dev/null 2>&1; then
        output=$(timeout "$timeout" bash -c "$test_function" 2>&1)
        result=$?
        if [[ $result -eq 124 ]]; then
            result=$TEST_ERROR
            error_output="Test timed out after ${timeout}s"
        fi
    else
        output=$(eval "$test_function" 2>&1)
        result=$?
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Store test result
    TEST_RESULTS[$result]=$((TEST_RESULTS[$result] + 1))
    TEST_NAMES[$TESTS_TOTAL]="$test_name"
    
    # Update counters
    case $result in
        $TEST_PASS)
            ((TESTS_PASSED++))
            if [[ $VERBOSE_TESTS -eq 1 ]]; then
                echo -e "${TEST_COLORS[pass]}✓ PASS${TEST_COLORS[reset]} ($duration)s"
            fi
            ;;
        $TEST_FAIL)
            ((TESTS_FAILED++))
            echo -e "${TEST_COLORS[fail]}✗ FAIL${TEST_COLORS[reset]} $test_name ($duration)s"
            if [[ -n "$output" ]]; then
                echo -e "${TEST_COLORS[fail]}$output${TEST_COLORS[reset]}"
            fi
            ;;
        $TEST_SKIP)
            ((TESTS_SKIPPED++))
            echo -e "${TEST_COLORS[skip]}- SKIP${TEST_COLORS[reset]} $test_name ($duration)s"
            ;;
        $TEST_ERROR)
            ((TESTS_ERRORS++))
            echo -e "${TEST_COLORS[error]}✗ ERROR${TEST_COLORS[reset]} $test_name ($duration)s"
            if [[ -n "$error_output" ]]; then
                echo -e "${TEST_COLORS[error]}$error_output${TEST_COLORS[reset]}"
            fi
            if [[ -n "$output" ]]; then
                echo -e "${TEST_COLORS[error]}$output${TEST_COLORS[reset]}"
            fi
            ;;
    esac
    
    # Stop on failure if enabled
    if [[ $result -ne $TEST_PASS && $result -ne $TEST_SKIP && $STOP_ON_FAILURE -eq 1 ]]; then
        echo -e "${TEST_COLORS[fail]}Stopping test execution due to failure${TEST_COLORS[reset]}"
        return $result
    fi
    
    return $result
}

# Test suite functions
test_suite() {
    local suite_name="$1"
    shift
    local -a test_functions=("$@")
    
    echo -e "${TEST_COLORS[bold]}${TEST_COLORS[info]}Test Suite: $suite_name${TEST_COLORS[reset]}"
    echo
    
    local suite_start_time=$(date +%s)
    local suite_result=$TEST_PASS
    
    for test_func in "${test_functions[@]}"; do
        if declare -f "$test_func" >/dev/null; then
            run_test "$test_func" "$test_func"
            local result=$?
            if [[ $result -ne $TEST_PASS && $result -ne $TEST_SKIP ]]; then
                suite_result=$result
            fi
        else
            echo -e "${TEST_COLORS[fail]}Test function not found: $test_func${TEST_COLORS[reset]}"
            ((TESTS_FAILED++))
            suite_result=$TEST_FAIL
        fi
    done
    
    local suite_end_time=$(date +%s)
    local suite_duration=$((suite_end_time - suite_start_time))
    
    echo
    echo -e "${TEST_COLORS[bold]}Suite Results: $suite_name${TEST_COLORS[reset]}"
    echo "Duration: ${suite_duration}s"
    echo "Passed: $TESTS_PASSED"
    echo "Failed: $TESTS_FAILED"
    echo "Errors: $TESTS_ERRORS"
    echo "Skipped: $TESTS_SKIPPED"
    echo "Total: $TESTS_TOTAL"
    echo
    
    return $suite_result
}

# Test helper functions
skip_test() {
    local reason="${1:-No reason provided}"
    echo "Skipping test: $reason"
    return $TEST_SKIP
}

setup_test() {
    local test_name="$1"
    local setup_function="$2"
    
    if [[ -n "$setup_function" ]] && declare -f "$setup_function" >/dev/null; then
        if [[ $VERBOSE_TESTS -eq 1 ]]; then
            echo "Setting up test: $test_name"
        fi
        eval "$setup_function"
    fi
}

teardown_test() {
    local test_name="$1"
    local teardown_function="$2"
    
    if [[ -n "$teardown_function" ]] && declare -f "$teardown_function" >/dev/null; then
        if [[ $VERBOSE_TESTS -eq 1 ]]; then
            echo "Tearing down test: $test_name"
        fi
        eval "$teardown_function"
    fi
}

# Before/after hooks (for compatibility)
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

# Test reporting functions
print_test_summary() {
    echo -e "${TEST_COLORS[bold]}${TEST_COLORS[info]}Test Summary${TEST_COLORS[reset]}"
    echo "================================"
    echo "Total tests: $TESTS_TOTAL"
    echo -e "Passed: ${TEST_COLORS[pass]}$TESTS_PASSED${TEST_COLORS[reset]}"
    echo -e "Failed: ${TEST_COLORS[fail]}$TESTS_FAILED${TEST_COLORS[reset]}"
    echo -e "Errors: ${TEST_COLORS[error]}$TESTS_ERRORS${TEST_COLORS[reset]}"
    echo -e "Skipped: ${TEST_COLORS[skip]}$TESTS_SKIPPED${TEST_COLORS[reset]}"
    echo
    
    if [[ $TESTS_FAILED -eq 0 && $TESTS_ERRORS -eq 0 ]]; then
        echo -e "${TEST_COLORS[pass]}${TEST_COLORS[bold]}All tests passed!${TEST_COLORS[reset]}"
        return $TEST_PASS
    else
        echo -e "${TEST_COLORS[fail]}${TEST_COLORS[bold]}Some tests failed!${TEST_COLORS[reset]}"
        return $TEST_FAIL
    fi
}

print_test_details() {
    echo -e "${TEST_COLORS[bold]}${TEST_COLORS[info]}Test Details${TEST_COLORS[reset]}"
    echo "=================="
    
    for ((i=1; i<=TESTS_TOTAL; i++)); do
        local test_name="${TEST_NAMES[$i]}"
        local status="Unknown"
        
        # Determine test status (simplified)
        if [[ $i -le $TESTS_PASSED ]]; then
            status="PASS"
            echo -e "${TEST_COLORS[pass]}$i. $test_name: $status${TEST_COLORS[reset]}"
        elif [[ $i -le $((TESTS_PASSED + TESTS_FAILED + TESTS_ERRORS)) ]]; then
            status="FAIL/ERROR"
            echo -e "${TEST_COLORS[fail]}$i. $test_name: $status${TEST_COLORS[reset]}"
        else
            status="SKIP"
            echo -e "${TEST_COLORS[skip]}$i. $test_name: $status${TEST_COLORS[reset]}"
        fi
    done
}

# Test file generation
generate_test_file() {
    local content="$1"
    local file_path="$2"
    
    if [[ -z "$file_path" ]]; then
        file_path="/tmp/test_file_$(date +%s).txt"
    fi
    
    echo "$content" > "$file_path"
    echo "$file_path"
}

# Test directory generation
generate_test_dir() {
    local dir_path="${1:-/tmp/test_dir_$(date +%s)}"
    
    mkdir -p "$dir_path"
    echo "$dir_path"
}

# Mock functions for testing
mock_function() {
    local original_func="$1"
    local mock_func="$2"
    local mock_return="${3:-0}"
    
    # Save original function if it exists
    if declare -f "$original_func" >/dev/null; then
        eval "original_${original_func}() { $(declare -f "$original_func" | tail -n +2); }"
    fi
    
    # Create mock function
    eval "$original_func() { $mock_func; return $mock_return; }"
}

unmock_function() {
    local original_func="$1"
    
    # Restore original function if it was saved
    if declare -f "original_${original_func}" >/dev/null; then
        eval "$original_func() { $(declare -f "original_${original_func}" | tail -n +2); }"
        unset -f "original_${original_func}"
    else
        unset -f "$original_func"
    fi
}

# Mock functions (for compatibility)
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

# Performance testing
benchmark_function() {
    local func_name="$1"
    local iterations="${2:-100}"
    local -n result_ref="$3"
    
    if [[ ! -f "$func_name" ]] && ! declare -f "$func_name"; then
        error "Function not found: $func_name"
        return ${EXIT_FAILURE:-1}
    fi
    
    local start_time=$(date +%s%N)
    
    for ((i=0; i<iterations; i++)); do
        if declare -f "$func_name" >/dev/null; then
            "$func_name" >/dev/null
        else
            bash "$func_name" >/dev/null
        fi
    done
    
    local end_time=$(date +%s%N)
    local duration=$(((end_time - start_time) / 1000000))  # Convert to milliseconds
    
    result_ref["iterations"]=$iterations
    result_ref["duration_ms"]=$duration
    result_ref["avg_ms"]=$((duration / iterations))
    
    echo "Benchmark results for $func_name:"
    echo "Iterations: $iterations"
    echo "Total duration: ${duration}ms"
    echo "Average per iteration: ${result_ref[avg_ms]}ms"
}

# Test coverage (basic)
test_coverage() {
    local script_file="$1"
    local -n result_ref="$2"
    
    if [[ ! -f "$script_file" ]]; then
        error "Script file not found: $script_file"
        return ${EXIT_FAILURE:-1}
    fi
    
    # Extract function names
    local -a functions
    mapfile -t functions < <(grep -n "^function \|^ *[a-zA-Z_][a-zA-Z0-9_]*() {" "$script_file" | grep -v "function test_" | head -10)
    
    result_ref["total_functions"]=${#functions[@]}
    result_ref["functions_tested"]=0  # This would require more sophisticated analysis
    
    echo "Coverage analysis for $script_file:"
    echo "Total functions found: ${result_ref[total_functions]}"
    echo "Functions tested: ${result_ref[functions_tested]}"
    echo "Coverage: $((result_ref[functions_tested] * 100 / result_ref[total_functions]))%"
}

# Test configuration
configure_tests() {
    local config_file="$1"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        if [[ $VERBOSE_TESTS -eq 1 ]]; then
            echo "Loaded test configuration from: $config_file"
        fi
    else
        if [[ $VERBOSE_TESTS -eq 1 ]]; then
            echo "Test configuration file not found: $config_file"
        fi
    fi
}

# Test runner (for compatibility)
run_test_file() {
    local test_file="$1"
    
    if [[ ! -f "$test_file" ]]; then
        echo "Test file not found: $test_file"
        return 1
    fi
    
    echo "Running tests from: $test_file"
    echo "$(repeat_str "-" 60)"
    
    # Reset counters
    TEST_TOTAL=0
    TEST_PASSED=0
    TEST_FAILED=0
    TEST_ERRORS=0
    TEST_SKIPPED=0
    TEST_RESULTS=()
    
    # Source test file in subshell
    (
        source "$test_file"
        
        # Print summary
        echo
        printc "info" "bold" "Test Summary:"
        echo "  Total: $TEST_TOTAL"
        echo -e "  Passed: ${TEST_COLORS[pass]}$TEST_PASSED${TEST_COLORS[reset]}"
        echo -e "  Failed: ${TEST_COLORS[fail]}$TEST_FAILED${TEST_COLORS[reset]}"
        echo -e "  Errors: ${TEST_COLORS[error]}$TEST_ERRORS${TEST_COLORS[reset]}"
        echo -e "  Skipped: ${TEST_COLORS[skip]}$TESTS_SKIPPED${TEST_COLORS[reset]}"
        
        # Return appropriate exit code
        if [[ $TEST_FAILED -gt 0 ]] || [[ $TEST_ERRORS -gt 0 ]]; then
            exit 1
        else
            exit 0
        fi
    )
}

# Run all test files (for compatibility)
run_all_tests() {
    local test_dir="${1:-tests}"
    
    if [[ ! -d "$test_dir" ]]; then
        echo "Test directory not found: $test_dir"
        return 1
    fi
    
    local total_passed=0
    local total_failed=0
    local total_files=0
    
    echo "Running all tests in: $test_dir"
    echo "$(repeat_str "=" 80)"
    
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
    echo "$(repeat_str "=" 80)"
    printc "info" "bold" "Overall Summary:"
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

# Generate test report (for compatibility)
generate_report() {
    local output_file="${1:-test_report.txt}"
    
    {
        echo "Test Report - $(date)"
        echo "$(repeat_str "=" 50)"
        echo
        
        echo "Test Summary:"
        echo "  Total Tests: $TEST_TOTAL"
        echo "  Passed: $TEST_PASSED"
        echo "  Failed: $TEST_FAILED"
        echo "  Errors: $TEST_ERRORS"
        echo "  Skipped: $TESTS_SKIPPED"
        echo
        
        if [[ ${#TEST_RESULTS[@]} -gt 0 ]]; then
            echo "Detailed Results:"
            echo "$(repeat_str "-" 50)"
            
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

# Helper function for colored output (for compatibility)
printc() {
    local color="$1"
    local style="$2"
    local text="$3"
    
    echo -e "${TEST_COLORS[$color]}$text${TEST_COLORS[reset]}"
}

# Export module functions
export_module testing \
    init_tests \
    describe it \
    assert_true assert_false assert_equals assert_not_equals assert_contains assert_not_contains assert_match assert_matches \
    assert_file_exists assert_file_not_exists assert_dir_exists assert_dir_not_exists \
    assert_command_success assert_command_failure assert_exit_code \
    test_pass test_fail test_error \
    run_test test_suite \
    skip_test setup_test teardown_test before_each after_each \
    print_test_summary print_test_details \
    generate_test_file generate_test_dir \
    mock_function unmock_function mock unmock \
    benchmark_function test_coverage \
    configure_tests \
    run_test_file run_all_tests generate_report printc