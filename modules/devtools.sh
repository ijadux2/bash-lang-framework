#!/usr/bin/bash

# Development Tools - Debugger, profiler, and development utilities
module_version "devtools" "1.0.0"

# Debug state
declare -g DEBUG_ENABLED=0
declare -g DEBUG_LEVEL=1
declare -g DEBUG_FILE=""
declare -g DEBUG_BREAKPOINTS=()

# Enable debugging
enable_debug() {
    DEBUG_ENABLED=1
    DEBUG_LEVEL="${1:-1}"
    DEBUG_FILE="${2:-debug.log}"
    
    echo "Debug enabled (level: $DEBUG_LEVEL, log: $DEBUG_FILE)"
}

# Disable debugging
disable_debug() {
    DEBUG_ENABLED=0
    echo "Debug disabled"
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

# Breakpoint
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

# Profiler
declare -g PROFILER_ENABLED=0
declare -g PROFILER_DATA=()
declare -g PROFILER_START_TIME=0

enable_profiler() {
    PROFILER_ENABLED=1
    PROFILER_START_TIME=$(date +%s.%N)
    echo "Profiler enabled"
}

disable_profiler() {
    PROFILER_ENABLED=0
    echo "Profiler disabled"
}

profile_function() {
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

# Memory usage
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
    echo "$(repeat 40 "-")"
    
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

# Code analyzer
analyze_code() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return 1
    fi
    
    echo "Code Analysis for: $file"
    echo "$(repeat 50 "=")"
    
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
    echo "$(repeat 30 "-")"
    grep -n "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*(" "$file" | while read -r line; do
        local line_num=$(echo "$line" | cut -d':' -f1)
        local func_def=$(echo "$line" | cut -d':' -f2-)
        echo "  $line_num: $func_def"
    done
    echo
    
    # Potential issues
    echo "Potential Issues:"
    echo "$(repeat 30 "-")"
    
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

# Code formatter
format_code() {
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

# Linter
lint_code() {
    local file="$1"
    local errors=0
    
    echo "Linting: $file"
    echo "$(repeat 40 "=")"
    
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

# Development server
dev_server() {
    local port="${1:-8080}"
    local watch_dir="${2:-.}"
    local command="${3:-bash}"
    
    echo "Development Server"
    echo "Port: $port"
    echo "Watch directory: $watch_dir"
    echo "Command: $command"
    echo "$(repeat 40 "=")"
    
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

# Export functions
export_module "devtools" enable_debug disable_debug debug_log breakpoint enable_profiler disable_profiler profile_function get_memory_usage monitor_performance analyze_code format_code lint_code dev_server