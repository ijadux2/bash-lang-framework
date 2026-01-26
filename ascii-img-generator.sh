#!/usr/bin/bash

# Enhanced ASCII Image Generator using Bash System Language
# Supports PNG, JPG, GIF formats with advanced theming and options
#
# Usage: ./ascii-img-generator.sh [options] <image_file>
# Options:
#   -w <width>  : Set output width (default: 80)
#   -h <height> : Set output height (default: auto)
#   -t <theme>  : Set ASCII theme (default, blocks, dots, binary)
#   -c          : Use color output
#   -o <file>   : Output to file instead of stdout
#   -v          : Verbose mode
#
# --- Enhanced with Bash System Language

source ./lib.sh

# Import required modules
import core.system
import string
import ui
import io
import fs

# Configuration module
module_version "ascii.generator" "2.0.0"

# Default values
CONFIG_WIDTH=80
CONFIG_HEIGHT=""
CONFIG_THEME="default"
CONFIG_COLOR=false
CONFIG_OUTPUT=""
CONFIG_VERBOSE=false
CONFIG_INVERT=false

# Initialize ASCII_THEMES if not already defined
if [[ ${#ASCII_THEMES[@]} -eq 0 ]]; then
    declare -A ASCII_THEMES=(
        ["default"]=" .:-=+*#%@"
        ["blocks"]=" ░▒▓█"
        ["dots"]=" ·:;•●"
        ["binary"]=" 01"
        ["simple"]=" .oO"
        ["detailed"]=" .,:;i1tfLCG08@"
        ["braille"]="⠀⠁⠂⠃⠄⠅⠆⠇⠈⠉⠊⠋⠌⠍⠎⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠙⠚⠛⠜⠝⠞⠟⠠⠡⠢⠣⠤⠥⠦⠧⠨⠩⠪⠫⠬⠭⠮⠯⠰⠱⠲⠳⠴⠵⠶⠷⠸⠹⠺⠻⠼⠽⠾⠿"
    )
fi

# Parse command line options
parse_options() {
    while getopts "w:h:t:co:vi" opt; do
        case $opt in
            w) CONFIG_WIDTH="$OPTARG" ;;
            h) CONFIG_HEIGHT="$OPTARG" ;;
            t) CONFIG_THEME="$OPTARG" ;;
            c) CONFIG_COLOR=true ;;
            o) CONFIG_OUTPUT="$OPTARG" ;;
            v) CONFIG_VERBOSE=true ;;
            i) CONFIG_INVERT=true ;;
            *)
                error_msg "Usage: $0 [-w width] [-h height] [-t theme] [-c] [-o file] [-v] [-i] <image_file>"
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))
    
    if [[ $# -ne 1 ]]; then
        error_msg "Please provide an image file."
        return 1
    fi
    
    IMAGE_FILE="$1"
}

# Validate image file
validate_image() {
    if [[ ! -f "$IMAGE_FILE" ]]; then
        error_msg "File '$IMAGE_FILE' does not exist."
        return 1
    fi
    
    local ext
    ext=$(string.to_lower "${IMAGE_FILE##*.}")
    
    case "$ext" in
        png|jpg|jpeg|gif|bmp|tiff)
            success "Valid image format: $ext"
            ;;
        *)
            error_msg "Unsupported format: $ext. Supported: PNG, JPG, GIF, BMP, TIFF"
            return 1
            ;;
    esac
}

# Check dependencies
check_dependencies() {
    local deps=("jp2a" "convert" "identify")
    local available=()
    
    for dep in "${deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            available+=("$dep")
        fi
    done
    
    if [[ $CONFIG_VERBOSE == true ]]; then
        info_msg "Available tools: ${available[*]}"
    fi
    
    echo "${available[@]}"
}

# Generate ASCII using jp2a
generate_with_jp2a() {
    local cmd="jp2a --width=$CONFIG_WIDTH"
    
    if [[ -n "$CONFIG_HEIGHT" ]]; then
        cmd="$cmd --height=$CONFIG_HEIGHT"
    fi
    
    if [[ "$CONFIG_COLOR" == true ]]; then
        cmd="$cmd --colors"
    fi
    
    if [[ "$CONFIG_INVERT" == true ]]; then
        cmd="$cmd --invert"
    fi
    
    cmd="$cmd \"$IMAGE_FILE\""
    
    if [[ $CONFIG_VERBOSE == true ]]; then
        info_msg "Running: $cmd"
    fi
    
    eval "$cmd"
}

# Generate ASCII using ImageMagick fallback
generate_with_imagemagick() {
    local resize="${CONFIG_WIDTH}x"
    if [[ -n "$CONFIG_HEIGHT" ]]; then
        resize="${CONFIG_WIDTH}x${CONFIG_HEIGHT}!"
    fi
    
    local chars="${ASCII_THEMES[$CONFIG_THEME]:-${ASCII_THEMES[default]}}"
    
    if [[ $CONFIG_VERBOSE == true ]]; then
        info_msg "Using ImageMagick with theme: $CONFIG_THEME"
        info_msg "Character set: $chars"
        info_msg "Resize: $resize"
    fi
    
    convert "$IMAGE_FILE" -resize "$resize" -colorspace Gray txt:- |
        awk -v chars="$chars" -v width="$CONFIG_WIDTH" -v invert="$CONFIG_INVERT" '
        BEGIN {
            n = split(chars, char_array, "")
            if (invert == "true") {
                for (i = 1; i <= n/2; i++) {
                    temp = char_array[i]
                    char_array[i] = char_array[n-i+1]
                    char_array[n-i+1] = temp
                }
            }
        }
        /^#/ { next }
        {
            if (NF >= 4) {
                gray = $4
                idx = int((gray / 255) * (n - 1)) + 1
                printf "%s", char_array[idx]
                col++
                if (col >= width) {
                    printf "\n"
                    col = 0
                }
            }
        }
        END {
            if (col > 0) printf "\n"
        }'
}

