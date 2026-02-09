#!/bin/bash

# I/O Module
# Provides file operations, user input, and data formatting utilities

module_version io 1.0.0

# File reading operations
read_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ ! -r "$file" ]]; then
        error "File not readable: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    cat "$file"
}

read_lines() {
    local file="$1"
    local -n result_ref="$2"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    mapfile -t result_ref < "$file"
}

read_line() {
    local file="$1"
    local line_num="$2"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    sed -n "${line_num}p" "$file"
}

read_first_line() {
    local file="$1"
    head -n 1 "$file"
}

read_last_line() {
    local file="$1"
    tail -n 1 "$file"
}

# File writing operations
write_file() {
    local file="$1"
    local content="$2"
    local mode="${3:-overwrite}"  # overwrite, append, prepend
    
    local dir
    dir=$(dirname "$file")
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            error "Cannot create directory: $dir"
            return ${EXIT_FAILURE:-1}
        }
    fi
    
    case "$mode" in
        "overwrite")
            echo "$content" > "$file"
            ;;
        "append")
            echo "$content" >> "$file"
            ;;
        "prepend")
            local temp_file=$(mktemp)
            echo "$content" > "$temp_file"
            cat "$file" >> "$temp_file" 2>/dev/null || true
            mv "$temp_file" "$file"
            ;;
        *)
            error "Invalid write mode: $mode"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
}

append_file() {
    local file="$1"
    local content="$2"
    write_file "$file" "$content" "append"
}

prepend_file() {
    local file="$1"
    local content="$2"
    write_file "$file" "$content" "prepend"
}

# File existence and properties
file_exists() {
    local file="$1"
    [[ -f "$file" ]]
}

exists() {
    file_exists "$@"
}

dir_exists() {
    local dir="$1"
    [[ -d "$dir" ]]
}

is_dir() {
    dir_exists "$@"
}

is_readable() {
    local file="$1"
    [[ -r "$file" ]]
}

is_writable() {
    local file="$1"
    [[ -w "$file" ]]
}

is_executable() {
    local file="$1"
    [[ -x "$file" ]]
}

get_file_size() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

get_file_lines() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        wc -l < "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Directory operations
mkdir_p() {
    local dir="$1"
    mkdir -p "$dir"
}

list_files() {
    local dir="$1"
    find "$dir" -maxdepth 1 -type f | sort
}

list_dirs() {
    local dir="$1"
    find "$dir" -maxdepth 1 -type d | sort
}

# User input functions
prompt() {
    local message="$1"
    local default="${2:-}"
    local -n result_ref="$3"
    
    if [[ -n "$default" ]]; then
        read -p "$message [$default]: " result_ref
        if [[ -z "${result_ref}" ]]; then
            result_ref="$default"
        fi
    else
        read -p "$message: " result_ref
    fi
}

prompt_yes_no() {
    local message="$1"
    local default="${2:-n}"
    local -n result_ref="$3"
    local response
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$message [Y/n]: " response
            response="${response:-y}"
        else
            read -p "$message [y/N]: " response
            response="${response:-n}"
        fi
        
        case "${response,,}" in
            y|yes)
                result_ref="yes"
                return 0
                ;;
            n|no)
                result_ref="no"
                return 0
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

confirm() {
    local message="$1"
    local default="${2:-n}"
    local response
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$message [Y/n]: " response
            response="${response:-y}"
        else
            read -p "$message [y/N]: " response
            response="${response:-n}"
        fi
        
        case "${response,,}" in
            y|yes)
                return 0
                ;;
            n|no)
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

prompt_password() {
    local message="$1"
    local -n result_ref="$2"
    
    read -s -p "$message: " result_ref
    echo
}

prompt_choice() {
    local message="$1"
    shift
    local -n result_ref="$1"
    shift
    local choices=("$@")
    local choice
    
    while true; do
        echo "$message:"
        for i in "${!choices[@]}"; do
            echo "  $((i + 1))) ${choices[$i]}"
        done
        
        read -p "Enter choice [1-${#choices[@]}]: " choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#choices[@]} ]]; then
            result_ref="${choices[$((choice - 1))]}"
            return 0
        else
            echo "Invalid choice. Please try again."
        fi
    done
}

menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo "$title"
    echo "--------"
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[$i]}"
    done
    
    while true; do
        read -p "Select an option (1-${#options[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#options[@]} ]]; then
            echo "${options[$((choice-1))]}"
            return $((choice-1))
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

prompt_multiline() {
    local message="$1"
    local -n result_ref="$2"
    local line
    local lines=()
    
    echo "$message (enter empty line to finish):"
    while true; do
        read -p "> " line
        if [[ -z "$line" ]]; then
            break
        fi
        lines+=("$line")
    done
    
    result_ref=$(printf '%s\n' "${lines[@]}")
}

