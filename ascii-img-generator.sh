#!/usr/bin/bash

# Simplified ASCII Image Generator using Bash System Language
# Creates ASCII art from text and basic patterns without external dependencies
#
# Usage: ./ascii-img-generator.sh [options]
# Options:
#   -t <type>   : Art type (text, pattern, border, effects)
#   -p <pattern>: Pattern type (checkerboard, diamond, heart, star, tree)
#   -s <size>   : Size (small, medium, large)
#   -c <theme>  : Color theme (dark, light, neon, ocean, forest)
#   -o <file>   : Output to file
#   -i          : Interactive mode
#
# --- Simplified with Bash System Language

source ./lib.sh

# Import required modules
import core.system
import string
import ui
import io

# Configuration module
module_version "ascii.generator" "1.0.0"

# Default values
CONFIG_TYPE="pattern"
CONFIG_PATTERN="checkerboard"
CONFIG_SIZE="medium"
CONFIG_THEME="dark"
CONFIG_OUTPUT=""
CONFIG_INTERACTIVE=false
CONFIG_TEXT=""

# Size configurations
declare -A SIZES=(
    ["small"]="20x10"
    ["medium"]="40x20"
    ["large"]="60x30"
)

# Pattern generators
generate_checkerboard() {
    local size="$1"
    local width height
    IFS='x' read -r width height <<< "$size"
    
    for ((i=0; i<height; i++)); do
        for ((j=0; j<width; j++)); do
            if (( (i + j) % 2 == 0 )); then
                echo -n "█"
            else
                echo -n "░"
            fi
        done
        echo
    done
}

generate_diamond() {
    local size="$1"
    local width height
    IFS='x' read -r width height <<< "$size"
    local mid_width=$((width / 2))
    local mid_height=$((height / 2))
    
    # Top half
    for ((i=0; i<mid_height; i++)); do
        local spaces=$((mid_width - i))
        local stars=$((2 * i + 1))
        printf "%*s" $spaces ""
        printf "%*s\n" $stars | tr ' ' '*'
    done
    
    # Bottom half
    for ((i=mid_height-1; i>=0; i--)); do
        local spaces=$((mid_width - i))
        local stars=$((2 * i + 1))
        printf "%*s" $spaces ""
        printf "%*s\n" $stars | tr ' ' '*'
    done
}

