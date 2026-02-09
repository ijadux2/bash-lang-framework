#!/bin/bash

# UI Module
# Provides theming system and interactive UI components

module_version ui 1.0.0

# Color definitions
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
    ["bold"]="\033[1m"
    ["dim"]="\033[2m"
    ["underline"]="\033[4m"
    ["blink"]="\033[5m"
    ["reverse"]="\033[7m"
    ["hidden"]="\033[8m"
)

# Style definitions
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

# Theme definitions
declare -A THEMES=(
    ["default"]="primary=blue|secondary=cyan|success=green|warning=yellow|danger=red|info=white|bg_default=black|text_default=white"
    ["dark"]="primary=bright_blue|secondary=bright_cyan|success=bright_green|warning=bright_yellow|danger=bright_red|info=bright_white|bg_default=black|text_default=white"
    ["light"]="primary=blue|secondary=cyan|success=green|warning=yellow|danger=red|info=black|bg_default=white|text_default=black"
    ["neon"]="primary=bright_magenta|secondary=bright_cyan|success=bright_green|warning=bright_yellow|danger=bright_red|info=bright_white|bg_default=black|text_default=bright_white"
    ["retro"]="primary=yellow|secondary=cyan|success=green|warning=red|danger=magenta|info=white|bg_default=black|text_default=green"
)

# ASCII art themes
declare -A ASCII_THEMES=(
    ["default"]="header=╔═══╗|footer=╚═══╝|border=║|corner_tl=╔|corner_tr=╗|corner_bl=╚|corner_br=╝|h_border=═|v_border=║|cross=╬|t_cross=╦|b_cross=╩|l_cross=╠|r_cross=╣"
    ["rounded"]="header=╭────╮|footer=╰────╯|border=│|corner_tl=╭|corner_tr=╮|corner_bl=╰|corner_br=╯|h_border=─|v_border=│|cross=┼|t_cross=┬|b_cross=┴|l_cross=├|r_cross=┤"
    ["double"]="header=╔════╗|footer=╚════╝|border=║|corner_tl=╔|corner_tr=╗|corner_bl=╚|corner_br=╝|h_border=═|v_border=║|cross=╬|t_cross=╦|b_cross=╩|l_cross=╠|r_cross=╣"
    ["simple"]="header=+---+|footer=+---+|border=|||corner_tl=+|corner_tr=+|corner_bl=+|corner_br=+|h_border=-|v_border=|||cross=+|t_cross=+|b_cross=+|l_cross=+|r_cross=+"
)

# Current theme settings
declare -A CURRENT_THEME

# Initialize default theme
init_theme() {
    local theme_name="${1:-default}"
    load_theme "$theme_name"
}

# Load a theme
load_theme() {
    local theme_name="$1"
    
    if [[ -z "${THEMES[$theme_name]}" ]]; then
        error "Theme '$theme_name' not found"
        return ${EXIT_FAILURE:-1}
    fi
    
    # Parse theme definition
    local theme_def="${THEMES[$theme_name]}"
    IFS='|' read -ra theme_parts <<< "$theme_def"
    
    for part in "${theme_parts[@]}"; do
        local key="${part%%=*}"
        local value="${part#*=}"
        CURRENT_THEME["$key"]="$value"
    done
    
    # Store current theme name
    CURRENT_THEME["name"]="$theme_name"
}

# Set theme (alias for load_theme)
set_theme() {
    load_theme "$@"
}

# Get current theme value
get_theme_color() {
    local key="$1"
    echo "${CURRENT_THEME[$key]:-white}"
}

# Get color code
get_color() {
    local name="$1"
    local style="$2"
    
    local color_code="${UI_COLORS[$name]:-${CURRENT_THEME[$name]}}"
    local style_code="${UI_STYLES[$style]:-}"
    
    echo "${style_code}${color_code}"
}

# Apply color to text
colorize() {
    local text="$1"
    local color_key="$2"
    local color_name="${CURRENT_THEME[$color_key]:-$color_key}"
    local color_code="${UI_COLORS[$color_name]:-\033[0m}"
    
    echo -e "${color_code}${text}\033[0m"
}

# Print colored text
print_color() {
    local text="$1"
    local color_key="$2"
    colorize "$text" "$color_key"
    echo
}

printc() {
    local color="$1"
    local style="$2"
    local text="$3"
    
    local color_code
    color_code=$(get_color "$color" "$style")
    
    echo -e "${color_code}${text}${UI_COLORS[reset]}"
}