# Input validation
validate_input() {
    local input="$1"
    local pattern="$2"
    local error_msg="${3:-Invalid input}"
    
    if [[ ! "$input" =~ $pattern ]]; then
        error "$error_msg"
        return ${EXIT_FAILURE:-1}
    fi
    
    return 0
}

validate_number() {
    local input="$1"
    local min="${2:-}"
    local max="${3:-}"
    
    if ! [[ "$input" =~ ^-?[0-9]+$ ]]; then
        error "Please enter a valid number"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ -n "$min" ]] && [[ "$input" -lt "$min" ]]; then
        error "Please enter a number >= $min"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ -n "$max" ]] && [[ "$input" -gt "$max" ]]; then
        error "Please enter a number <= $max"
        return ${EXIT_FAILURE:-1}
    fi
    
    return 0
}

validate_email() {
    local input="$1"
    
    if ! [[ "$input" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        error "Please enter a valid email address"
        return ${EXIT_FAILURE:-1}
    fi
    
    return 0
}

validate_url() {
    local input="$1"
    
    if ! [[ "$input" =~ ^https?://[a-zA-Z0-9.-]+(\.[a-zA-Z]{2,})?(/.*)?$ ]]; then
        error "Please enter a valid URL"
        return ${EXIT_FAILURE:-1}
    fi
    
    return 0
}

# Table formatting
create_table() {
    local -n headers_ref="$1"
    shift
    local -n rows_ref="$1"
    shift
    local -n result_ref="$1"
    local options=("$@")
    
    local column_count=${#headers_ref[@]}
    local col_widths=()
    local border="${options[0]:-1}"
    local padding="${options[1]:-1}"
    
    # Calculate column widths
    for ((i=0; i<column_count; i++)); do
        local max_width=${#headers_ref[$i]}
        
        for row in "${rows_ref[@]}"; do
            local -a row_data
            IFS='|' read -ra row_data <<< "$row"
            if [[ ${#row_data[$i]} -gt $max_width ]]; then
                max_width=${#row_data[$i]}
            fi
        done
        
        col_widths[$i]=$((max_width + 2 * padding))
    done
    
    # Build table
    local table=""
    
    # Top border
    if [[ "$border" == "1" ]]; then
        table+="+"
        for width in "${col_widths[@]}"; do
            table+=$(repeat_str "-" "$width")
            table+="+"
        done
        table+=$'\n'
    fi
    
    # Header row
    table+="|"
    for ((i=0; i<column_count; i++)); do
        local header="${headers_ref[$i]}"
        table+=" $(lpad "$header" $((col_widths[i] - 2)) " ") |"
    done
    table+=$'\n'
    
    # Header separator
    if [[ "$border" == "1" ]]; then
        table+="+"
        for width in "${col_widths[@]}"; do
            table+=$(repeat_str "-" "$width")
            table+="+"
        done
        table+=$'\n'
    fi
    
    # Data rows
    for row in "${rows_ref[@]}"; do
        local -a row_data
        IFS='|' read -ra row_data <<< "$row"
        
        table+="|"
        for ((i=0; i<column_count; i++)); do
            local cell="${row_data[$i]:-}"
            table+=" $(lpad "$cell" $((col_widths[i] - 2)) " ") |"
        done
        table+=$'\n'
    done
    
    # Bottom border
    if [[ "$border" == "1" ]]; then
        table+="+"
        for width in "${col_widths[@]}"; do
            table+=$(repeat_str "-" "$width")
            table+="+"
        done
        table+=$'\n'
    fi
    
    result_ref="$table"
}

print_table() {
    local -n headers_ref="$1"
    shift
    local -n rows_ref="$1"
    shift
    local options=("$@")
    
    local table
    create_table headers_ref rows_ref table options
    echo "$table"
}

table() {
    local -a headers=("$1")
    shift
    local -a rows=("$@")
    
    # Calculate column widths
    local -a widths
    for i in "${!headers[@]}"; do
        widths[$i]=${#headers[$i]}
    done
    
    for row in "${rows[@]}"; do
        IFS='|' read -ra cols <<< "$row"
        for i in "${!cols[@]}"; do
            if [[ ${#cols[$i]} -gt ${widths[$i]} ]]; then
                widths[$i]=${#cols[$i]}
            fi
        done
    done
    
    # Print header
    local header_line
    for i in "${!headers[@]}"; do
        header_line+="$(printf "%-${widths[$i]}s" "${headers[$i]}") | "
    done
    echo "${header_line% | }"
    
    # Print separator
    local separator_line
    for i in "${!widths[@]}"; do
        separator_line+="$(printf "%-${widths[$i]}s" "" | tr ' ' '-')-+"
    done
    echo "${separator_line%-+}"
    
    # Print rows
    for row in "${rows[@]}"; do
        IFS='|' read -ra cols <<< "$row"
        local row_line
        for i in "${!cols[@]}"; do
            row_line+="$(printf "%-${widths[$i]}s" "${cols[$i]}") | "
        done
        echo "${row_line% | }"
    done
}

# Progress bar
show_progress() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local char="${4:-█}"
    local -n result_ref="$5"
    
    if [[ "$total" -eq 0 ]]; then
        result_ref=""
        return
    fi
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    local bar=$(repeat_str "$char" "$filled")
    bar+="$(repeat_str " " "$empty")"
    
    result_ref="[$bar] $percentage% ($current/$total)"
}

progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local char="${4:-█}"
    
    local progress
    show_progress "$current" "$total" "$width" "$char" progress
    echo -ne "\r$progress"
    
    if [[ "$current" -eq "$total" ]]; then
        echo
    fi
}

# Spinner animation
start_spinner() {
    local message="${1:-Loading...}"
    local -n spinner_ref="$2"
    local chars="|/-\\"
    local delay=0.1
    
    spinner_ref=0
    while true; do
        local char="${chars:$spinner_ref:1}"
        echo -ne "\r$message $char"
        spinner_ref=$(((spinner_ref + 1) % 4))
        sleep "$delay"
    done
}

stop_spinner() {
    local -n spinner_ref="$1"
    local message="${2:-Done}"
    
    if [[ -n "${spinner_ref:-}" ]]; then
        kill "$spinner_ref" 2>/dev/null || true
        wait "$spinner_ref" 2>/dev/null || true
    fi
    
    echo -ne "\r$message\n"
}

# Color output (if available)
color_text() {
    local text="$1"
    local color="$2"
    local -n result_ref="$3"
    
    if has_color_support; then
        local color_code
        case "${color,,}" in
            "black") color_code="30" ;;
            "red") color_code="31" ;;
            "green") color_code="32" ;;
            "yellow") color_code="33" ;;
            "blue") color_code="34" ;;
            "magenta") color_code="35" ;;
            "cyan") color_code="36" ;;
            "white") color_code="37" ;;
            "reset") color_code="0" ;;
            *) color_code="0" ;;
        esac
        result_ref="\033[${color_code}m${text}\033[0m"
    else
        result_ref="$text"
    fi
}

print_color() {
    local text="$1"
    local color="$2"
    local colored
    
    color_text "$text" "$color" colored
    echo -e "$colored"
}

color() {
    local color="$1"
    local text="$2"
    local reset="\033[0m"
    
    case "$color" in
        red) echo -e "\033[31m${text}${reset}" ;;
        green) echo -e "\033[32m${text}${reset}" ;;
        yellow) echo -e "\033[33m${text}${reset}" ;;
        blue) echo -e "\033[34m${text}${reset}" ;;
        magenta) echo -e "\033[35m${text}${reset}" ;;
        cyan) echo -e "\033[36m${text}${reset}" ;;
        white) echo -e "\033[37m${text}${reset}" ;;
        bold) echo -e "\033[1m${text}${reset}" ;;
        underline) echo -e "\033[4m${text}${reset}" ;;
        *) echo "$text" ;;
    esac
}

