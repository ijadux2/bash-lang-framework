#!/usr/bin/bash

# Core System Module - Essential system utilities
module_version "core.system" "1.0.0"

# System information
get_os() { uname -s; }
get_arch() { uname -m; }
get_kernel() { uname -r; }
get_hostname() { hostname; }

# Process management
get_pid() { echo $$; }
get_ppid() { echo $PPID; }
is_process_running() { ps -p "$1" > /dev/null 2>&1; }

# Environment utilities
get_env() { echo "${!1}"; }
set_env() { export "$1=$2"; }
unset_env() { unset "$1"; }

# Path utilities
join_path() { echo "$1/$2" | sed 's|//*|/|g'; }
realpath() { readlink -f "$1"; }
is_absolute() { [[ "$1" = /* ]]; }

# Time utilities
timestamp() { date +%s; }
timestamp_ms() { date +%s%3N; }
format_time() { date -d "@$1" "$2"; }

# Exit codes
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_INVALID_ARGS=2
EXIT_FILE_NOT_FOUND=3
EXIT_PERMISSION_DENIED=4
EXIT_NETWORK_ERROR=5

# Error handling
error() { echo "Error: $*" >&2; return "${EXIT_FAILURE}"; }
fatal() { echo "Fatal: $*" >&2; exit "${EXIT_FAILURE}"; }
warn() { echo "Warning: $*" >&2; }
info() { echo "Info: $*"; }

# Debug utilities
debug() { [[ "${DEBUG:-0}" == "1" ]] && echo "Debug: $*" >&2; }
assert() {
    if ! eval "$1"; then
        fatal "Assertion failed: $1"
    fi
}

# Export functions
export_module "core.system" get_os get_arch get_kernel get_hostname get_pid get_ppid is_process_running get_env set_env unset_env join_path realpath is_absolute timestamp timestamp_ms format_time error fatal warn info debug assert