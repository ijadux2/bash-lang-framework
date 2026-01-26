#!/usr/bin/bash

# IO Module - Input/Output utilities
module_version "io" "1.0.0"

# File operations
read_file() { cat "$1"; }
write_file() { echo "$2" > "$1"; }
append_file() { echo "$2" >> "$1"; }
exists() { [[ -f "$1" ]]; }
is_dir() { [[ -d "$1" ]]; }

# Directory operations
mkdir_p() { mkdir -p "$1"; }
list_files() { find "$1" -maxdepth 1 -type f | sort; }
list_dirs() { find "$1" -maxdepth 1 -type d | sort; }

# User input
prompt() {
    local message="$1"
    local default="$2"
    local var_name="$3"
    
    if [[ -n "$default" ]]; then
        read -p "$message [$default]: " input
        input="${input:-$default}"
    else
        read -p "$message: " input
    fi
    
    if [[ -n "$var_name" ]]; then
        printf -v "$var_name" '%s' "$input"
    else
        echo "$input"
    fi
}

confirm() {
    local message="$1"
    local default="${2:-n}"
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$message [Y/n]: " response
            response="${response:-y}"
        else
            read -p "$message [y/N]: " response
            response="${response:-n}"
        fi
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# Menu selection
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

# Progress bar
progress_bar() {
    local current=$1 total=$2 width="${3:-50}"
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%*s" "$filled" | tr ' ' '='
    printf "%*s" "$empty" | tr ' ' '-'
    printf "] %d%% (%d/%d)" "$percent" "$current" "$total"
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# Color output
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

# Table formatting
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

# Export functions
export_module "io" read_file write_file append_file exists is_dir mkdir_p list_files list_dirs prompt confirm menu progress_bar color table