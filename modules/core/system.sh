#!/bin/bash

# Core System Module
# Provides system utilities, environment management, and error handling

module_version core.system 1.0.0

# System information functions
get_os() {
    if command -v uname > /dev/null; then
        uname -s
    else
        echo "unknown"
    fi
}

get_arch() {
    if command -v uname > /dev/null; then
        uname -m
    else
        echo "unknown"
    fi
}

get_kernel_version() {
    if command -v uname > /dev/null; then
        uname -r
    else
        echo "unknown"
    fi
}

get_hostname() {
    if command -v hostname > /dev/null; then
        hostname
    else
        echo "unknown"
    fi
}

get_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$ID"
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        echo "$DISTRIB_ID"
    else
        echo "unknown"
    fi
}

get_distro_version() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$VERSION_ID"
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        echo "$DISTRIB_RELEASE"
    else
        echo "unknown"
    fi
}

# Process management
get_pid() {
    echo $$
}

get_ppid() {
    echo $PPID
}

is_process_running() {
    local pid="$1"
    [[ -n "$pid" && -d "/proc/$pid" ]]
}

kill_process() {
    local pid="$1"
    local signal="${2:-TERM}"
    
    if is_process_running "$pid"; then
        kill -"$signal" "$pid" 2>/dev/null
        return $?
    else
        return 1
    fi
}

wait_for_process() {
    local pid="$1"
    local timeout="${2:-30}"
    
    if ! is_process_running "$pid"; then
        return 1
    fi
    
    local count=0
    while is_process_running "$pid" && [[ $count -lt $timeout ]]; do
        sleep 1
        ((count++))
    done
    
    ! is_process_running "$pid"
}

# Environment utilities
set_env() {
    local key="$1"
    local value="$2"
    export "$key"="$value"
}

get_env() {
    local key="$1"
    local default="${2:-}"
    echo "${!key:-$default}"
}

unset_env() {
    local key="$1"
    unset "$key" 2>/dev/null || true
}

has_env() {
    local key="$1"
    [[ -n "${!key:-}" ]]
}

# Path utilities
add_to_path() {
    local dir="$1"
    local position="${2:-append}"  # append or prepend
    
    if [[ -d "$dir" && ":$PATH:" != *":$dir:"* ]]; then
        if [[ "$position" == "prepend" ]]; then
            export PATH="$dir:$PATH"
        else
            export PATH="$PATH:$dir"
        fi
    fi
}

remove_from_path() {
    local dir="$1"
    local new_path
    
    new_path=$(echo "$PATH" | tr ':' '\n' | grep -v "^$dir$" | tr '\n' ':' | sed 's/:$//')
    export PATH="$new_path"
}

path_contains() {
    local dir="$1"
    [[ ":$PATH:" == *":$dir:"* ]]
}

join_path() {
    echo "$1/$2" | sed 's|//*|/|g'
}

realpath() {
    if command -v readlink > /dev/null; then
        readlink -f "$1"
    else
        echo "$1"
    fi
}

