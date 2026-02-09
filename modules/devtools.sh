#!/bin/bash

# Development Tools Module
# Provides debugging, profiling, and code analysis utilities

module_version devtools 1.0.0

# Debugging utilities
declare -a DEBUG_BREAKPOINTS=()
declare -i DEBUG_ENABLED=0
declare -i DEBUG_VERBOSE=0
declare -i DEBUG_STEP_MODE=0
declare -i DEBUG_CURRENT_LINE=0
declare -g DEBUG_LEVEL=1
declare -g DEBUG_FILE=""

# Enable debugging
enable_debug() {
    local verbose="${1:-0}"
    local level="${2:-1}"
    local file="${3:-debug.log}"
    
    DEBUG_ENABLED=1
    DEBUG_VERBOSE=$verbose
    DEBUG_LEVEL=$level
    DEBUG_FILE=$file
    
    if [[ $DEBUG_VERBOSE -eq 1 ]]; then
        echo "Debug mode enabled (verbose: $verbose, level: $level, log: $file)"
    fi
    
    # Set up debug trap
    trap 'debug_trap $LINENO "$BASH_COMMAND"' DEBUG
}

# Disable debugging
disable_debug() {
    DEBUG_ENABLED=0
    DEBUG_STEP_MODE=0
    DEBUG_BREAKPOINTS=()
    
    # Remove debug trap
    trap - DEBUG
    
    if [[ $DEBUG_VERBOSE -eq 1 ]]; then
        echo "Debug mode disabled"
    fi
}

# Debug logging
debug_log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    if [[ $DEBUG_ENABLED -eq 1 ]] && [[ $level -le $DEBUG_LEVEL ]]; then
        local log_entry="[$timestamp] [DEBUG:$level] $message"
        echo "$log_entry" | tee -a "$DEBUG_FILE" >&2
    fi
}

# Debug trap handler
debug_trap() {
    local line_no="$1"
    local command="$2"
    DEBUG_CURRENT_LINE=$line_no
    
    # Check if we hit a breakpoint
    if [[ " ${DEBUG_BREAKPOINTS[@]} " =~ " $line_no " ]]; then
        echo "Breakpoint hit at line $line_no"
        echo "Command: $command"
        echo "Stack:"
        local frame=0
        while caller $frame; do
            ((frame++))
        done
        echo
        
        if [[ $DEBUG_STEP_MODE -eq 1 ]]; then
            debug_prompt
        fi
    fi
    
    if [[ $DEBUG_VERBOSE -eq 1 ]]; then
        echo "DEBUG: Line $line_no: $command"
    fi
}

# Set breakpoint
set_breakpoint() {
    local line_no="$1"
    
    if [[ -n "$line_no" && "$line_no" =~ ^[0-9]+$ ]]; then
        DEBUG_BREAKPOINTS+=("$line_no")
        echo "Breakpoint set at line $line_no"
    else
        echo "Invalid line number: $line_no"
    fi
}

# Remove breakpoint
remove_breakpoint() {
    local line_no="$1"
    local -a new_breakpoints=()
    
    for bp in "${DEBUG_BREAKPOINTS[@]}"; do
        if [[ "$bp" != "$line_no" ]]; then
            new_breakpoints+=("$bp")
        fi
    done
    
    DEBUG_BREAKPOINTS=("${new_breakpoints[@]}")
    echo "Breakpoint removed from line $line_no"
}

# List breakpoints
list_breakpoints() {
    if [[ ${#DEBUG_BREAKPOINTS[@]} -eq 0 ]]; then
        echo "No breakpoints set"
    else
        echo "Breakpoints:"
        for bp in "${DEBUG_BREAKPOINTS[@]}"; do
            echo "  Line $bp"
        done
    fi
}

# Debug prompt
debug_prompt() {
    while true; do
        echo -n "debug> "
        read -r cmd
        
        case "$cmd" in
            "c"|"continue")
                break
                ;;
            "s"|"step")
                DEBUG_STEP_MODE=1
                break
                ;;
            "n"|"next")
                DEBUG_STEP_MODE=0
                break
                ;;
            "l"|"list")
                debug_list_variables
                ;;
            "b"|"backtrace")
                debug_backtrace
                ;;
            "h"|"help")
                debug_help
                ;;
            "q"|"quit")
                exit 0
                ;;
            *)
                echo "Unknown command: $cmd"
                debug_help
                ;;
        esac
    done
}

