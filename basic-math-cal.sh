#!/bin/bash

# Basic Math Calculator
# A demonstration of the Bash System Language framework

# Import required modules
source lib.sh

import core.system
import math.basic
import string
import ui
import io

# Calculator state
declare -a CALC_HISTORY=()
declare -i CALC_HISTORY_INDEX=0
declare -i CALC_HISTORY_MAX=100
declare -i CALC_PRECISION=2

# Calculator functions
calc_add() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Both arguments must be numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(add "$a" "$b")
    echo "$result"
}

calc_sub() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Both arguments must be numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(sub "$a" "$b")
    echo "$result"
}

calc_mul() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Both arguments must be numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(mul "$a" "$b")
    echo "$result"
}

calc_div() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Both arguments must be numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ "$b" -eq 0 ]]; then
        error "Division by zero is not allowed"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(div "$a" "$b")
    echo "$result"
}

calc_mod() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Both arguments must be numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ "$b" -eq 0 ]]; then
        error "Modulo by zero is not allowed"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(mod "$a" "$b")
    echo "$result"
}

calc_pow() {
    local base="$1"
    local exp="$2"
    
    if ! is_number "$base" || ! is_number "$exp"; then
        error "Both arguments must be numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ "$exp" -lt 0 ]]; then
        error "Negative exponents are not supported"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(pow "$base" "$exp")
    echo "$result"
}

calc_sqrt() {
    local num="$1"
    
    if ! is_number "$num"; then
        error "Argument must be a number"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ "$num" -lt 0 ]]; then
        error "Square root of negative number is not supported"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(sqrt_int "$num")
    echo "$result"
}

calc_factorial() {
    local n="$1"
    
    if ! is_number "$n"; then
        error "Argument must be a number"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ "$n" -lt 0 ]]; then
        error "Factorial of negative number is not supported"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(fact "$n")
    echo "$result"
}

calc_gcd() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Both arguments must be numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(gcd "$a" "$b")
    echo "$result"
}

calc_lcm() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Both arguments must be numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(lcm "$a" "$b")
    echo "$result"
}

calc_is_prime() {
    local num="$1"
    
    if ! is_number "$num"; then
        error "Argument must be a number"
        return ${EXIT_FAILURE:-1}
    fi
    
    if is_prime "$num"; then
        echo "true"
    else
        echo "false"
    fi
}

calc_fib() {
    local n="$1"
    
    if ! is_number "$n"; then
        error "Argument must be a number"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ "$n" -lt 0 ]]; then
        error "Fibonacci sequence index must be non-negative"
        return ${EXIT_FAILURE:-1}
    fi
    
    local result=$(fib_n "$n")
    echo "$result"
}

