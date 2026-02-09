#!/bin/bash

# String Module
# Provides string manipulation, validation, and formatting utilities

module_version string 1.0.0

# String length
strlen() {
    local str="$1"
    echo "${#str}"
}

length() {
    strlen "$@"
}

# String manipulation
substr() {
    local str="$1"
    local start="$2"
    local length="${3:-}"
    
    if [[ -n "$length" ]]; then
        echo "${str:$start:$length}"
    else
        echo "${str:$start}"
    fi
}

substring() {
    substr "$@"
}

# String concatenation
concat() {
    local result=""
    for str in "$@"; do
        result="${result}${str}"
    done
    echo "$result"
}

# String repetition
repeat_str() {
    local str="$1"
    local count="$2"
    local result=""
    
    for ((i=0; i<count; i++)); do
        result="${result}${str}"
    done
    
    echo "$result"
}

repeat() {
    repeat_str "$@"
}

# String case conversion
to_upper() {
    local str="$1"
    echo "${str^^}"
}

to_lower() {
    local str="$1"
    echo "${str,,}"
}

capitalize() {
    to_upper "${1:0:1}${1:1}"
}

to_title() {
    local str="$1"
    local result=""
    local prev_char=" "
    
    for ((i=0; i<${#str}; i++)); do
        local char="${str:$i:1}"
        if [[ "$prev_char" == " " ]]; then
            result="${result}${char^^}"
        else
            result="${result}${char,,}"
        fi
        prev_char="$char"
    done
    
    echo "$result"
}

# String trimming
ltrim() {
    local str="$1"
    echo "${str#"${str%%[![:space:]]*}"}"
}

rtrim() {
    local str="$1"
    echo "${str%"${str##*[![:space:]]}"}"
}

trim() {
    local str="$1"
    rtrim "$(ltrim "$str")"
}

# String padding
lpad() {
    local str="$1"
    local length="$2"
    local pad_char="${3:- }"
    local str_len="${#str}"
    
    if [[ "$str_len" -ge "$length" ]]; then
        echo "$str"
        return
    fi
    
    local pad_len=$((length - str_len))
    local padding=$(repeat_str "$pad_char" "$pad_len")
    echo "${padding}${str}"
}

pad_left() {
    lpad "$@"
}

rpad() {
    local str="$1"
    local length="$2"
    local pad_char="${3:- }"
    local str_len="${#str}"
    
    if [[ "$str_len" -ge "$length" ]]; then
        echo "$str"
        return
    fi
    
    local pad_len=$((length - str_len))
    local padding=$(repeat_str "$pad_char" "$pad_len")
    echo "${str}${padding}"
}

pad_right() {
    rpad "$@"
}

# String search and replace
indexof() {
    local str="$1"
    local substr="$2"
    local start="${3:-0}"
    
    local search_str="${str:$start}"
    local pos="${search_str%%"$substr"*}"
    
    if [[ "$pos" == "$search_str" ]]; then
        echo "-1"
    else
        echo $((start + ${#pos}))
    fi
}

contains() {
    local str="$1"
    local substr="$2"
    [[ "$str" == *"$substr"* ]]
}

startswith() {
    local str="$1"
    local prefix="$2"
    [[ "$str" == "$prefix"* ]]
}

starts_with() {
    startswith "$@"
}

endswith() {
    local str="$1"
    local suffix="$2"
    [[ "$str" == *"$suffix" ]]
}

ends_with() {
    endswith "$@"
}

replace() {
    local str="$1"
    local old="$2"
    local new="$3"
    echo "${str//$old/$new}"
}

replace_first() {
    local str="$1"
    local old="$2"
    local new="$3"
    echo "${str/$old/$new}"
}

# String splitting
split() {
    local str="$1"
    local delimiter="${2:- }"
    local -a result
    
    IFS="$delimiter" read -ra result <<< "$str"
    printf '%s\n' "${result[@]}"
}

split_lines() {
    local str="$1"
    local -a result
    
    mapfile -t result <<< "$str"
    printf '%s\n' "${result[@]}"
}

# String joining
join() {
    local delimiter="$1"
    shift
    local first="$1"
    shift
    
    local result="$first"
    for item in "$@"; do
        result="${result}${delimiter}${item}"
    done
    
    echo "$result"
}

# String validation
is_empty() {
    local str="$1"
    [[ -z "$str" ]]
}

is_not_empty() {
    local str="$1"
    [[ -n "$str" ]]
}

is_alpha() {
    local str="$1"
    [[ "$str" =~ ^[a-zA-Z]+$ ]]
}

is_alnum() {
    local str="$1"
    [[ "$str" =~ ^[a-zA-Z0-9]+$ ]]
}

is_alphanumeric() {
    is_alnum "$@"
}

is_numeric() {
    local str="$1"
    [[ "$str" =~ ^[0-9]+$ ]]
}

is_email() {
    local str="$1"
    [[ "$str" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

is_url() {
    local str="$1"
    [[ "$str" =~ ^https?://[a-zA-Z0-9.-]+(\.[a-zA-Z]{2,})?(/.*)?$ ]]
}

is_ip() {
    local str="$1"
    local ip_regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    
    if [[ ! "$str" =~ $ip_regex ]]; then
        return 1
    fi
    
    # Check each octet is <= 255
    IFS='.' read -ra octets <<< "$str"
    for octet in "${octets[@]}"; do
        if [[ "$octet" -gt 255 ]]; then
            return 1
        fi
    done
    
    return 0
}

# String transformation
reverse() {
    local str="$1"
    local reversed=""
    local len="${#str}"
    
    for ((i=len-1; i>=0; i--)); do
        reversed="${reversed}${str:$i:1}"
    done
    
    echo "$reversed"
}

shuffle() {
    local str="$1"
    local chars=()
    local shuffled=""
    
    # Convert to array
    for ((i=0; i<${#str}; i++)); do
        chars+=("${str:$i:1}")
    done
    
    # Fisher-Yates shuffle
    local len=${#chars[@]}
    for ((i=len-1; i>0; i--)); do
        local j=$((RANDOM % (i + 1)))
        local temp="${chars[$i]}"
        chars[$i]="${chars[$j]}"
        chars[$j]="$temp"
    done
    
    # Convert back to string
    for char in "${chars[@]}"; do
        shuffled="${shuffled}${char}"
    done
    
    echo "$shuffled"
}

# String counting
count_chars() {
    local str="$1"
    local char="$2"
    local count=0
    
    for ((i=0; i<${#str}; i++)); do
        if [[ "${str:$i:1}" == "$char" ]]; then
            ((count++))
        fi
    done
    
    echo "$count"
}

count() {
    count_chars "$@"
}

count_substrings() {
    local str="$1"
    local substr="$2"
    local count=0
    local pos=0
    
    while [[ $pos -lt ${#str} ]]; do
        local found=$(indexof "$str" "$substr" "$pos")
        if [[ "$found" -eq -1 ]]; then
            break
        fi
        ((count++))
        pos=$((found + ${#substr}))
    done
    
    echo "$count"
}

# String formatting
center() {
    local str="$1"
    local width="$2"
    local pad_char="${3:- }"
    local str_len="${#str}"
    
    if [[ "$str_len" -ge "$width" ]]; then
        echo "$str"
        return
    fi
    
    local total_pad=$((width - str_len))
    local left_pad=$((total_pad / 2))
    local right_pad=$((total_pad - left_pad))
    
    local left_padding=$(repeat_str "$pad_char" "$left_pad")
    local right_padding=$(repeat_str "$pad_char" "$right_pad")
    
    echo "${left_padding}${str}${right_padding}"
}

# String escaping
escape_regex() {
    local str="$1"
    echo "$str" | sed 's/[][\.()*?{}|^$+]/\\&/g'
}

escape_shell() {
    local str="$1"
    printf '%q' "$str"
}

escape_html() {
    local str="$1"
    local result="$str"
    result="${result//&/&amp;}"
    result="${result//</&lt;}"
    result="${result//>/&gt;}"
    result="${result//\"/&quot;}"
    result="${result//'/&#39;}"
    echo "$result"
}

unescape_html() {
    local str="$1"
    local result="$str"
    result="${result//&amp;/&}"
    result="${result//&lt;/</}"
    result="${result//&gt;/>}"
    result="${result//&quot;/\"}"
    result="${result//&#39;/'}"
    echo "$result"
}

# String comparison (case-insensitive)
equals_ignore_case() {
    local str1="$1"
    local str2="$2"
    [[ "${str1,,}" == "${str2,,}" ]]
}

contains_ignore_case() {
    local str="$1"
    local substr="$2"
    local lower_str="${str,,}"
    local lower_substr="${substr,,}"
    [[ "$lower_str" == *"$lower_substr"* ]]
}

# String hashing (simple)
hash_string() {
    local str="$1"
    local hash=0
    
    for ((i=0; i<${#str}; i++)); do
        local char_code=$(printf "%d" "'${str:$i:1}")
        hash=$(((hash * 31 + char_code) % 2147483647))
    done
    
    echo "$hash"
}

# String to array conversion
to_chars() {
    local str="$1"
    local -a result
    
    result=()
    for ((i=0; i<${#str}; i++)); do
        result+=("${str:$i:1}")
    done
    
    printf '%s\n' "${result[@]}"
}

to_words() {
    local str="$1"
    local -a result
    
    read -ra result <<< "$str"
    printf '%s\n' "${result[@]}"
}

# String utilities
uuid() {
    if command -v uuidgen > /dev/null; then
        uuidgen
    elif [[ -f /proc/sys/kernel/random/uuid ]]; then
        cat /proc/sys/kernel/random/uuid
    else
        # Fallback: simple UUID-like string
        printf "%04x%04x-%04x-%04x-%04x-%04x%04x%04x" \
            $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM $RANDOM
    fi
}

random_string() {
    local length="${1:-10}"
    local charset="${2:-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789}"
    local result=""
    
    for ((i=0; i<length; i++)); do
        local pos=$((RANDOM % ${#charset}))
        result="${result}${charset:$pos:1}"
    done
    
    echo "$result"
}

# Export module functions
export_module string \
    strlen length substr substring concat repeat_str repeat \
    to_upper to_lower capitalize to_title \
    ltrim rtrim trim \
    lpad pad_left rpad pad_right \
    indexof contains startswith starts_with endswith ends_with replace replace_first \
    split split_lines join \
    is_empty is_not_empty is_alpha is_alnum is_alphanumeric is_numeric is_email is_url is_ip \
    reverse shuffle \
    count_chars count count_substrings \
    center \
    escape_regex escape_shell escape_html unescape_html \
    equals_ignore_case contains_ignore_case \
    hash_string \
    to_chars to_words \
    uuid random_string