# List variables in debug context
debug_list_variables() {
    echo "Variables:"
    # List environment variables
    env | head -20
    echo "..."
}

# Show backtrace
debug_backtrace() {
    echo "Backtrace:"
    local frame=0
    while caller $frame; do
        ((frame++))
    done
}

# Debug help
debug_help() {
    echo "Debug commands:"
    echo "  c, continue  - Continue execution"
    echo "  s, step      - Step to next line"
    echo "  n, next      - Continue to next breakpoint"
    echo "  l, list      - List variables"
    echo "  b, backtrace - Show backtrace"
    echo "  h, help      - Show this help"
    echo "  q, quit      - Quit debugging"
}

# Breakpoint (for compatibility)
breakpoint() {
    local condition="$1"
    local message="${2:-Breakpoint hit}"
    
    if [[ $DEBUG_ENABLED -eq 1 ]]; then
        if [[ -n "$condition" ]]; then
            if ! eval "$condition"; then
                return 0
            fi
        fi
        
        debug_log 1 "$message"
        echo "=== BREAKPOINT ==="
        echo "Function: ${FUNCNAME[1]}"
        echo "Line: ${BASH_LINENO[0]}"
        echo "File: ${BASH_SOURCE[1]}"
        echo "Stack:"
        for i in "${!FUNCNAME[@]}"; do
            echo "  $i: ${FUNCNAME[$i]} (${BASH_SOURCE[$i]}:${BASH_LINENO[$i]})"
        done
        echo "=================="
        
        # Interactive debugging
        while true; do
            echo -n "debug> "
            read -r cmd
            case "$cmd" in
                "c"|"continue") break ;;
                "v"|"vars") 
                    echo "Local variables:"
                    set | grep -E "^[a-zA-Z_][a-zA-Z0-9_]*=" | head -10
                    ;;
                "s"|"stack") 
                    echo "Call stack:"
                    for i in "${!FUNCNAME[@]}"; do
                        echo "  $i: ${FUNCNAME[$i]}"
                    done
                    ;;
                "q"|"quit") exit 1 ;;
                "h"|"help") 
                    echo "Commands: c(continue), v(vars), s(stack), q(quit), h(help)"
                    ;;
                *) echo "Unknown command: $cmd" ;;
            esac
        done
    fi
}

# Variable watcher
watch_variable() {
    local var_name="$1"
    local old_value="${!var_name}"
    
    while true; do
        local new_value="${!var_name}"
        if [[ "$new_value" != "$old_value" ]]; then
            echo "Variable $var_name changed: '$old_value' -> '$new_value'"
            old_value="$new_value"
        fi
        sleep 0.1
    done
}

# Function tracer
trace_function() {
    local func_name="$1"
    local -n result_ref="$2"
    
    # Save original function
    if declare -f "$func_name" >/dev/null; then
        eval "original_$func_name() { $(declare -f "$func_name" | tail -n +2); }"
    fi
    
    # Create traced version
    eval "$func_name() {
        echo \"ENTER: $func_name \$@\"
        local start_time=\$(date +%s%N)
        original_$func_name \"\$@\"
        local result=\$?
        local end_time=\$(date +%s%N)
        local duration=\$(((end_time - start_time) / 1000000))
        echo \"EXIT: $func_name (result: \$result, duration: \${duration}ms)\"
        return \$result
    }"
    
    result_ref="Function $func_name is now being traced"
}

# Remove function tracer
untrace_function() {
    local func_name="$1"
    
    if declare -f "original_$func_name" >/dev/null; then
        eval "$func_name() { $(declare -f "original_$func_name" | tail -n +2); }"
        unset -f "original_$func_name"
        echo "Function $func_name is no longer being traced"
    fi
}