# Print header
print_header() {
    local title="$1"
    local width="${2:-80}"
    local theme="${3:-default}"
    
    load_theme "$theme" 2>/dev/null || load_theme "default"
    
    local ascii_theme="${ASCII_THEMES[$theme]:-${ASCII_THEMES[default]}}"
    local corner_tl="${ascii_theme#*corner_tl=}" && corner_tl="${corner_tl%%|*}"
    local corner_tr="${ascii_theme#*corner_tr=}" && corner_tr="${corner_tr%%|*}"
    local h_border="${ascii_theme#*h_border=}" && h_border="${h_border%%|*}"
    
    # Top border
    local top_line="$corner_tl"
    top_line+="$(repeat_str "$h_border" $((width - 2)))"
    top_line+="$corner_tr"
    print_color "$top_line" "primary"
    
    # Title line
    local title_len="${#title}"
    local padding=$(((width - title_len - 2) / 2))
    local title_line="│"
    title_line+="$(repeat_str " " $padding)"
    title_line+="$title"
    title_line+="$(repeat_str " " $((width - title_len - padding - 2)))"
    title_line+="│"
    print_color "$title_line" "primary"
    
    # Bottom border
    local bottom_line="╚"
    bottom_line+="$(repeat_str "═" $((width - 2)))"
    bottom_line+="╝"
    print_color "$bottom_line" "primary"
}

