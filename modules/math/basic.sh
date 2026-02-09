#!/bin/bash

# Basic Math Module
# Provides arithmetic operations and mathematical utilities

module_version math.basic 1.0.0

# Basic arithmetic operations
add() {
    local a="$1"
    local b="$2"
    echo "$((a + b))"
}

sub() {
    local a="$1"
    local b="$2"
    echo "$((a - b))"
}

subtract() {
    sub "$@"
}

mul() {
    local a="$1"
    local b="$2"
    echo "$((a * b))"
}

multiply() {
    mul "$@"
}

div() {
    local a="$1"
    local b="$2"
    
    if [[ "$b" -eq 0 ]]; then
        error "Division by zero"
        return ${EXIT_FAILURE:-1}
    fi
    
    echo "$((a / b))"
}

divide() {
    div "$@"
}

mod() {
    local a="$1"
    local b="$2"
    
    if [[ "$b" -eq 0 ]]; then
        error "Modulo by zero"
        return ${EXIT_FAILURE:-1}
    fi
    
    echo "$((a % b))"
}

pow() {
    local base="$1"
    local exp="$2"
    local result=1
    
    if [[ "$exp" -lt 0 ]]; then
        error "Negative exponent not supported"
        return ${EXIT_FAILURE:-1}
    fi
    
    for ((i=0; i<exp; i++)); do
        result=$((result * base))
    done
    
    echo "$result"
}

power() {
    pow "$@"
}

# Comparison functions
eq() {
    local a="$1"
    local b="$2"
    [[ "$a" -eq "$b" ]]
}

equal() {
    eq "$@"
}

ne() {
    local a="$1"
    local b="$2"
    [[ "$a" -ne "$b" ]]
}

not_equal() {
    ne "$@"
}

lt() {
    local a="$1"
    local b="$2"
    [[ "$a" -lt "$b" ]]
}

less() {
    lt "$@"
}

le() {
    local a="$1"
    local b="$2"
    [[ "$a" -le "$b" ]]
}

less_equal() {
    le "$@"
}

gt() {
    local a="$1"
    local b="$2"
    [[ "$a" -gt "$b" ]]
}

greater() {
    gt "$@"
}

ge() {
    local a="$1"
    local b="$2"
    [[ "$a" -ge "$b" ]]
}

greater_equal() {
    ge "$@"
}

# Min/Max functions
min() {
    local min_val="$1"
    shift
    
    for val in "$@"; do
        if [[ "$val" -lt "$min_val" ]]; then
            min_val="$val"
        fi
    done
    
    echo "$min_val"
}

max() {
    local max_val="$1"
    shift
    
    for val in "$@"; do
        if [[ "$val" -gt "$max_val" ]]; then
            max_val="$val"
        fi
    done
    
    echo "$max_val"
}

# Find minimum in array
min_array() {
    local min_val="$1"
    shift
    
    for val in "$@"; do
        if [[ "$val" -lt "$min_val" ]]; then
            min_val="$val"
        fi
    done
    
    echo "$min_val"
}

# Find maximum in array
max_array() {
    local max_val="$1"
    shift
    
    for val in "$@"; do
        if [[ "$val" -gt "$max_val" ]]; then
            max_val="$val"
        fi
    done
    
    echo "$max_val"
}

# Sum of numbers
sum() {
    local total=0
    
    for num in "$@"; do
        total=$((total + num))
    done
    
    echo "$total"
}

# Average of numbers
avg() {
    local count=$#
    local total=$(sum "$@")
    
    if [[ "$count" -eq 0 ]]; then
        error "No numbers provided"
        return ${EXIT_FAILURE:-1}
    fi
    
    echo "$((total / count))"
}

# Absolute value
abs() {
    local num="$1"
    
    if [[ "$num" -lt 0 ]]; then
        echo "$((0 - num))"
    else
        echo "$num"
    fi
}

# Factorial
fact() {
    local n="$1"
    local result=1
    
    if [[ "$n" -lt 0 ]]; then
        error "Factorial of negative number"
        return ${EXIT_FAILURE:-1}
    fi
    
    for ((i=1; i<=n; i++)); do
        result=$((result * i))
    done
    
    echo "$result"
}

# Greatest Common Divisor (Euclidean algorithm)
gcd() {
    local a="$1"
    local b="$2"
    local temp
    
    while [[ "$b" -ne 0 ]]; do
        temp="$b"
        b=$((a % b))
        a="$temp"
    done
    
    echo "$a"
}

# Least Common Multiple
lcm() {
    local a="$1"
    local b="$2"
    
    if [[ "$a" -eq 0 || "$b" -eq 0 ]]; then
        echo "0"
        return
    fi
    
    local result=$((a * b / $(gcd "$a" "$b")))
    echo "$result"
}

# Check if number is even
is_even() {
    local num="$1"
    [[ $((num % 2)) -eq 0 ]]
}

# Check if number is odd
is_odd() {
    local num="$1"
    [[ $((num % 2)) -ne 0 ]]
}