# Profiling utilities
declare -A PROFILE_DATA
declare -i PROFILE_ENABLED=0
declare -i PROFILE_START_TIME=0
declare -g PROFILER_ENABLED=0
declare -g PROFILER_DATA=()

# Enable profiling
enable_profile() {
    PROFILE_ENABLED=1
    PROFILER_ENABLED=1
    PROFILE_START_TIME=$(date +%s%N)
    PROFILER_START_TIME=$(date +%s.%N)
    PROFILE_DATA=()
    PROFILER_DATA=()
    
    # Set up profiling trap
    trap 'profile_trap $LINENO "$BASH_COMMAND"' DEBUG
    
    echo "Profiling enabled"
}

# Disable profiling
disable_profile() {
    PROFILE_ENABLED=0
    PROFILER_ENABLED=0
    
    # Remove profiling trap
    trap - DEBUG
    
    echo "Profiling disabled"
}

# Profile trap handler
profile_trap() {
    local line_no="$1"
    local command="$2"
    local current_time=$(date +%s%N)
    local duration=$((current_time - PROFILE_START_TIME))
    
    if [[ $PROFILE_ENABLED -eq 1 ]]; then
        PROFILE_DATA["$line_no"]="${PROFILE_DATA[$line_no]:-0} $duration"
    fi
    
    if [[ $PROFILER_ENABLED -eq 1 ]]; then
        PROFILER_DATA+=("$line_no:$duration")
        debug_log 2 "Profile: Line $line_no took ${duration}ns"
    fi
}

# Generate profile report
generate_profile_report() {
    local output_file="${1:-profile_report.txt}"
    
    {
        echo "Profile Report - $(date)"
        echo "========================"
        echo
        
        echo "Line execution counts:"
        for line_no in "${!PROFILE_DATA[@]}"; do
            local times="${PROFILE_DATA[$line_no]}"
            local count=$(echo "$times" | wc -w)
            echo "Line $line_no: $count executions"
        done
        
        echo
        echo "Total execution time: $(((date +%s%N) - PROFILE_START_TIME) / 1000000)ms"
        
    } > "$output_file"
    
    echo "Profile report generated: $output_file"
}

# Function profiler
profile_function() {
    local func_name="$1"
    local iterations="${2:-100}"
    local -n result_ref="$3"
    
    if ! declare -f "$func_name" >/dev/null; then
        echo "Function not found: $func_name"
        return 1
    fi
    
    echo "Profiling function: $func_name ($iterations iterations)"
    
    local total_time=0
    local min_time=999999999
    local max_time=0
    
    for ((i=0; i<iterations; i++)); do
        local start_time=$(date +%s%N)
        "$func_name" >/dev/null 2>&1
        local end_time=$(date +%s%N)
        local duration=$(((end_time - start_time) / 1000000))  # Convert to ms
        
        total_time=$((total_time + duration))
        
        if [[ $duration -lt $min_time ]]; then
            min_time=$duration
        fi
        
        if [[ $duration -gt $max_time ]]; then
            max_time=$duration
        fi
    done
    
    local avg_time=$((total_time / iterations))
    
    result_ref["function"]="$func_name"
    result_ref["iterations"]=$iterations
    result_ref["total_ms"]=$total_time
    result_ref["avg_ms"]=$avg_time
    result_ref["min_ms"]=$min_time
    result_ref["max_ms"]=$max_time
    
    echo "Function: $func_name"
    echo "Iterations: $iterations"
    echo "Total time: ${total_time}ms"
    echo "Average: ${avg_time}ms"
    echo "Min: ${min_time}ms"
    echo "Max: ${max_time}ms"
}

# Function profiler (for compatibility)
profile_function_compat() {
    local func_name="$1"
    local start_time
    start_time=$(date +%s.%N)
    
    # Call the function
    "$@"
    
    local end_time
    end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l)
    
    if [[ $PROFILER_ENABLED -eq 1 ]]; then
        PROFILER_DATA+=("$func_name:$duration")
        debug_log 2 "Profile: $func_name took ${duration}s"
    fi
}