header() {
    local title="$1"
    local width="${2:-60}"
    local color="${3:-primary}"
    
    local padding=$(( (width - ${#title}) / 2 ))
    local line
    line=$(repeat_str "$width" "─")
    
    printc "$color" "bold" "$line"
    printc "$color" "bold" "$(printf "%*s" "$padding")$title"
    printc "$color" "bold" "$line"
}

# Print footer
print_footer() {
    local text="$1"
    local width="${2:-80}"
    
    local footer_line="╚"
    footer_line+="$(repeat_str "═" $((width - 2)))"
    footer_line+="╝"
    print_color "$footer_line" "primary"
    
    if [[ -n "$text" ]]; then
        local text_len="${#text}"
        local padding=$(((width - text_len - 2) / 2))
        local text_line=" "
        text_line+="$(repeat_str " " $padding)"
        text_line+="$text"
        text_line+="$(repeat_str " " $((width - text_len - padding - 2)))"
        text_line+=" "
        print_color "$text_line" "info"
    fi
}

footer() {
    local text="$1"
    local width="${2:-60}"
    local color="${3:-secondary}"
    
    printf "%${width}s" "" | tr ' ' '─'
    printc "$color" "dim" " $text "
}

# Print separator line
print_separator() {
    local width="${1:-80}"
    local char="${2:-─}"
    local color_key="${3:-secondary}"
    
    local separator="$(repeat_str "$char" "$width")"
    print_color "$separator" "$color_key"
}

separator() {
    local char="${1:-─}"
    local length="${2:-60}"
    local color="${3:-accent}"
    
    printc "$color" "dim" "$(repeat_str "$length" "$char")"
}

# Print box around text
print_box() {
    local text="$1"
    local width="${2:-80}"
    local theme="${3:-default}"
    
    load_theme "$theme" 2>/dev/null || load_theme "default"
    
    local ascii_theme="${ASCII_THEMES[$theme]:-${ASCII_THEMES[default]}}"
    local v_border="${ascii_theme#*v_border=}" && v_border="${v_border%%|*}"
    
    # Split text into lines
    local -a lines
    IFS=$'\n' read -ra lines <<< "$text"
    
    for line in "${lines[@]}"; do
        local line_len="${#line}"
        local padding=$(((width - line_len - 2) / 2))
        local box_line="$v_border"
        box_line+="$(repeat_str " " $padding)"
        box_line+="$line"
        box_line+="$(repeat_str " " $((width - line_len - padding - 2)))"
        box_line+="$v_border"
        print_color "$box_line" "primary"
    done
}

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

# Interactive menu with theme
show_menu() {
    local title="$1"
    shift
    local -a options=("$@")
    local selected=0
    local key
    
    # Hide cursor
    tput civis 2>/dev/null || true
    
    while true; do
        # Clear screen and show header
        clear
        print_header "$title"
        echo
        
        # Show options
        for i in "${!options[@]}"; do
            local prefix="   "
            local color_key="text_default"
            
            if [[ $i -eq $selected ]]; then
                prefix=" > "
                color_key="primary"
            fi
            
            local option_line="$prefix${options[$i]}"
            print_color "$option_line" "$color_key"
        done
        
        echo
        print_color "Use ↑↓ to navigate, ENTER to select, ESC to quit" "info"
        
        # Read key
        read -rsn1 key 2>/dev/null || key=""
        
        case "$key" in
            $'\x1b')  # ESC sequence
                read -rsn2 -t 0.1 key 2>/dev/null || key=""
                case "$key" in
                    "[A")  # Up arrow
                        ((selected > 0)) && ((selected--))
                        ;;
                    "[B")  # Down arrow
                        ((selected < ${#options[@]} - 1)) && ((selected++))
                        ;;
                    *)  # ESC alone
                        selected=-1
                        break
                        ;;
                esac
                ;;
            "")  # ENTER
                break
                ;;
        esac
    done
    
    # Show cursor
    tput cnorm 2>/dev/null || true
    
    clear
    print_header "$title"
    echo
    
    if [[ $selected -eq -1 ]]; then
        print_color "Cancelled" "warning"
        return 1
    else
        print_color "Selected: ${options[$selected]}" "success"
        echo "${options[$selected]}"
        return $selected
    fi
}

themed_menu() {
    local title="$1"
    shift
    local options=("$@")
    local color="${CURRENT_THEME[primary]}"
    
    printc "$color" "bold" "$title"
    printc "$color" "dim" "$(repeat_str "${#title}" "─")"
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
confirm_dialog() {
    local message="$1"
    local default="${2:-n}"
    local result
    
    print_header "Confirmation"
    echo
    print_color "$message" "info"
    echo
    
    if [[ "$default" == "y" ]]; then
        prompt_yes_no "Confirm [Y/n]?" "$default" result
    else
        prompt_yes_no "Confirm [y/N]?" "$default" result
    fi
    
    echo
    if [[ "$result" == "yes" ]]; then
        print_color "Confirmed" "success"
        return 0
    else
        print_color "Cancelled" "warning"
        return 1
    fi
}

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

# Input dialog with theme
input_dialog() {
    local title="$1"
    local message="$2"
    local default="${3:-}"
    local result
    
    print_header "$title"
    echo
    print_color "$message" "info"
    echo
    prompt "Enter value" "$default" result
    echo
    print_color "Input: $result" "success"
    echo "$result"
}

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

# Progress dialog with theme
progress_dialog() {
    local title="$1"
    local total="$2"
    local current=0
    
    print_header "$title"
    echo
    
    while [[ $current -le $total ]]; do
        local progress
        show_progress "$current" "$total" 60 "█" progress
        print_color "$progress" "primary"
        
        ((current++))
        sleep 0.1
        
        # Move cursor up to overwrite progress bar
        tput cuu1 2>/dev/null || true
    done
    
    echo
    print_color "Complete!" "success"
}

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

# Status message with theme
status_message() {
    local message="$1"
    local status="${2:-info}"  # info, success, warning, error, danger
    local timeout="${3:-3}"
    
    case "$status" in
        "success")
            print_color "✓ $message" "success"
            ;;
        "warning"|"warn")
            print_color "⚠ $message" "warning"
            ;;
        "error"|"danger")
            print_color "✗ $message" "danger"
            ;;
        *)
            print_color "ℹ $message" "info"
            ;;
    esac
    
    if [[ "$timeout" -gt 0 ]]; then
        sleep "$timeout"
    fi
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

# List available themes
list_themes() {
    echo "Available themes:"
    for theme in "${!THEMES[@]}"; do
        if [[ "${CURRENT_THEME[name]}" == "$theme" ]]; then
            print_color "  $theme (current)" "success"
        else
            echo "  $theme"
        fi
    done
}

# List available ASCII themes
list_ascii_themes() {
    echo "Available ASCII themes:"
    for theme in "${!ASCII_THEMES[@]}"; do
        echo "  $theme"
    done
}

# Preview theme
preview_theme() {
    local theme_name="$1"
    
    if [[ -z "${THEMES[$theme_name]}" ]]; then
        error "Theme '$theme_name' not found"
        return ${EXIT_FAILURE:-1}
    fi
    
    load_theme "$theme_name"
    
    print_header "Theme Preview: $theme_name"
    echo
    print_color "This is primary text" "primary"
    print_color "This is secondary text" "secondary"
    print_color "This is success text" "success"
    print_color "This is warning text" "warning"
    print_color "This is danger text" "danger"
    print_color "This is info text" "info"
    echo
    print_separator
    echo
    print_box "This is a box with themed borders\nMultiple lines supported"
    echo
    print_footer "End of preview"
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

# Create custom theme
create_theme() {
    local name="$1"
    local primary="$2"
    local secondary="$3"
    local success="$4"
    local warning="$5"
    local danger="$6"
    local info="$7"
    local bg_default="$8"
    local text_default="$9"
    
    local theme_def="primary=$primary|secondary=$secondary|success=$success|warning=$warning|danger=$danger|info=$info|bg_default=$bg_default|text_default=$text_default"
    THEMES["$name"]="$theme_def"
    
    success "Theme '$name' created"
}

# Save theme to file
save_theme() {
    local name="$1"
    local file="$2"
    
    if [[ -z "${THEMES[$name]}" ]]; then
        error "Theme '$name' not found"
        return ${EXIT_FAILURE:-1}
    fi
    
    echo "THEMES[\"$name\"]=\"${THEMES[$name]}\"" >> "$file"
    success "Theme '$name' saved to $file"
}

# Load theme from file
load_theme_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        error "Theme file not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    source "$file"
    success "Themes loaded from $file"
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

# Initialize default theme on module load
init_theme "default"

# Export module functions
export_module ui \
    init_theme load_theme set_theme get_theme_color get_color colorize print_color printc \
    print_header header print_footer footer print_separator separator print_box box \
    show_menu themed_menu confirm_dialog themed_confirm input_dialog themed_prompt \
    progress_dialog themed_progress_bar status_message \
    themsg success warning error_msg info_msg \
    list_themes list_ascii_themes preview_theme current_theme_info \
    create_theme save_theme load_theme_file themed_table