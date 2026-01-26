#!/usr/bin/bash

# Enhanced Basic Math Calculator using Bash System Language
source ./lib.sh

# Import required modules
import math.basic
import string
import ui
import core.system

# Main calculator function
calculator_main() {
    header "Basic Math Calculator" 60 "primary"
    
    # Get first number with validation
    local num1
    while true; do
        num1=$(themed_prompt "Enter the first number")
        if string.is_numeric "$num1"; then
            success "First number: $num1"
            break
        else
            error_msg "Invalid input. Please enter a valid number."
        fi
    done
    
    # Get second number with validation
    local num2
    while true; do
        num2=$(themed_prompt "Enter the second number")
        if string.is_numeric "$num2"; then
            success "Second number: $num2"
            break
        else
            error_msg "Invalid input. Please enter a valid number."
        fi
    done
    
    separator "─" 60 "accent"
    
    # Display available operations
    local operations=("Addition (+)" "Subtraction (-)" "Multiplication (*)" "Division (/)" "Square" "Cube" "Power (^)" "Exit")
    
    local choice
    choice=$(themed_menu "Choose an operation" "${operations[@]}")
    
    local result
    local operation_name
    
    case "$choice" in
        "Addition (+)")
            result=$(math.basic.add "$num1" "$num2")
            operation_name="Addition"
            ;;
        "Subtraction (-)")
            result=$(math.basic.subtract "$num1" "$num2")
            operation_name="Subtraction"
            ;;
        "Multiplication (*)")
            result=$(math.basic.multiply "$num1" "$num2")
            operation_name="Multiplication"
            ;;
        "Division (/)")
            if math.basic.equal "$num2" "0"; then
                error_msg "Division by zero is not allowed."
                return 1
            else
                result=$(math.basic.divide "$num1" "$num2")
                operation_name="Division"
            fi
            ;;
        "Square")
            local square_choice
            square_choice=$(themed_menu "Square which number?" "First number ($num1)" "Second number ($num2)")
            if [[ "$square_choice" == "First number ($num1)" ]]; then
                result=$(math.basic.power "$num1" "2")
                operation_name="Square of $num1"
            else
                result=$(math.basic.power "$num2" "2")
                operation_name="Square of $num2"
            fi
            ;;
        "Cube")
            local cube_choice
            cube_choice=$(themed_menu "Cube which number?" "First number ($num1)" "Second number ($num2)")
            if [[ "$cube_choice" == "First number ($num1)" ]]; then
                result=$(math.basic.power "$num1" "3")
                operation_name="Cube of $num1"
            else
                result=$(math.basic.power "$num2" "3")
                operation_name="Cube of $num2"
            fi
            ;;
        "Power (^)")
            local power_base=$(themed_prompt "Enter base number" "$num1")
            local power_exp=$(themed_prompt "Enter exponent" "$num2")
            result=$(math.basic.power "$power_base" "$power_exp")
            operation_name="Power ($power_base^$power_exp)"
            ;;
        "Exit")
            info_msg "Calculator session ended."
            return 0
            ;;
        *)
            error_msg "Invalid operation selected."
            return 1
            ;;
    esac
    
    # Display result with enhanced formatting
    separator "═" 60 "success"
    box "Result: $result" 50 "success"
    printc "success" "bold" "$operation_name completed successfully!"
    separator "═" 60 "success"
    
    # Ask if user wants to continue
    if themed_confirm "Do you want to perform another calculation?" "y"; then
        calculator_main
    else
        info_msg "Thank you for using the calculator!"
    fi
}

# Additional utility functions
display_history() {
    local history_file="$HOME/.calc_history"
    if [[ -f "$history_file" ]]; then
        header "Calculation History" 60 "info"
        cat "$history_file"
        separator "─" 60 "info"
    else
        warning "No history found."
    fi
}

save_to_history() {
    local expression="$1"
    local result="$2"
    local history_file="$HOME/.calc_history"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] $expression = $result" >> "$history_file"
}

# Enhanced calculator with history
enhanced_calculator() {
    # Set a nice theme
    ui.set_theme "neon"
    
    header "Enhanced Bash Calculator" 80 "primary"
    info_msg "Welcome to the Enhanced Bash Calculator!"
    info_msg "This calculator uses the Bash System Language framework."
    echo
    
    local main_options=("Start Calculator" "View History" "Change Theme" "Exit")
    
    local main_choice
    main_choice=$(themed_menu "Main Menu" "${main_options[@]}")
    
    case "$main_choice" in
        "Start Calculator")
            calculator_main
            ;;
        "View History")
            display_history
            enhanced_calculator
            ;;
        "Change Theme")
            local themes=("default" "dark" "light" "neon" "retro")
            local theme_choice
            theme_choice=$(themed_menu "Select a theme" "${themes[@]}")
            ui.set_theme "$theme_choice"
            success "Theme changed to $theme_choice"
            enhanced_calculator
            ;;
        "Exit")
            info_msg "Goodbye!"
            return 0
            ;;
    esac
}

# Run the enhanced calculator
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    enhanced_calculator "$@"
fi