# Memory usage profiler
profile_memory() {
    local command="$1"
    local -n result_ref="$2"
    
    echo "Profiling memory usage for: $command"
    
    # Get initial memory
    local initial_mem=$(get_memory_usage)
    local initial_pid=$$
    
    # Run command
    eval "$command" >/dev/null 2>&1
    local exit_code=$?
    
    # Get final memory
    local final_mem=$(get_memory_usage)
    
    result_ref["command"]="$command"
    result_ref["initial_kb"]=$initial_mem
    result_ref["final_kb"]=$final_mem
    result_ref["delta_kb"]=$((final_mem - initial_mem))
    result_ref["exit_code"]=$exit_code
    
    echo "Command: $command"
    echo "Initial memory: ${initial_mem}KB"
    echo "Final memory: ${final_mem}KB"
    echo "Memory delta: $((final_mem - initial_mem))KB"
    echo "Exit code: $exit_code"
}

# Get memory usage
get_memory_usage() {
    local pid="${1:-$$}"
    if command -v ps > /dev/null; then
        ps -o rss= -p "$pid" | tr -d ' '
    else
        echo "0"
    fi
}

# Performance monitor
monitor_performance() {
    local command="$1"
    local interval="${2:-1}"
    
    echo "Monitoring performance of: $command"
    echo "Time(s) | CPU% | Memory(MB) | Status"
    echo "$(repeat_str "-" 40)"
    
    local start_time=$(date +%s)
    local pid
    
    # Start command in background
    eval "$command" &
    pid=$!
    
    while kill -0 "$pid" 2>/dev/null; do
        local elapsed=$(($(date +%s) - start_time))
        local cpu_usage=$(ps -o %cpu= -p "$pid" 2>/dev/null | tr -d ' ')
        local memory_kb=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
        local memory_mb=$(echo "scale=2; $memory_kb / 1024" | bc -l 2>/dev/null || echo "0")
        
        printf "%7s | %4s | %10s | Running\n" "$elapsed" "${cpu_usage:-0}" "${memory_mb:-0}"
        sleep "$interval"
    done
    
    local final_elapsed=$(($(date +%s) - start_time))
    printf "%7s | %4s | %10s | Completed\n" "$final_elapsed" "0" "0"
}

# Code analysis utilities
analyze_script() {
    local script_file="$1"
    local -n result_ref="$2"
    
    if [[ ! -f "$script_file" ]]; then
        echo "Script file not found: $script_file"
        return 1
    fi
    
    echo "Analyzing script: $script_file"
    
    # Count lines
    local total_lines=$(wc -l < "$script_file")
    local non_empty_lines=$(grep -c . "$script_file")
    local comment_lines=$(grep -c '^[[:space:]]*#' "$script_file")
    
    # Count functions
    local function_count=$(grep -c '^function \|^ *[a-zA-Z_][a-zA-Z0-9_]*() ' "$script_file")
    
    # Count variables
    local variable_count=$(grep -c '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*=' "$script_file")
    
    # Check for common issues
    local issues=()
    
    # Check for unused variables (basic)
    if grep -q '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*=' "$script_file"; then
        local declared_vars=$(grep '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*=' "$script_file" | sed 's/^[[:space:]]*\([a-zA-Z_][a-zA-Z0-9_]*\)=.*/\1/' | sort -u)
        for var in $declared_vars; do
            if ! grep -q "\$$var" "$script_file"; then
                issues+=("Potentially unused variable: $var")
            fi
        done
    fi
    
    # Check for functions without return
    if grep -q '^function \|^ *[a-zA-Z_][a-zA-Z0-9_]*() ' "$script_file"; then
        local func_without_return=$(grep -A 10 '^function \|^ *[a-zA-Z_][a-zA-Z0-9_]*() ' "$script_file" | grep -B 10 -E '^[[:space:]]*}' | grep -E '^function \|^ *[a-zA-Z_][a-zA-Z0-9_]*() ' | wc -l)
        if [[ $func_without_return -gt 0 ]]; then
            issues+=("$func_without_return functions may not have explicit return")
        fi
    fi
    
    result_ref["file"]="$script_file"
    result_ref["total_lines"]=$total_lines
    result_ref["non_empty_lines"]=$non_empty_lines
    result_ref["comment_lines"]=$comment_lines
    result_ref["function_count"]=$function_count
    result_ref["variable_count"]=$variable_count
    result_ref["issues"]="${issues[*]}"
    
    echo "Analysis results for $script_file:"
    echo "Total lines: $total_lines"
    echo "Non-empty lines: $non_empty_lines"
    echo "Comment lines: $comment_lines"
    echo "Functions: $function_count"
    echo "Variables: $variable_count"
    
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "Issues found:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
    fi
}