# File backup and restore
backup_file() {
    local file="$1"
    local backup_dir="${2:-./backups}"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_name="$(basename "$file").$timestamp.bak"
    local backup_path="$backup_dir/$backup_name"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    mkdir -p "$backup_dir" || {
        error "Cannot create backup directory: $backup_dir"
        return ${EXIT_FAILURE:-1}
    }
    
    cp "$file" "$backup_path" || {
        error "Cannot create backup: $backup_path"
        return ${EXIT_FAILURE:-1}
    }
    
    echo "Backup created: $backup_path"
    return 0
}

restore_file() {
    local backup="$1"
    local target="${2:-}"
    
    if [[ ! -f "$backup" ]]; then
        error "Backup file not found: $backup"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ -z "$target" ]]; then
        # Remove timestamp and .bak extension
        target=$(basename "$backup" | sed 's/\.[0-9]\{8\}_[0-9]\{6\}\.bak$//')
    fi
    
    cp "$backup" "$target" || {
        error "Cannot restore file: $target"
        return ${EXIT_FAILURE:-1}
    }
    
    echo "File restored: $target"
    return 0
}

# Export module functions
export_module io \
    read_file read_lines read_line read_first_line read_last_line \
    write_file append_file prepend_file \
    file_exists exists dir_exists is_dir is_readable is_writable is_executable \
    get_file_size get_file_lines \
    mkdir_p list_files list_dirs \
    prompt prompt_yes_no confirm prompt_password prompt_choice menu prompt_multiline \
    validate_input validate_number validate_email validate_url \
    create_table print_table table \
    show_progress progress_bar \
    start_spinner stop_spinner \
    color_text print_color color \
    backup_file restore_file