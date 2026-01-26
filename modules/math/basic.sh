#!/usr/bin/bash

# Math Basic Module - Basic arithmetic operations
module_version "math.basic" "1.0.0"

# Basic arithmetic
add() { echo $(($1 + $2)); }
subtract() { echo $(($1 - $2)); }
multiply() { echo $(($1 * $2)); }
divide() { 
    if [[ $2 -eq 0 ]]; then 
        error "Division by zero"
        return ${EXIT_FAILURE}
    fi
    echo $(($1 / $2))
}

# Modulo and power
mod() { echo $(($1 % $2)); }
power() { echo $(($1 ** $2)); }

# Comparison
equal() { [[ $1 -eq $2 ]]; }
not_equal() { [[ $1 -ne $2 ]]; }
greater() { [[ $1 -gt $2 ]]; }
greater_equal() { [[ $1 -ge $2 ]]; }
less() { [[ $1 -lt $2 ]]; }
less_equal() { [[ $1 -le $2 ]]; }

# Min/Max
max() { 
    local max_val=$1
    for val in "${@:2}"; do
        if [[ $val -gt $max_val ]]; then
            max_val=$val
        fi
    done
    echo $max_val
}

min() { 
    local min_val=$1
    for val in "${@:2}"; do
        if [[ $val -lt $min_val ]]; then
            min_val=$val
        fi
    done
    echo $min_val
}

# Range check
in_range() { [[ $1 -ge $2 && $1 -le $3 ]]; }
clamp() {
    local val=$1 min=$2 max=$3
    if [[ $val -lt $min ]]; then echo $min; 
    elif [[ $val -gt $max ]]; then echo $max; 
    else echo $val; fi
}

# Export functions
export_module "math.basic" add subtract multiply divide mod power equal not_equal greater greater_equal less less_equal max min in_range clamp