# Code analyzer (for compatibility)
analyze_code() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return 1
    fi
    
    echo "Code Analysis for: $file"
    echo "$(repeat_str "=" 50)"
    
    # Basic stats
    local lines=$(wc -l < "$file")
    local functions=$(grep -c "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*(" "$file")
    local comments=$(grep -c "^[[:space:]]*#" "$file")
    local empty_lines=$(grep -c "^[[:space:]]*$" "$file")
    
    echo "Lines: $lines"
    echo "Functions: $functions"
    echo "Comments: $comments"
    echo "Empty lines: $empty_lines"
    echo "Code density: $(echo "scale=1; ($lines - $comments - $empty_lines) * 100 / $lines" | bc -l)%"
    echo
    
    # Function analysis
    echo "Functions:"
    echo "$(repeat_str "-" 30)"
    grep -n "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*(" "$file" | while read -r line; do
        local line_num=$(echo "$line" | cut -d':' -f1)
        local func_def=$(echo "$line" | cut -d':' -f2-)
        echo "  $line_num: $func_def"
    done
    echo
    
    # Potential issues
    echo "Potential Issues:"
    echo "$(repeat_str "-" 30)"
    
    # Check for common issues
    if grep -q "eval " "$file"; then
        echo "  ⚠ Uses eval (potential security risk)"
    fi
    
    if grep -q "\$.*\|.*\$" "$file"; then
        echo "  ⚠ Uses pipe to subshell (performance impact)"
    fi
    
    if grep -q "rm -rf " "$file"; then
        echo "  ⚠ Uses rm -rf (destructive operation)"
    fi
    
    if grep -q "chmod +x " "$file"; then
        echo "  ⚠ Uses chmod +x (security consideration)"
    fi
}

# Check script syntax
check_syntax() {
    local script_file="$1"
    local -n result_ref="$2"
    
    if [[ ! -f "$script_file" ]]; then
        echo "Script file not found: $script_file"
        return 1
    fi
    
    echo "Checking syntax for: $script_file"
    
    local syntax_output
    syntax_output=$(bash -n "$script_file" 2>&1)
    local syntax_result=$?
    
    result_ref["file"]="$script_file"
    result_ref["syntax_result"]=$syntax_result
    result_ref["syntax_output"]="$syntax_output"
    
    if [[ $syntax_result -eq 0 ]]; then
        echo "Syntax check passed"
    else
        echo "Syntax errors found:"
        echo "$syntax_output"
    fi
    
    return $syntax_result
}

# Code formatter
format_code() {
    local script_file="$1"
    local output_file="${2:-${script_file%.sh}_formatted.sh}"
    local indent_size="${3:-4}"
    
    if [[ ! -f "$script_file" ]]; then
        echo "Script file not found: $script_file"
        return 1
    fi
    
    echo "Formatting code: $script_file -> $output_file"
    
    # Basic formatting rules
    sed "
        # Remove trailing whitespace
        s/[[:space:]]*$//
        
        # Ensure consistent spacing around operators
        s/\([^=]\)=\([^=]\)/\1 = \2/g
        s/\([^+]\)\+\([^+]\)/\1 + \2/g
        s/\([^-]\)-\([^-]\)/\1 - \2/g
        s/\([^*]\)\*\([^*]\)/\1 * \2/g
        s/\([^/]\)\/\([^/]\)/\1 \/ \2/g
        
        # Add spacing after semicolons
        s/;/; /g
        
    " "$script_file" > "$output_file"
    
    echo "Code formatted: $output_file"
}