generate_heart() {
    local size="$1"
    local width height
    IFS='x' read -r width height <<< "$size"
    
    # Simple heart shape
    local heart=(
        "  ♥♥   ♥♥  "
        " ♥███ ███♥ "
        "██████████"
        "██████████"
        " ████████ "
        "  ██████  "
        "   ████   "
        "    ██    "
        "     █     "
    )
    
    local start_line=$(( (${#heart[@]} - height) / 2 ))
    for ((i=0; i<height && i+start_line<${#heart[@]}; i++)); do
        local line="${heart[$((i+start_line))]}"
        local padding=$(((width - ${#line}) / 2))
        printf "%*s%s\n" $padding "" "$line"
    done
}

generate_star() {
    local size="$1"
    local width height
    IFS='x' read -r width height <<< "$size"
    local mid_width=$((width / 2))
    
    # Simple star pattern
    local star_patterns=(
        "    *    "
        "   ***   "
        "  *****  "
        "    *    "
        "   ***   "
        "  *****  "
        " ******* "
        "*********"
        " ******* "
        "  *****  "
        "   ***   "
        "    *    "
    )
    
    local start_line=$(( (${#star_patterns[@]} - height) / 2 ))
    for ((i=0; i<height && i+start_line<${#star_patterns[@]}; i++)); do
        local line="${star_patterns[$((i+start_line))]}"
        local padding=$(((width - ${#line}) / 2))
        printf "%*s%s\n" $padding "" "$line"
    done
}

generate_tree() {
    local size="$1"
    local width height
    IFS='x' read -r width height <<< "$size"
    local mid_width=$((width / 2))
    
    # Tree layers
    local layers=(
        "    *    "
        "   ***   "
        "  *****  "
        " ******* "
        "*********"
        "   ***   "
        "   ***   "
        "   ***   "
    )
    
    local start_line=$(( (${#layers[@]} - height) / 2 ))
    for ((i=0; i<height && i+start_line<${#layers[@]}; i++)); do
        local line="${layers[$((i+start_line))]}"
        local padding=$(((width - ${#line}) / 2))
        printf "%*s%s\n" $padding "" "$line"
    done
}

generate_text_ascii() {
    local text="$1"
    local size="$2"
    local width height
    IFS='x' read -r width height <<< "$size"
    
    # Simple text to ASCII (basic letter patterns)
    local -A letter_patterns=(
        ["A"]="  █  \n ███ \n█   █\n█████\n█   █"
        ["B"]="████ \n█   █\n████ \n█   █\n████ "
        ["C"]=" ████\n█    \n█    \n█    \n ████"
        ["D"]="████ \n█   █\n█   █\n█   █\n████ "
        ["E"]="█████\n█    \n███  \n█    \n█████"
        ["F"]="█████\n█    \n███  \n█    \n█    "
        ["G"]=" ████\n█    \n█  ██\n█   █\n ████"
        ["H"]="█   █\n█   █\n█████\n█   █\n█   █"
        ["I"]="█████\n  █  \n  █  \n  █  \n█████"
        ["L"]="█    \n█    \n█    \n█    \n█████"
        ["O"]=" ███ \n█   █\n█   █\n█   █\n ███ "
        ["P"]="████ \n█   █\n████ \n█    \n█    "
        ["R"]="████ \n█   █\n████ \n█   █\n█   █"
        ["S"]=" ████\n█    \n ███ \n    █\n████ "
        ["T"]="█████\n  █  \n  █  \n  █  \n  █  "
        ["U"]="█   █\n█   █\n█   █\n█   █\n ███ "
        ["Y"]="█   █\n█   █\n ███ \n  █  \n  █  "
        [" "]="     \n     \n     \n     \n     "
    )
    
    # Convert text to uppercase
    text=$(string.to_upper "$text")
    
    # Generate ASCII for each character
    local result_lines=()
    for ((line=0; line<5; line++)); do
        local line_result=""
        for ((char=0; char<${#text}; char++)); do
            local letter="${text:$char:1}"
            local pattern="${letter_patterns[$letter]:-$letter_patterns[ ]}"
            local pattern_line
            pattern_line=$(echo "$pattern" | sed -n "$((line+1))p")
            line_result+="$pattern_line  "
        done
        result_lines+=("$line_result")
    done
    
    # Center and display
    for line in "${result_lines[@]}"; do
        local padding=$(((width - ${#line}) / 2))
        printf "%*s%s\n" $padding "" "$line"
    done
}

add_border() {
    local content="$1"
    local border_type="$2"
    local width
    width=$(echo "$content" | head -1 | wc -c)
    
    case "$border_type" in
        "double")
            echo "╔$(printf "═%.0s" $(seq 1 $((width-2))))╗"
            echo "$content" | while IFS= read -r line; do
                echo "║$line║"
            done
            echo "╚$(printf "═%.0s" $(seq 1 $((width-2))))╝"
            ;;
        "single")
            echo "┌$(printf "─%.0s" $(seq 1 $((width-2))))┐"
            echo "$content" | while IFS= read -r line; do
                echo "│$line│"
            done
            echo "└$(printf "─%.0s" $(seq 1 $((width-2))))┘"
            ;;
        "rounded")
            echo "╭$(printf "─%.0s" $(seq 1 $((width-2))))╮"
            echo "$content" | while IFS= read -r line; do
                echo "│$line│"
            done
            echo "╰$(printf "─%.0s" $(seq 1 $((width-2))))╯"
            ;;
        *)
            echo "$content"
            ;;
    esac
}

add_shadow() {
    local content="$1"
    echo "$content" | while IFS= read -r line; do
        echo "$line  ██"
    done
}

# Main generation function
generate_ascii() {
    local size="${SIZES[$CONFIG_SIZE]}"
    local content=""
    
    case "$CONFIG_TYPE" in
        "pattern")
            case "$CONFIG_PATTERN" in
                "checkerboard") content=$(generate_checkerboard "$size") ;;
                "diamond") content=$(generate_diamond "$size") ;;
                "heart") content=$(generate_heart "$size") ;;
                "star") content=$(generate_star "$size") ;;
                "tree") content=$(generate_tree "$size") ;;
                *) content=$(generate_checkerboard "$size") ;;
            esac
            ;;
        "text")
            if [[ -z "$CONFIG_TEXT" ]]; then
                CONFIG_TEXT="HELLO"
            fi
            content=$(generate_text_ascii "$CONFIG_TEXT" "$size")
            ;;
        *)
            content=$(generate_checkerboard "$size")
            ;;
    esac
    
    # Apply effects
    content=$(add_border "$content" "double")
    content=$(add_shadow "$content")
    
    # Output
    if [[ -n "$CONFIG_OUTPUT" ]]; then
        echo "$content" > "$CONFIG_OUTPUT"
        success "ASCII art saved to: $CONFIG_OUTPUT"
    else
        echo "$content"
    fi
}

# Interactive mode
interactive_mode() {
    ui.set_theme "neon"
    
    header "ASCII Generator - Interactive Mode" 80 "primary"
    
    # Select type
    local type_options=("pattern" "text")
    local selected_type
    selected_type=$(themed_menu "Select art type" "${type_options[@]}")
    CONFIG_TYPE="$selected_type"
    
    if [[ "$CONFIG_TYPE" == "pattern" ]]; then
        # Select pattern
        local pattern_options=("checkerboard" "diamond" "heart" "star" "tree")
        local selected_pattern
        selected_pattern=$(themed_menu "Select pattern" "${pattern_options[@]}")
        CONFIG_PATTERN="$selected_pattern"
    else
        # Enter text
        CONFIG_TEXT=$(themed_prompt "Enter text to convert" "HELLO")
    fi
    
    # Select size
    local size_options=("small" "medium" "large")
    local selected_size
    selected_size=$(themed_menu "Select size" "${size_options[@]}")
    CONFIG_SIZE="$selected_size"
    
    # Select theme
    local theme_options=("dark" "light" "neon" "ocean" "forest")
    local selected_theme
    selected_theme=$(themed_menu "Select theme" "${theme_options[@]}")
    CONFIG_THEME="$selected_theme"
    
    # Output file
    if themed_confirm "Save to file?" "n"; then
        CONFIG_OUTPUT=$(themed_prompt "Output file" "ascii-art.txt")
    fi
    
    # Generate
    ui.set_theme "$CONFIG_THEME"
    generate_ascii
}

# List available patterns
list_patterns() {
    header "Available Patterns" 60 "info"
    
    local pattern_data=(
        "checkerboard|Alternating squares|█░█░█░"
        "diamond|Diamond shape|▲/\\▼"
        "heart|Heart shape|♥♥♥"
        "star|Star shape|★☆★"
        "tree|Tree shape|🌲🌲"
    )
    
    local -a headers=("Pattern" "Description" "Preview")
    local -a rows=()
    
    for pattern_info in "${pattern_data[@]}"; do
        IFS='|' read -r name desc preview <<< "$pattern_info"
        rows+=("$name|$desc|$preview")
    done
    
    themed_table "${headers[@]}" "${rows[@]}"
}

# Parse command line options
parse_options() {
    while getopts "t:p:s:c:o:i" opt; do
        case $opt in
            t) CONFIG_TYPE="$OPTARG" ;;
            p) CONFIG_PATTERN="$OPTARG" ;;
            s) CONFIG_SIZE="$OPTARG" ;;
            c) CONFIG_THEME="$OPTARG" ;;
            o) CONFIG_OUTPUT="$OPTARG" ;;
            i) CONFIG_INTERACTIVE=true ;;
            *)
                error_msg "Usage: $0 [-t type] [-p pattern] [-s size] [-c theme] [-o file] [-i]"
                return 1
                ;;
        esac
    done
}

# Main function
main() {
    # Set theme
    ui.set_theme "$CONFIG_THEME"
    
    # Parse options
    if [[ $# -eq 0 ]]; then
        interactive_mode
        return 0
    fi
    
    parse_options "$@" || return 1
    
    if [[ "$CONFIG_INTERACTIVE" == true ]]; then
        interactive_mode
    else
        generate_ascii
    fi
}

# Export module functions
export_module "ascii.generator" generate_checkerboard generate_diamond generate_heart generate_star generate_tree generate_text_ascii add_border add_shadow generate_ascii interactive_mode list_patterns main

# Run main function if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