is_absolute() {
    [[ "$1" = /* ]]
}

# User information
get_user() {
    echo "${USER:-$(whoami 2>/dev/null || echo unknown)}"
}

get_home() {
    echo "${HOME:-$(getent passwd "$(get_user)" | cut -d: -f6)}"
}

get_shell() {
    echo "${SHELL:-$(getent passwd "$(get_user)" | cut -d: -f7)}"
}

is_root() {
    [[ $EUID -eq 0 ]]
}

# System resources
get_cpu_count() {
    if command -v nproc > /dev/null; then
        nproc
    elif [[ -f /proc/cpuinfo ]]; then
        grep -c "^processor" /proc/cpuinfo
    else
        echo "1"
    fi
}

get_memory_total() {
    if [[ -f /proc/meminfo ]]; then
        awk '/MemTotal/ {print $2}' /proc/meminfo
    else
        echo "0"
    fi
}

get_memory_available() {
    if [[ -f /proc/meminfo ]]; then
        awk '/MemAvailable/ {print $2}' /proc/meminfo
    else
        echo "0"
    fi
}

get_disk_usage() {
    local path="${1:-.}"
    if command -v df > /dev/null; then
        df -h "$path" | tail -1 | awk '{print $5}'
    else
        echo "unknown"
    fi
}

# System load
get_load_average() {
    if [[ -f /proc/loadavg ]]; then
        awk '{print $1}' /proc/loadavg
    elif command -v uptime > /dev/null; then
        uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | tr -d ' '
    else
        echo "0"
    fi
}

# Time utilities
get_timestamp() {
    date +%s
}

get_timestamp_ms() {
    if command -v date > /dev/null; then
        date +%s%3N 2>/dev/null || date +%s
    else
        date +%s
    fi
}

format_timestamp() {
    local timestamp="$1"
    local format="${2:-%Y-%m-%d %H:%M:%S}"
    date -d "@$timestamp" +"$format" 2>/dev/null || date -r "$timestamp" +"$format" 2>/dev/null || echo "invalid timestamp"
}

get_uptime() {
    if [[ -f /proc/uptime ]]; then
        awk '{print $1}' /proc/uptime
    elif command -v uptime > /dev/null; then
        uptime | awk -F'up ' '{print $2}' | cut -d',' -f1
    else
        echo "unknown"
    fi
}

timestamp() {
    get_timestamp
}

timestamp_ms() {
    get_timestamp_ms
}

format_time() {
    format_timestamp "$1" "$2"
}

# File descriptors
get_fd_count() {
    local pid="${1:-$$}"
    if [[ -d "/proc/$pid/fd" ]]; then
        find "/proc/$pid/fd" -type l 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

get_fd_limit() {
    if command -v ulimit > /dev/null; then
        ulimit -n
    else
        echo "unknown"
    fi
}

# Signal handling
trap_signal() {
    local signal="$1"
    local handler="$2"
    
    trap "$handler" "$signal"
}

ignore_signal() {
    local signal="$1"
    trap "" "$signal"
}

default_signal() {
    local signal="$1"
    trap - "$signal"
}

# System checks
command_exists() {
    command -v "$1" > /dev/null 2>&1
}

is_interactive() {
    [[ -t 0 && -n "$PS1" ]]
}

is_script() {
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

has_color_support() {
    [[ -t 1 && -n "${TERM:-}" ]] && command_exists tput && tput colors > /dev/null 2>&1
}

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_FAILURE=1
readonly EXIT_INVALID_ARGS=2
readonly EXIT_FILE_NOT_FOUND=3
readonly EXIT_PERMISSION_DENIED=4
readonly EXIT_NETWORK_ERROR=5

# Error handling utilities
die() {
    local message="$1"
    local exit_code="${2:-1}"
    echo "Fatal: $message" >&2
    exit "$exit_code"
}

assert() {
    local condition="$1"
    local message="${2:-Assertion failed}"
    
    if ! eval "$condition"; then
        die "$message" 2
    fi
}

# Logging utilities with timestamps
log_info() {
    local message="$1"
    local timestamp=$(format_timestamp "$(get_timestamp)" "%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] INFO: $message"
}

log_warn() {
    local message="$1"
    local timestamp=$(format_timestamp "$(get_timestamp)" "%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] WARN: $message" >&2
}

log_error() {
    local message="$1"
    local timestamp=$(format_timestamp "$(get_timestamp)" "%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] ERROR: $message" >&2
}

log_debug() {
    local message="$1"
    if [[ "${DEBUG:-0}" == "1" ]]; then
        local timestamp=$(format_timestamp "$(get_timestamp)" "%Y-%m-%d %H:%M:%S")
        echo "[$timestamp] DEBUG: $message" >&2
    fi
}

# System status summary
system_status() {
    echo "=== System Status ==="
    echo "OS: $(get_os) $(get_arch)"
    echo "Distro: $(get_distro) $(get_distro_version)"
    echo "Kernel: $(get_kernel_version)"
    echo "Hostname: $(get_hostname)"
    echo "User: $(get_user)$(is_root && echo " (root)" || echo "")"
    echo "Shell: $(get_shell)"
    echo "CPU Cores: $(get_cpu_count)"
    echo "Memory: $(get_memory_available)KB available / $(get_memory_total)KB total"
    echo "Load: $(get_load_average)"
    echo "Uptime: $(get_uptime)"
    echo "Timestamp: $(format_timestamp "$(get_timestamp)")"
    echo "FDs: $(get_fd_count)/$(get_fd_limit)"
    echo "Color Support: $(has_color_support && echo "yes" || echo "no")"
    echo "Interactive: $(is_interactive && echo "yes" || echo "no")"
}

# Export module functions
export_module core.system \
    get_os get_arch get_kernel_version get_hostname get_distro get_distro_version \
    get_pid get_ppid is_process_running kill_process wait_for_process \
    set_env get_env unset_env has_env \
    add_to_path remove_from_path path_contains join_path realpath is_absolute \
    get_user get_home get_shell is_root \
    get_cpu_count get_memory_total get_memory_available get_disk_usage \
    get_load_average get_timestamp get_timestamp_ms format_timestamp get_uptime timestamp timestamp_ms format_time \
    get_fd_count get_fd_limit \
    trap_signal ignore_signal default_signal \
    command_exists is_interactive is_script has_color_support \
    die assert \
    log_info log_warn log_error log_debug \
    system_status