# History management
add_to_history() {
    local expression="$1"
    local result="$2"
    
    CALC_HISTORY[$CALC_HISTORY_INDEX]="$expression = $result"
    ((CALC_HISTORY_INDEX++))
    
    # Keep history within limits
    if [[ $CALC_HISTORY_INDEX -ge $CALC_HISTORY_MAX ]]; then
        # Remove oldest entry
        unset CALC_HISTORY[0]
        # Shift array
        local -a temp_history=("${CALC_HISTORY[@]}")
        CALC_HISTORY=()
        for ((i=1; i<${#temp_history[@]}; i++)); do
            CALC_HISTORY[$((i-1))]="${temp_history[$i]}"
        done
        ((CALC_HISTORY_INDEX--))
    fi
}

show_history() {
    if [[ $CALC_HISTORY_INDEX -eq 0 ]]; then
        echo "No calculation history yet"
        return
    fi
    
    echo "Calculation History:"
    echo "==================="
    
    for ((i=0; i<CALC_HISTORY_INDEX; i++)); do
        local entry="${CALC_HISTORY[$i]}"
        local expr="${entry%%=*}"
        local result="${entry#*=}"
        printf "%3d: %s = %s\n" $((i+1)) "$expr" "$result"
    done
}

clear_history() {
    CALC_HISTORY=()
    CALC_HISTORY_INDEX=0
    echo "History cleared"
}

# Expression evaluator
evaluate_expression() {
    local expression="$1"
    
    # Remove whitespace
    expression=$(echo "$expression" | tr -d ' ')
    
    # Handle basic operations
    if [[ "$expression" =~ ^(.+)\+(.+)$ ]]; then
        local a="${BASH_REMATCH[1]}"
        local b="${BASH_REMATCH[2]}"
        calc_add "$a" "$b"
    elif [[ "$expression" =~ ^(.+)\-(.+)$ ]]; then
        local a="${BASH_REMATCH[1]}"
        local b="${BASH_REMATCH[2]}"
        calc_sub "$a" "$b"
    elif [[ "$expression" =~ ^(.+)\*(.+)$ ]]; then
        local a="${BASH_REMATCH[1]}"
        local b="${BASH_REMATCH[2]}"
        calc_mul "$a" "$b"
    elif [[ "$expression" =~ ^(.+)/(.+)$ ]]; then
        local a="${BASH_REMATCH[1]}"
        local b="${BASH_REMATCH[2]}"
        calc_div "$a" "$b"
    elif [[ "$expression" =~ ^(.+)\%(.+)$ ]]; then
        local a="${BASH_REMATCH[1]}"
        local b="${BASH_REMATCH[2]}"
        calc_mod "$a" "$b"
    elif [[ "$expression" =~ ^(.+)\^(.+)$ ]]; then
        local base="${BASH_REMATCH[1]}"
        local exp="${BASH_REMATCH[2]}"
        calc_pow "$base" "$exp"
    elif [[ "$expression" =~ ^sqrt\((.+)\)$ ]]; then
        local num="${BASH_REMATCH[1]}"
        calc_sqrt "$num"
    elif [[ "$expression" =~ ^factorial\((.+)\)$ ]]; then
        local n="${BASH_REMATCH[1]}"
        calc_factorial "$n"
    elif [[ "$expression" =~ ^gcd\((.+),(.+)\)$ ]]; then
        local a="${BASH_REMATCH[1]}"
        local b="${BASH_REMATCH[2]}"
        calc_gcd "$a" "$b"
    elif [[ "$expression" =~ ^lcm\((.+),(.+)\)$ ]]; then
        local a="${BASH_REMATCH[1]}"
        local b="${BASH_REMATCH[2]}"
        calc_lcm "$a" "$b"
    elif [[ "$expression" =~ ^is_prime\((.+)\)$ ]]; then
        local num="${BASH_REMATCH[1]}"
        calc_is_prime "$num"
    elif [[ "$expression" =~ ^fib\((.+)\)$ ]]; then
        local n="${BASH_REMATCH[1]}"
        calc_fib "$n"
    else
        # Try to evaluate as a simple number
        if is_number "$expression"; then
            echo "$expression"
        else
            error "Invalid expression: $expression"
            return ${EXIT_FAILURE:-1}
        fi
    fi
}

# Interactive calculator
interactive_calculator() {
    echo "Basic Math Calculator"
    echo "===================="
    echo "Enter 'help' for available commands"
    echo "Enter 'quit' to exit"
    echo
    
    while true; do
        echo -n "calc> "
        read -r input
        
        case "$input" in
            "quit"|"exit"|"q")
                echo "Goodbye!"
                break
                ;;
            "help"|"h")
                show_help
                ;;
            "history"|"hist"|"!")
                show_history
                ;;
            "clear"|"c")
                clear_history
                ;;
            ""|*)
                if [[ -n "$input" ]]; then
                    local result
                    if result=$(evaluate_expression "$input" 2>/dev/null); then
                        echo "Result: $result"
                        add_to_history "$input" "$result"
                    else
                        echo "Error: Invalid expression or calculation failed"
                    fi
                fi
                ;;
        esac
    done
}

# Help system
show_help() {
    echo "Available Commands:"
    echo "==================="
    echo "Basic Operations:"
    echo "  5 + 3          - Addition"
    echo "  10 - 4         - Subtraction"
    echo "  6 * 7          - Multiplication"
    echo "  15 / 3         - Division"
    echo "  10 % 3         - Modulo"
    echo "  2 ^ 8          - Power"
    echo ""
    echo "Advanced Functions:"
    echo "  sqrt(16)       - Square root"
    echo "  factorial(5)   - Factorial"
    echo "  gcd(12, 8)    - Greatest common divisor"
    echo "  lcm(6, 8)     - Least common multiple"
    echo "  is_prime(7)   - Check if number is prime"
    echo "  fib(10)        - Fibonacci number"
    echo ""
    echo "Other Commands:"
    echo "  help           - Show this help"
    echo "  history        - Show calculation history"
    echo "  clear          - Clear history"
    echo "  quit           - Exit calculator"
    echo ""
    echo "Examples:"
    echo "  calc> 2 + 3"
    echo "  Result: 5"
    echo "  calc> sqrt(16)"
    echo "  Result: 4"
    echo "  calc> factorial(5)"
    echo "  Result: 120"
}

# Command line interface
main() {
    local command="${1:-interactive}"
    
    case "$command" in
        "interactive"|"")
            interactive_calculator
            ;;
        "eval"|"e")
            if [[ -z "$2" ]]; then
                error "Expression required for eval mode"
                echo "Usage: $0 eval <expression>"
                return ${EXIT_FAILURE:-1}
            fi
            local result
            if result=$(evaluate_expression "$2"); then
                echo "$result"
                return 0
            else
                return ${EXIT_FAILURE:-1}
            fi
            ;;
        "help"|"h"|"-h"|"--help")
            show_help
            ;;
        "version"|"v"|"-v"|"--version")
            echo "Basic Math Calculator v1.0.0"
            echo "Built with Bash System Language framework"
            ;;
        *)
            error "Unknown command: $command"
            echo "Usage: $0 [command] [args]"
            echo "Commands: interactive, eval, help, version"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