# Code formatter (for compatibility)
format_code_compat() {
    local file="$1"
    local backup="${2:-1}"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return 1
    fi
    
    if [[ "$backup" == "1" ]]; then
        cp "$file" "$file.backup"
        echo "Backup created: $file.backup"
    fi
    
    # Format the code
    local temp_file=$(mktemp)
    
    # Remove trailing whitespace
    sed 's/[[:space:]]*$//' "$file" > "$temp_file"
    
    # Ensure proper spacing around operators
    sed -i 's/=\([^=]\)/= \1/g' "$temp_file"
    sed -i 's/\([^=]\)=/\1 =/g' "$temp_file"
    
    # Add proper indentation (basic)
    sed -i 's/^    /    /g' "$temp_file"
    
    # Move formatted file back
    mv "$temp_file" "$file"
    
    echo "Code formatted: $file"
}

# Lint script
lint_script() {
    local script_file="$1"
    local -n result_ref="$2"
    
    if [[ ! -f "$script_file" ]]; then
        echo "Script file not found: $script_file"
        return 1
    fi
    
    echo "Linting script: $script_file"
    
    local -a lint_issues=()
    local line_num=0
    
    while IFS= read -r line; do
        ((line_num++))
        
        # Check for common issues
        if [[ "$line" =~ ^[[:space:]]*echo[[:space:]]+.*\$[A-Za-z_][A-Za-z0-9_]*[[:space:]]*$ ]]; then
            lint_issues+=("Line $line_num: Unquoted variable in echo")
        fi
        
        if [[ "$line" =~ ^[[:space:]]*rm[[:space:]]+-rf[[:space:]]+/ ]]; then
            lint_issues+=("Line $line_num: Dangerous rm -rf / command")
        fi
        
        if [[ "$line" =~ ^[[:space:]]*eval[[:space:]]+ ]]; then
            lint_issues+=("Line $line_num: Use of eval (potential security risk)")
        fi
        
        if [[ "$line" =~ ^[[:space:]]*chmod[[:space:]]+777 ]]; then
            lint_issues+=("Line $line_num: World-writable permissions (security risk)")
        fi
        
    done < "$script_file"
    
    result_ref["file"]="$script_file"
    result_ref["issues"]="${lint_issues[*]}"
    result_ref["issue_count"]=${#lint_issues[@]}
    
    echo "Lint results for $script_file:"
    if [[ ${#lint_issues[@]} -eq 0 ]]; then
        echo "No issues found"
    else
        echo "Issues found (${#lint_issues[@]}):"
        for issue in "${lint_issues[@]}"; do
            echo "  - $issue"
        done
    fi
}

# Linter (for compatibility)
lint_code() {
    local file="$1"
    local errors=0
    
    echo "Linting: $file"
    echo "$(repeat_str "=" 40)"
    
    # Check shebang
    if ! head -n1 "$file" | grep -q "^#!"; then
        echo "✗ Missing shebang"
        ((errors++))
    else
        echo "✓ Shebang present"
    fi
    
    # Check for common issues
    local issues=(
        "eval.*\\$.*:Use of eval with variables"
        "rm -rf.*\\$:Destructive operation with variable"
        "chmod +x.*\\$:Permission change with variable"
        "^[[:space:]]*echo.*>>.*\\$:Appending to variable file"
        "^[[:space:]]*\\$.*\\|.*\\$:Pipe to subshell"
    )
    
    for issue in "${issues[@]}"; do
        local pattern=$(echo "$issue" | cut -d':' -f1)
        local message=$(echo "$issue" | cut -d':' -f2)
        
        if grep -qE "$pattern" "$file"; then
            echo "⚠ $message"
            ((errors++))
        fi
    done
    
    # Check function naming
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\( ]]; then
            local func_name="${BASH_REMATCH[1]}"
            if [[ ! "$func_name" =~ ^[a-z_][a-z0-9_]*$ ]]; then
                echo "⚠ Function name should be lowercase: $func_name"
                ((errors++))
            fi
        fi
    done < "$file"
    
    echo
    if [[ $errors -eq 0 ]]; then
        echo "✓ No issues found"
    else
        echo "✗ $errors potential issues found"
    fi
    
    return $errors
}

# Performance benchmark
benchmark_script() {
    local script_file="$1"
    local iterations="${2:-10}"
    local -n result_ref="$3"
    
    if [[ ! -f "$script_file" ]]; then
        echo "Script file not found: $script_file"
        return 1
    fi
    
    echo "Benchmarking script: $script_file ($iterations iterations)"
    
    local total_time=0
    local min_time=999999999
    local max_time=0
    
    for ((i=0; i<iterations; i++)); do
        local start_time=$(date +%s%N)
        bash "$script_file" >/dev/null 2>&1
        local end_time=$(date +%s%N)
        local duration=$(((end_time - start_time) / 1000000))  # Convert to ms
        
        total_time=$((total_time + duration))
        
        if [[ $duration -lt $min_time ]]; then
            min_time=$duration
        fi
        
        if [[ $duration -gt $max_time ]]; then
            max_time=$duration
        fi
    done
    
    local avg_time=$((total_time / iterations))
    
    result_ref["script"]="$script_file"
    result_ref["iterations"]=$iterations
    result_ref["total_ms"]=$total_time
    result_ref["avg_ms"]=$avg_time
    result_ref["min_ms"]=$min_time
    result_ref["max_ms"]=$max_time
    
    echo "Benchmark results for $script_file:"
    echo "Iterations: $iterations"
    echo "Total time: ${total_time}ms"
    echo "Average: ${avg_time}ms"
    echo "Min: ${min_time}ms"
    echo "Max: ${max_time}ms"
}

# Development server
dev_server() {
    local port="${1:-8080}"
    local watch_dir="${2:-.}"
    local command="${3:-echo 'File changed'}"
    
    echo "Development server started on port $port"
    echo "Watching directory: $watch_dir"
    echo "Command: $command"
    echo "Press Ctrl+C to stop"
    echo
    
    while true; do
        if command -v inotifywait >/dev/null 2>&1; then
            inotifywait -r -e modify,create,delete "$watch_dir" 2>/dev/null
            echo "Files changed. Running command..."
            eval "$command"
        else
            # Fallback to simple polling
            sleep 2
            echo "Polling for changes..."
            eval "$command"
        fi
    done
}

# Development server (for compatibility)
dev_server_compat() {
    local port="${1:-8080}"
    local watch_dir="${2:-.}"
    local command="${3:-bash}"
    
    echo "Development Server"
    echo "Port: $port"
    echo "Watch directory: $watch_dir"
    echo "Command: $command"
    echo "$(repeat_str "=" 40)"
    
    # Simple file watcher (requires inotify-tools)
    if command -v inotifywait > /dev/null; then
        while true; do
            echo "Watching for changes..."
            inotifywait -r -e modify,create,delete "$watch_dir" 2>/dev/null
            echo "Files changed. Restarting..."
            eval "$command"
        done
    else
        echo "inotifywait not found. Install inotify-tools for file watching."
        echo "Running command once..."
        eval "$command"
    fi
}

# Export module functions
export_module devtools \
    enable_debug disable_debug debug_log breakpoint set_breakpoint remove_breakpoint list_breakpoints debug_prompt \
    watch_variable trace_function untrace_function \
    enable_profile disable_profile generate_profile_report profile_function profile_function_compat profile_memory \
    analyze_script analyze_code check_syntax format_code format_code_compat lint_script lint_code benchmark_script \
    get_memory_usage monitor_performance \
    dev_server dev_server_compat