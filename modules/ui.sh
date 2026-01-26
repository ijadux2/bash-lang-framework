#!/usr/bin/bash

# UI/Theme Module - User interface and theming system
module_version "ui" "1.0.0"

# Initialize UI_COLORS if not already defined
if [[ ${#UI_COLORS[@]} -eq 0 ]]; then
    declare -A UI_COLORS=(
        ["reset"]="\033[0m"
        ["black"]="\033[30m"
        ["red"]="\033[31m"
        ["green"]="\033[32m"
        ["yellow"]="\033[33m"
        ["blue"]="\033[34m"
        ["magenta"]="\033[35m"
        ["cyan"]="\033[36m"
        ["white"]="\033[37m"
        ["bright_black"]="\033[90m"
        ["bright_red"]="\033[91m"
        ["bright_green"]="\033[92m"
        ["bright_yellow"]="\033[93m"
        ["bright_blue"]="\033[94m"
        ["bright_magenta"]="\033[95m"
        ["bright_cyan"]="\033[96m"
        ["bright_white"]="\033[97m"
        ["bg_black"]="\033[40m"
        ["bg_red"]="\033[41m"
        ["bg_green"]="\033[42m"
        ["bg_yellow"]="\033[43m"
        ["bg_blue"]="\033[44m"
        ["bg_magenta"]="\033[45m"
        ["bg_cyan"]="\033[46m"
        ["bg_white"]="\033[47m"
    )
fi

# Initialize UI_STYLES if not already defined
if [[ ${#UI_STYLES[@]} -eq 0 ]]; then
    declare -A UI_STYLES=(
        ["reset"]="\033[0m"
        ["bold"]="\033[1m"
        ["dim"]="\033[2m"
        ["italic"]="\033[3m"
        ["underline"]="\033[4m"
        ["blink"]="\033[5m"
        ["reverse"]="\033[7m"
        ["hidden"]="\033[8m"
        ["strikethrough"]="\033[9m"
    )
fi

# Initialize CURRENT_THEME if not already defined
if [[ ${#CURRENT_THEME[@]} -eq 0 ]]; then
    declare -A CURRENT_THEME=(
        ["primary"]="blue"
        ["secondary"]="green"
        ["accent"]="yellow"
        ["success"]="green"
        ["warning"]="yellow"
        ["error"]="red"
        ["info"]="cyan"
        ["background"]="bg_black"
        ["text"]="white"
    )
fi

# Initialize THEMES if not already defined
if [[ ${#THEMES[@]} -eq 0 ]]; then
    declare -A THEMES=(
        ["default"]="primary:blue,secondary:green,accent:yellow,success:green,warning:yellow,error:red,info:cyan,background:bg_black,text:white"
        ["dark"]="primary:bright_blue,secondary:bright_green,accent:bright_yellow,success:bright_green,warning:bright_yellow,error:bright_red,info:bright_cyan,background:bg_black,text:bright_white"
        ["light"]="primary:black,secondary:bright_green,accent:blue,success:green,warning:yellow,error:red,info:blue,background:bg_white,text:black"
        ["neon"]="primary:bright_magenta,secondary:bright_cyan,accent:bright_yellow,success:bright_green,warning:bright_yellow,error:bright_red,info:bright_cyan,background:bg_black,text:bright_white"
        ["retro"]="primary:green,secondary:green,accent:yellow,success:green,warning:yellow,error:red,info:cyan,background:bg_black,text:green"
    )
fi

# Set theme
set_theme() {
    local theme_name="$1"
    
    if [[ -z "$theme_name" ]]; then
        theme_name="default"
    fi
    
    if [[ -n "${THEMES[$theme_name]}" ]]; then
        local theme_config="${THEMES[$theme_name]}"
        IFS=',' read -ra theme_parts <<< "$theme_config"
        
        for part in "${theme_parts[@]}"; do
            IFS=':' read -r key value <<< "$part"
            CURRENT_THEME[$key]="$value"
        done
        
        info "Theme set to: $theme_name"
    else
        error "Unknown theme: $theme_name"
        return 1
    fi
}

# Get color code
get_color() {
    local name="$1"
    local style="$2"
    
    local color_code="${UI_COLORS[$name]:-${CURRENT_THEME[$name]}}"
    local style_code="${UI_STYLES[$style]:-}"
    
    echo "${style_code}${color_code}"
}

# Print colored text
printc() {
    local color="$1"
    local style="$2"
    local text="$3"
    
    local color_code
    color_code=$(get_color "$color" "$style")
    
    echo -e "${color_code}${text}${UI_COLORS[reset]}"
}

# Theme-aware message functions
themsg() {
    local type="$1"
    local message="$2"
    local prefix="$3"
    
    local color="${CURRENT_THEME[$type]}"
    local timestamp
    timestamp=$(date "+%H:%M:%S")
    
    local full_message="[$timestamp] ${prefix:-[$type]} $message"
    printc "$color" "bold" "$full_message"
}

success() { themsg "success" "$1" "✓"; }
warning() { themsg "warning" "$1" "⚠"; }
error_msg() { themsg "error" "$1" "✗"; }
info_msg() { themsg "info" "$1" "ℹ"; }

# UI Components
header() {
    local title="$1"
    local width="${2:-60}"
    local color="${3:-primary}"
    
    local padding=$(( (width - ${#title}) / 2 ))
    local line
    line=$(repeat "$width" "─")
    
    printc "$color" "bold" "$line"
    printc "$color" "bold" "$(printf "%*s" "$padding")$title"
    printc "$color" "bold" "$line"
}

footer() {
    local text="$1"
    local width="${2:-60}"
    local color="${3:-secondary}"
    
    printf "%${width}s" "" | tr ' ' '─'
    printc "$color" "dim" " $text "
}

separator() {
    local char="${1:-─}"
    local length="${2:-60}"
    local color="${3:-accent}"
    
    printc "$color" "dim" "$(repeat "$length" "$char")"
}

# Progress bar with theme
themed_progress_bar() {
    local current=$1 total=$2 width="${3:-50}" label="${4:-}"
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    local progress_bar="["
    progress_bar+=$(printf "%*s" "$filled" | tr ' ' '█')
    progress_bar+=$(printf "%*s" "$empty" | tr ' ' '░')
    progress_bar+="]"
    
    if [[ -n "$label" ]]; then
        local label_width=$((width - ${#label} - 5))
        printf "\r%s %-*s %d%% (%d/%d)" "$label" "$label_width" "$progress_bar" "$percent" "$current" "$total"
    else
        printf "\r%s %d%% (%d/%d)" "$progress_bar" "$percent" "$current" "$total"
    fi
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# Interactive menu with theme
themed_menu() {
    local title="$1"
    shift
    local options=("$@")
    local color="${CURRENT_THEME[primary]}"
    
    printc "$color" "bold" "$title"
    printc "$color" "dim" "$(repeat ${#title} "─")"
    echo
    
    for i in "${!options[@]}"; do
        local option_num=$((i+1))
        local option_text="${options[$i]}"
        
        printc "$color" "bold" "[$option_num]"
        echo -e " $option_text"
    done
    
    echo
    
    while true; do
        printc "$color" "bold" "Select an option (1-${#options[@]}): "
        read -r choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#options[@]} ]]; then
            echo "${options[$((choice-1))]}"
            return $((choice-1))
        else
            error_msg "Invalid selection. Please try again."
        fi
    done
}

# Confirmation dialog with theme
themed_confirm() {
    local message="$1"
    local default="${2:-n}"
    local color="${CURRENT_THEME[warning]}"
    
    while true; do
        if [[ "$default" == "y" ]]; then
            printc "$color" "bold" "$message [Y/n]: "
            read -r response
            response="${response:-y}"
        else
            printc "$color" "bold" "$message [y/N]: "
            read -r response
            response="${response:-n}"
        fi
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) 
                success "Yes"
                return 0
                ;;
            [Nn]|[Nn][Oo]) 
                error_msg "No"
                return 1
                ;;
            *) 
                warning "Please answer yes or no."
                ;;
        esac
    done
}

# Input prompt with theme
themed_prompt() {
    local message="$1"
    local default="$2"
    local color="${CURRENT_THEME[info]}"
    
    if [[ -n "$default" ]]; then
        printc "$color" "bold" "$message [$default]: "
        read -r input
        input="${input:-$default}"
    else
        printc "$color" "bold" "$message: "
        read -r input
    fi
    
    echo "$input"
}

# Table with theme
themed_table() {
    local -a headers=("$1")
    shift
    local -a rows=("$@")
    local header_color="${CURRENT_THEME[primary]}"
    local border_color="${CURRENT_THEME[accent]}"
    
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
        header_line+="$(printf "%-${widths[$i]}s" "${headers[$i]}") │ "
    done
    printc "$header_color" "bold" "${header_line% │ }"
    
    # Print separator
    local separator_line
    for i in "${!widths[@]}"; do
        separator_line+="$(printf "%-${widths[$i]}s" "" | tr ' ' '─')──┼"
    done
    printc "$border_color" "dim" "${separator_line%──┼}"
    
    # Print rows
    local row_color="${CURRENT_THEME[text]}"
    for row in "${rows[@]}"; do
        IFS='|' read -ra cols <<< "$row"
        local row_line
        for i in "${!cols[@]}"; do
            row_line+="$(printf "%-${widths[$i]}s" "${cols[$i]}") │ "
        done
        printc "$row_color" "normal" "${row_line% │ }"
    done
}

# Box with theme
box() {
    local text="$1"
    local width="${2:-60}"
    local color="${3:-primary}"
    
    # Create box
    local top_bottom="┌$(printf "%*s" $((width - 2)) | tr ' ' '─')┐"
    local padding=$(( (width - ${#text} - 4) / 2 ))
    local middle="│$(printf "%*s" $padding) $text $(printf "%*s" $padding)│"
    
    printc "$color" "bold" "$top_bottom"
    printc "$color" "normal" "$middle"
    printc "$color" "bold" "$top_bottom"
}

# List available themes
list_themes() {
    info "Available themes:"
    for theme in "${!THEMES[@]}"; do
        echo "  • $theme"
    done
}

# Get current theme info
current_theme_info() {
    info "Current theme configuration:"
    for key in "${!CURRENT_THEME[@]}"; do
        local value="${CURRENT_THEME[$key]}"
        local color_code
        color_code=$(get_color "$value")
        echo "  $key: ${color_code}${value}${UI_COLORS[reset]}"
    done
}

# Initialize default theme
set_theme "default"

# Export functions
export_module "ui" set_theme get_color printc success warning error_msg info_msg header footer separator themed_progress_bar themed_menu themed_confirm themed_prompt themed_table box list_themes current_theme_info