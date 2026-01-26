#!/usr/bin/bash

# File System Module - Advanced file operations
module_version "fs" "1.0.0"

# File operations
read_lines() {
    local file="$1"
    local start="${2:-1}"
    local count="${3:--1}"
    
    if [[ -f "$file" ]]; then
        tail -n "+$start" "$file" | head -n "$count"
    fi
}

write_lines() {
    local file="$1"
    shift
    local -a lines=("$@")
    
    printf "%s\n" "${lines[@]}" > "$file"
}

append_lines() {
    local file="$1"
    shift
    local -a lines=("$@")
    
    printf "%s\n" "${lines[@]}" >> "$file"
}

# Directory operations
create_dir() {
    local dir="$1"
    local mode="${2:-755}"
    
    mkdir -p "$dir"
    chmod "$mode" "$dir"
}

remove_dir() {
    local dir="$1"
    local recursive="${2:-false}"
    
    if [[ "$recursive" == "true" ]]; then
        rm -rf "$dir"
    else
        rmdir "$dir" 2>/dev/null || rm -d "$dir" 2>/dev/null
    fi
}

copy_tree() {
    local src="$1"
    local dst="$2"
    
    if [[ -d "$src" ]]; then
        cp -r "$src" "$dst"
    else
        error "Source directory '$src' does not exist"
        return 1
    fi
}

move_tree() {
    local src="$1"
    local dst="$2"
    
    if [[ -e "$src" ]]; then
        mv "$src" "$dst"
    else
        error "Source '$src' does not exist"
        return 1
    fi
}

# File search
find_files() {
    local dir="${1:-.}"
    local pattern="${2:-*}"
    local maxdepth="${3:-}"
    
    local cmd="find \"$dir\" -name \"$pattern\""
    if [[ -n "$maxdepth" ]]; then
        cmd="$cmd -maxdepth $maxdepth"
    fi
    
    eval "$cmd" 2>/dev/null
}

find_by_content() {
    local dir="${1:-.}"
    local pattern="$2"
    local file_pattern="${3:-*}"
    
    find "$dir" -name "$file_pattern" -exec grep -l "$pattern" {} \; 2>/dev/null
}

# File information
get_size() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null
    elif [[ -d "$file" ]]; then
        du -sb "$file" 2>/dev/null | cut -f1 || du -sk "$file" 2>/dev/null | cut -f1
    fi
}

get_modified() {
    local file="$1"
    
    stat -c%Y "$file" 2>/dev/null || stat -f%m "$file" 2>/dev/null
}

get_permissions() {
    local file="$1"
    
    stat -c%A "$file" 2>/dev/null || stat -f%Mp%Lp "$file" 2>/dev/null
}

# File utilities
is_empty() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        [[ ! -s "$file" ]]
    elif [[ -d "$file" ]]; then
        [[ -z "$(ls -A "$file" 2>/dev/null)" ]]
    else
        return 1
    fi
}

is_executable() {
    local file="$1"
    [[ -x "$file" ]]
}

is_readable() {
    local file="$1"
    [[ -r "$file" ]]
}

is_writable() {
    local file="$1"
    [[ -w "$file" ]]
}

# File backups
backup_file() {
    local file="$1"
    local backup_dir="${2:- backups}"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [[ -f "$file" ]]; then
        mkdir -p "$backup_dir"
        cp "$file" "$backup_dir/${file##*/}.$timestamp"
        success "Backup created: $backup_dir/${file##*/}.$timestamp"
    else
        error "File '$file' not found"
        return 1
    fi
}

restore_file() {
    local backup="$1"
    local target="${2:-}"
    
    if [[ -z "$target" ]]; then
        # Remove timestamp from backup name
        target=$(echo "$backup" | sed 's/\.[0-9_]\{8\}_[0-9]\{6\}$//')
        target="${target##*/}"
    fi
    
    if [[ -f "$backup" ]]; then
        cp "$backup" "$target"
        success "File restored: $target"
    else
        error "Backup '$backup' not found"
        return 1
    fi
}

# File compression
compress() {
    local file="$1"
    local format="${2:-gz}"
    
    case "$format" in
        "gz"|"gzip")
            gzip -c "$file" > "${file}.gz"
            ;;
        "bz2"|"bzip2")
            bzip2 -c "$file" > "${file}.bz2"
            ;;
        "xz")
            xz -c "$file" > "${file}.xz"
            ;;
        "zip")
            zip "${file}.zip" "$file"
            ;;
        *)
            error "Unsupported compression format: $format"
            return 1
            ;;
    esac
    
    success "File compressed: ${file}.$format"
}

decompress() {
    local file="$1"
    
    case "$file" in
        *.gz)
            gzip -d "$file"
            ;;
        *.bz2)
            bzip2 -d "$file"
            ;;
        *.xz)
            xz -d "$file"
            ;;
        *.zip)
            unzip "$file"
            ;;
        *)
            error "Unknown compressed file format: $file"
            return 1
            ;;
    esac
}

# File synchronization
sync_dirs() {
    local src="$1"
    local dst="$2"
    local options="${3:-av}"
    
    if [[ -d "$src" ]] && [[ -d "$dst" ]]; then
        rsync -$options "$src/" "$dst/"
        success "Directories synchronized: $src -> $dst"
    else
        error "Both source and destination must be directories"
        return 1
    fi
}

# File monitoring
watch_file() {
    local file="$1"
    local command="$2"
    
    if [[ -f "$file" ]]; then
        while true; do
            if [[ "$file" -nt "/tmp/.watch_$(basename "$file")" ]]; then
                touch "/tmp/.watch_$(basename "$file")"
                if [[ -n "$command" ]]; then
                    eval "$command"
                else
                    info "File changed: $file"
                fi
            fi
            sleep 1
        done
    else
        error "File '$file' not found"
        return 1
    fi
}

# File validation
validate_checksum() {
    local file="$1"
    local expected="$2"
    local algorithm="${3:-md5}"
    
    if [[ ! -f "$file" ]]; then
        error "File '$file' not found"
        return 1
    fi
    
    local actual
    case "$algorithm" in
        "md5")
            actual=$(md5sum "$file" | cut -d' ' -f1)
            ;;
        "sha1")
            actual=$(sha1sum "$file" | cut -d' ' -f1)
            ;;
        "sha256")
            actual=$(sha256sum "$file" | cut -d' ' -f1)
            ;;
        *)
            error "Unsupported algorithm: $algorithm"
            return 1
            ;;
    esac
    
    if [[ "$actual" == "$expected" ]]; then
        success "Checksum validated: $file"
        return 0
    else
        error "Checksum mismatch: $file"
        return 1
    fi
}

# Export functions
export_module "fs" read_lines write_lines append_lines create_dir remove_dir copy_tree move_tree find_files find_by_content get_size get_modified get_permissions is_empty is_executable is_readable is_writable backup_file restore_file compress decompress sync_dirs watch_file validate_checksum