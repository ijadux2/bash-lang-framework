#!/usr/bin/bash

# String Module - String manipulation utilities
module_version "string" "1.0.0"

# Basic operations
length() { echo "${#1}"; }
substring() { echo "${1:$2:$3}"; }
concat() { echo "$1$2"; }

# Case conversion
to_upper() { echo "${1^^}"; }
to_lower() { echo "${1,,}"; }
capitalize() { echo "${1^}"; }

# Trimming
trim() { echo "$1" | xargs; }
ltrim() { echo "$1" | sed 's/^[[:space:]]*//'; }
rtrim() { echo "$1" | sed 's/[[:space:]]*$//'; }

# Search and replace
contains() { [[ "$1" == *"$2"* ]]; }
starts_with() { [[ "$1" == "$2"* ]]; }
ends_with() { [[ "$1" == *"$2" ]]; }
replace() { echo "${1//$2/$3}"; }
replace_first() { echo "${1/$2/$3}"; }

# Splitting and joining
split() {
    local string="$1"
    local delimiter="$2"
    local -a result
    IFS="$delimiter" read -ra result <<< "$string"
    printf '%s\n' "${result[@]}"
}

join() {
    local delimiter="$1"
    shift
    local first="$1"
    shift
    printf %s "$first" "${@/#/$delimiter}"
}

# Padding
pad_left() {
    local str="$1" len="$2" char="${3:- }"
    printf "%*s" "$len" "$str" | tr ' ' "$char"
}

pad_right() {
    local str="$1" len="$2" char="${3:- }"
    printf "%-${len}s" "$str" | tr ' ' "$char"
}

# Repeat
repeat() { printf "%*s" "$1" | tr ' ' "$2"; }

# Reverse
reverse() { echo "$1" | rev; }

# Count occurrences
count() { echo "$1" | grep -o "$2" | wc -l; }

# Validation
is_empty() { [[ -z "$1" ]]; }
is_numeric() { [[ "$1" =~ ^[0-9]+$ ]]; }
is_alpha() { [[ "$1" =~ ^[a-zA-Z]+$ ]]; }
is_alphanumeric() { [[ "$1" =~ ^[a-zA-Z0-9]+$ ]]; }

# Export functions
export_module "string" length substring concat to_upper to_lower capitalize trim ltrim rtrim contains starts_with ends_with replace replace_first split join pad_left pad_right repeat reverse count is_empty is_numeric is_alpha is_alphanumeric