# Enhanced ASCII generator with effects
generate_enhanced_ascii() {
    local available_tools
    available_tools=($(check_dependencies))
    
    header "ASCII Image Generator" 80 "primary"
    info_msg "Processing: $IMAGE_FILE"
    info_msg "Dimensions: ${CONFIG_WIDTH}x${CONFIG_HEIGHT:-auto}"
    info_msg "Theme: $CONFIG_THEME"
    info_msg "Color: $CONFIG_COLOR"
    separator "─" 80 "accent"
    
    local result
    if [[ " ${available_tools[*]} " == *" jp2a "* ]]; then
        result=$(generate_with_jp2a)
    elif [[ " ${available_tools[*]} " == *" convert "* ]]; then
        result=$(generate_with_imagemagick)
    else
        error_msg "No suitable tools found. Install jp2a or ImageMagick."
        return 1
    fi
    
    # Apply color if enabled
    if [[ "$CONFIG_COLOR" == true ]]; then
        result=$(apply_color_theme "$result")
    fi
    
    # Output result
    if [[ -n "$CONFIG_OUTPUT" ]]; then
        echo "$result" > "$CONFIG_OUTPUT"
        success "ASCII art saved to: $CONFIG_OUTPUT"
    else
        echo "$result"
    fi
    
    separator "═" 80 "success"
    success "Generation completed!"
}

# Apply color theme to ASCII
apply_color_theme() {
    local ascii="$1"
    local color_map=(
        " " "black"
        "." "blue"
        ":" "cyan"
        "-" "green"
        "=" "yellow"
        "+" "magenta"
        "*" "red"
        "#" "bright_red"
        "%" "white"
        "@" "bright_white"
    )
    
    if [[ "$CONFIG_THEME" == "blocks" ]]; then
        color_map=(
            " " "black"
            "░" "blue"
            "▒" "cyan"
            "▓" "green"
            "█" "white"
        )
    fi
    
    # Apply colors (simplified version)
    echo "$ascii" | while IFS= read -r line; do
        local colored_line=""
        for ((i=0; i<${#line}; i++)); do
            local char="${line:$i:1}"
            local color="white"
            
            # Find color for character
            for ((j=0; j<${#color_map[@]}; j+=2)); do
                if [[ "$char" == "${color_map[$j]}" ]]; then
                    color="${color_map[$((j+1))]}"
                    break
                fi
            done
            
            colored_line+="$(get_color "$color")$char"
        done
        echo "$colored_line${UI_COLORS[reset]}"
    done
}

# Interactive mode
interactive_mode() {
    ui.set_theme "neon"
    
    header "ASCII Generator - Interactive Mode" 80 "primary"
    
    # Select image file
    local image_files=()
    while IFS= read -r -d '' file; do
        image_files+=("$file")
    done < <(find . -maxdepth 2 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" \) -print0 2>/dev/null)
    
    if [[ ${#image_files[@]} -eq 0 ]]; then
        error_msg "No image files found in current directory."
        return 1
    fi
    
    local selected_image
    selected_image=$(themed_menu "Select an image file" "${image_files[@]}")
    IMAGE_FILE="$selected_image"
    
    # Select theme
    local theme_options=("default" "blocks" "dots" "binary" "simple" "detailed" "braille")
    local selected_theme
    selected_theme=$(themed_menu "Select ASCII theme" "${theme_options[@]}")
    CONFIG_THEME="$selected_theme"
    
    # Configure dimensions
    CONFIG_WIDTH=$(themed_prompt "Enter width" "80")
    CONFIG_HEIGHT=$(themed_prompt "Enter height (leave empty for auto)" "")
    
    # Additional options
    if themed_confirm "Use color output?" "n"; then
        CONFIG_COLOR=true
    fi
    
    if themed_confirm "Invert colors?" "n"; then
        CONFIG_INVERT=true
    fi
    
    # Generate ASCII
    generate_enhanced_ascii
}

# List available themes
list_themes() {
    header "Available ASCII Themes" 60 "info"
    
    local theme_data=(
        "default|Standard grayscale characters| .:-=+*#%@"
        "blocks|Unicode block characters| ░▒▓█"
        "dots|Dot patterns| ·:;•●"
        "binary|Binary digits| 01"
        "simple|Simple characters| .oO"
        "detailed|High detail characters| .,:;i1tfLCG08@"
        "braille|Braille patterns| ⠁⠂⠃..."
    )
    
    local -a headers=("Theme" "Description" "Characters")
    local -a rows=()
    
    for theme_info in "${theme_data[@]}"; do
        IFS='|' read -r name desc chars <<< "$theme_info"
        rows+=("$name|$desc|$chars")
    done
    
    themed_table "${headers[@]}" "${rows[@]}"
}

# Main function
main() {
    # Set theme
    ui.set_theme "dark"
    
    # Parse options
    if [[ $# -eq 0 ]]; then
        interactive_mode
        return 0
    fi
    
    parse_options "$@" || return 1
    validate_image || return 1
    generate_enhanced_ascii
}

# Export module functions
export_module "ascii.generator" parse_options validate_image check_dependencies generate_with_jp2a generate_with_imagemagick generate_enhanced_ascii apply_color_theme interactive_mode list_themes main

# Run main function if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