# Check if number is prime
is_prime() {
    local num="$1"
    
    if [[ "$num" -le 1 ]]; then
        return 1
    fi
    
    if [[ "$num" -le 3 ]]; then
        return 0
    fi
    
    if [[ $((num % 2)) -eq 0 || $((num % 3)) -eq 0 ]]; then
        return 1
    fi
    
    local i=5
    while [[ $((i * i)) -le "$num" ]]; do
        if [[ $((num % i)) -eq 0 || $((num % (i + 2))) -eq 0 ]]; then
            return 1
        fi
        i=$((i + 6))
    done
    
    return 0
}

# Generate Fibonacci sequence up to n terms
fib() {
    local n="$1"
    local a=0
    local b=1
    
    if [[ "$n" -le 0 ]]; then
        return
    fi
    
    for ((i=0; i<n; i++)); do
        echo "$a"
        local temp="$a"
        a="$b"
        b=$((temp + b))
    done
}

# Get nth Fibonacci number
fib_n() {
    local n="$1"
    
    if [[ "$n" -le 0 ]]; then
        echo "0"
        return
    fi
    
    local a=0
    local b=1
    
    for ((i=1; i<n; i++)); do
        local temp="$a"
        a="$b"
        b=$((temp + b))
    done
    
    echo "$a"
}

# Square root (integer approximation)
sqrt_int() {
    local num="$1"
    local low=0
    local high="$num"
    local mid
    local result=0
    
    if [[ "$num" -lt 0 ]]; then
        error "Square root of negative number"
        return ${EXIT_FAILURE:-1}
    fi
    
    while [[ "$low" -le "$high" ]]; do
        mid=$(((low + high) / 2))
        local mid_sq=$((mid * mid))
        
        if [[ "$mid_sq" -eq "$num" ]]; then
            echo "$mid"
            return
        elif [[ "$mid_sq" -lt "$num" ]]; then
            low=$((mid + 1))
            result="$mid"
        else
            high=$((mid - 1))
        fi
    done
    
    echo "$result"
}

# Check if number is in range
in_range() {
    local num="$1"
    local min="$2"
    local max="$3"
    
    [[ "$num" -ge "$min" && "$num" -le "$max" ]]
}

# Clamp number to range
clamp() {
    local num="$1"
    local min="$2"
    local max="$3"
    
    if [[ "$num" -lt "$min" ]]; then
        echo "$min"
    elif [[ "$num" -gt "$max" ]]; then
        echo "$max"
    else
        echo "$num"
    fi
}

# Number base conversion
dec_to_bin() {
    local num="$1"
    local result=""
    local remainder
    
    if [[ "$num" -eq 0 ]]; then
        echo "0"
        return
    fi
    
    while [[ "$num" -gt 0 ]]; do
        remainder=$((num % 2))
        result="${remainder}${result}"
        num=$((num / 2))
    done
    
    echo "$result"
}

dec_to_hex() {
    local num="$1"
    local result=""
    local remainder
    local hex_chars="0123456789ABCDEF"
    
    if [[ "$num" -eq 0 ]]; then
        echo "0"
        return
    fi
    
    while [[ "$num" -gt 0 ]]; do
        remainder=$((num % 16))
        result="${hex_chars:$remainder:1}${result}"
        num=$((num / 16))
    done
    
    echo "$result"
}

# Parse number from string (validation)
is_number() {
    local str="$1"
    [[ "$str" =~ ^-?[0-9]+$ ]]
}

# Safe arithmetic with validation
safe_add() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Invalid numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    add "$a" "$b"
}

safe_sub() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Invalid numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    sub "$a" "$b"
}

safe_mul() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Invalid numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    mul "$a" "$b"
}

safe_div() {
    local a="$1"
    local b="$2"
    
    if ! is_number "$a" || ! is_number "$b"; then
        error "Invalid numbers"
        return ${EXIT_FAILURE:-1}
    fi
    
    div "$a" "$b"
}

# Random number utilities
random_int() {
    local min="${1:-0}"
    local max="${2:-32767}"
    
    if [[ "$min" -gt "$max" ]]; then
        local temp="$min"
        min="$max"
        max="$temp"
    fi
    
    local range=$((max - min + 1))
    echo $((min + RANDOM % range))
}

random_float() {
    local min="${1:-0}"
    local max="${2:-1}"
    
    if command -v awk > /dev/null; then
        awk "BEGIN{srand(); print $min + ($max - $min) * rand()}"
    else
        # Fallback to integer
        random_int "$min" "$max"
    fi
}

# Export module functions
export_module math.basic \
    add sub subtract mul multiply div divide mod pow power \
    eq equal ne not_equal lt less le less_equal gt greater ge greater_equal \
    min max min_array max_array sum avg \
    abs fact gcd lcm \
    is_even is_odd is_prime \
    fib fib_n sqrt_int \
    in_range clamp \
    dec_to_bin dec_to_hex \
    is_number \
    safe_add safe_sub safe_mul safe_div \
    random_int random_float