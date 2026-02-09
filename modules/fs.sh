#!/bin/bash

# File System Module
# Provides comprehensive file system operations and utilities

module_version fs 1.0.0

# Directory operations
create_dir() {
    local dir="$1"
    local mode="${2:-755}"
    
    if [[ -z "$dir" ]]; then
        error "Directory path required"
        return ${EXIT_FAILURE:-1}
    fi
    
    if mkdir -p "$dir"; then
        chmod "$mode" "$dir" 2>/dev/null || true
        success "Directory created: $dir"
        return 0
    else
        error "Failed to create directory: $dir"
        return ${EXIT_FAILURE:-1}
    fi
}

remove_dir() {
    local dir="$1"
    local recursive="${2:-false}"
    
    if [[ ! -d "$dir" ]]; then
        error "Directory not found: $dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ "$recursive" == "true" ]]; then
        rm -rf "$dir"
    else
        rmdir "$dir" 2>/dev/null || {
            error "Directory not empty: $dir"
            return ${EXIT_FAILURE:-1}
        }
    fi
    
    success "Directory removed: $dir"
    return 0
}

copy_dir() {
    local src="$1"
    local dest="$2"
    local recursive="${3:-true}"
    
    if [[ ! -d "$src" ]]; then
        error "Source directory not found: $src"
        return ${EXIT_FAILURE:-1}
    fi
    
    local opts=""
    if [[ "$recursive" == "true" ]]; then
        opts="-r"
    fi
    
    if cp $opts "$src" "$dest"; then
        success "Directory copied: $src -> $dest"
        return 0
    else
        error "Failed to copy directory: $src -> $dest"
        return ${EXIT_FAILURE:-1}
    fi
}

copy_tree() {
    copy_dir "$@"
}

move_dir() {
    local src="$1"
    local dest="$2"
    
    if [[ ! -d "$src" ]]; then
        error "Source directory not found: $src"
        return ${EXIT_FAILURE:-1}
    fi
    
    if mv "$src" "$dest"; then
        success "Directory moved: $src -> $dest"
        return 0
    else
        error "Failed to move directory: $src -> $dest"
        return ${EXIT_FAILURE:-1}
    fi
}

move_tree() {
    move_dir "$@"
}

# File operations
create_file() {
    local file="$1"
    local content="${2:-}"
    local mode="${3:-644}"
    
    if [[ -z "$file" ]]; then
        error "File path required"
        return ${EXIT_FAILURE:-1}
    fi
    
    local dir
    dir=$(dirname "$file")
    if [[ ! -d "$dir" ]]; then
        create_dir "$dir"
    fi
    
    if echo "$content" > "$file"; then
        chmod "$mode" "$file" 2>/dev/null || true
        success "File created: $file"
        return 0
    else
        error "Failed to create file: $file"
        return ${EXIT_FAILURE:-1}
    fi
}

remove_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    if rm "$file"; then
        success "File removed: $file"
        return 0
    else
        error "Failed to remove file: $file"
        return ${EXIT_FAILURE:-1}
    fi
}

copy_file() {
    local src="$1"
    local dest="$2"
    local preserve="${3:-true}"
    
    if [[ ! -f "$src" ]]; then
        error "Source file not found: $src"
        return ${EXIT_FAILURE:-1}
    fi
    
    local opts=""
    if [[ "$preserve" == "true" ]]; then
        opts="-p"
    fi
    
    local dest_dir
    dest_dir=$(dirname "$dest")
    if [[ ! -d "$dest_dir" ]]; then
        create_dir "$dest_dir"
    fi
    
    if cp $opts "$src" "$dest"; then
        success "File copied: $src -> $dest"
        return 0
    else
        error "Failed to copy file: $src -> $dest"
        return ${EXIT_FAILURE:-1}
    fi
}

move_file() {
    local src="$1"
    local dest="$2"
    
    if [[ ! -f "$src" ]]; then
        error "Source file not found: $src"
        return ${EXIT_FAILURE:-1}
    fi
    
    local dest_dir
    dest_dir=$(dirname "$dest")
    if [[ ! -d "$dest_dir" ]]; then
        create_dir "$dest_dir"
    fi
    
    if mv "$src" "$dest"; then
        success "File moved: $src -> $dest"
        return 0
    else
        error "Failed to move file: $src -> $dest"
        return ${EXIT_FAILURE:-1}
    fi
}

# File line operations
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

# File search and filtering
find_files() {
    local path="${1:-.}"
    local pattern="${2:-*}"
    local -n result_ref="$3"
    local max_depth="${4:-}"
    
    local find_cmd="find \"$path\" -type f -name \"$pattern\""
    
    if [[ -n "$max_depth" ]]; then
        find_cmd="$find_cmd -maxdepth $max_depth"
    fi
    
    mapfile -t result_ref < <(eval "$find_cmd" 2>/dev/null)
}

find_dirs() {
    local path="${1:-.}"
    local pattern="${2:-*}"
    local -n result_ref="$3"
    local max_depth="${4:-}"
    
    local find_cmd="find \"$path\" -type d -name \"$pattern\""
    
    if [[ -n "$max_depth" ]]; then
        find_cmd="$find_cmd -maxdepth $max_depth"
    fi
    
    mapfile -t result_ref < <(eval "$find_cmd" 2>/dev/null)
}

search_files() {
    local path="${1:-.}"
    local pattern="$2"
    local -n result_ref="$3"
    local case_sensitive="${4:-true}"
    
    local grep_opts="-r"
    if [[ "$case_sensitive" != "true" ]]; then
        grep_opts="$grep_opts -i"
    fi
    
    mapfile -t result_ref < <(grep $grep_opts "$pattern" "$path" 2>/dev/null | cut -d: -f1 | sort -u)
}

find_by_content() {
    local dir="${1:-.}"
    local pattern="$2"
    local file_pattern="${3:-*}"
    
    find "$dir" -name "$file_pattern" -exec grep -l "$pattern" {} \; 2>/dev/null
}

filter_files() {
    local -n files_ref="$1"
    local filter_func="$2"
    local -n result_ref="$3"
    
    result_ref=()
    for file in "${files_ref[@]}"; do
        if $filter_func "$file"; then
            result_ref+=("$file")
        fi
    done
}

# File information
get_file_info() {
    local file="$1"
    local -n result_ref="$2"
    
    if [[ ! -e "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    local stat_cmd="stat"
    if stat -c%s /dev/null > /dev/null 2>&1; then
        # Linux
        result_ref["size"]=$(stat -c%s "$file" 2>/dev/null || echo "0")
        result_ref["mode"]=$(stat -c%a "$file" 2>/dev/null || echo "000")
        result_ref["uid"]=$(stat -c%u "$file" 2>/dev/null || echo "0")
        result_ref["gid"]=$(stat -c%g "$file" 2>/dev/null || echo "0")
        result_ref["mtime"]=$(stat -c%Y "$file" 2>/dev/null || echo "0")
        result_ref["type"]=$(stat -c%F "$file" 2>/dev/null || echo "unknown")
    else
        # macOS/BSD
        result_ref["size"]=$(stat -f%z "$file" 2>/dev/null || echo "0")
        result_ref["mode"]=$(stat -f%Mp%Lp "$file" 2>/dev/null | sed 's/^0*//' || echo "000")
        result_ref["uid"]=$(stat -f%u "$file" 2>/dev/null || echo "0")
        result_ref["gid"]=$(stat -f%g "$file" 2>/dev/null || echo "0")
        result_ref["mtime"]=$(stat -f%m "$file" 2>/dev/null || echo "0")
        result_ref["type"]=$(stat -f%HT "$file" 2>/dev/null || echo "unknown")
    fi
    
    result_ref["name"]=$(basename "$file")
    result_ref["path"]=$(dirname "$file")
    result_ref["ext"]="${file##*.}"
    [[ "${result_ref["ext"]}" == "${result_ref["name"]}" ]] && result_ref["ext"]=""
}

get_file_hash() {
    local file="$1"
    local algorithm="${2:-md5}"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    case "$algorithm" in
        "md5")
            if command -v md5sum > /dev/null; then
                md5sum "$file" | cut -d' ' -f1
            elif command -v md5 > /dev/null; then
                md5 -q "$file"
            else
                error "md5 command not found"
                return ${EXIT_FAILURE:-1}
            fi
            ;;
        "sha1")
            if command -v sha1sum > /dev/null; then
                sha1sum "$file" | cut -d' ' -f1
            elif command -v shasum > /dev/null; then
                shasum -a 1 "$file" | cut -d' ' -f1
            else
                error "sha1 command not found"
                return ${EXIT_FAILURE:-1}
            fi
            ;;
        "sha256")
            if command -v sha256sum > /dev/null; then
                sha256sum "$file" | cut -d' ' -f1
            elif command -v shasum > /dev/null; then
                shasum -a 256 "$file" | cut -d' ' -f1
            else
                error "sha256 command not found"
                return ${EXIT_FAILURE:-1}
            fi
            ;;
        *)
            error "Unsupported hash algorithm: $algorithm"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
}

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
    
    if stat -c%a /dev/null > /dev/null 2>&1; then
        stat -c%a "$file" 2>/dev/null
    else
        stat -f%Mp%Lp "$file" 2>/dev/null | sed 's/^0*//'
    fi
}

# File comparison
compare_files() {
    local file1="$1"
    local file2="$2"
    local method="${3:-content}"
    
    if [[ ! -f "$file1" ]]; then
        error "File not found: $file1"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ ! -f "$file2" ]]; then
        error "File not found: $file2"
        return ${EXIT_FAILURE:-1}
    fi
    
    case "$method" in
        "content")
            cmp -s "$file1" "$file2"
            ;;
        "size")
            local size1 size2
            size1=$(get_file_size "$file1")
            size2=$(get_file_size "$file2")
            [[ "$size1" -eq "$size2" ]]
            ;;
        "hash")
            local hash1 hash2
            hash1=$(get_file_hash "$file1")
            hash2=$(get_file_hash "$file2")
            [[ "$hash1" == "$hash2" ]]
            ;;
        *)
            error "Unsupported comparison method: $method"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
}

# File permissions
set_permissions() {
    local path="$1"
    local mode="$2"
    local recursive="${3:-false}"
    
    if [[ ! -e "$path" ]]; then
        error "Path not found: $path"
        return ${EXIT_FAILURE:-1}
    fi
    
    local opts=""
    if [[ "$recursive" == "true" ]]; then
        opts="-R"
    fi
    
    if chmod $opts "$mode" "$path"; then
        success "Permissions set: $path -> $mode"
        return 0
    else
        error "Failed to set permissions: $path -> $mode"
        return ${EXIT_FAILURE:-1}
    fi
}

set_owner() {
    local path="$1"
    local owner="$2"
    local recursive="${3:-false}"
    
    if [[ ! -e "$path" ]]; then
        error "Path not found: $path"
        return ${EXIT_FAILURE:-1}
    fi
    
    local opts=""
    if [[ "$recursive" == "true" ]]; then
        opts="-R"
    fi
    
    if chown $opts "$owner" "$path"; then
        success "Owner set: $path -> $owner"
        return 0
    else
        error "Failed to set owner: $path -> $owner"
        return ${EXIT_FAILURE:-1}
    fi
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
    local backup_dir="${2:-./backups}"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_name="$(basename "$file").$timestamp.bak"
    local backup_path="$backup_dir/$backup_name"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    mkdir -p "$backup_dir" || {
        error "Cannot create backup directory: $backup_dir"
        return ${EXIT_FAILURE:-1}
    }
    
    cp "$file" "$backup_path" || {
        error "Cannot create backup: $backup_path"
        return ${EXIT_FAILURE:-1}
    }
    
    echo "Backup created: $backup_path"
    return 0
}

restore_file() {
    local backup="$1"
    local target="${2:-}"
    
    if [[ ! -f "$backup" ]]; then
        error "Backup file not found: $backup"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ -z "$target" ]]; then
        # Remove timestamp and .bak extension
        target=$(basename "$backup" | sed 's/\.[0-9]\{8\}_[0-9]\{6\}\.bak$//')
    fi
    
    cp "$backup" "$target" || {
        error "Cannot restore file: $target"
        return ${EXIT_FAILURE:-1}
    }
    
    echo "File restored: $target"
    return 0
}

# File compression and archiving
compress_file() {
    local file="$1"
    local method="${2:-gzip}"
    local remove_original="${3:-true}"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    case "$method" in
        "gzip")
            if gzip "$file"; then
                success "File compressed: $file.gz"
                return 0
            fi
            ;;
        "bzip2")
            if bzip2 "$file"; then
                success "File compressed: $file.bz2"
                return 0
            fi
            ;;
        "xz")
            if xz "$file"; then
                success "File compressed: $file.xz"
                return 0
            fi
            ;;
        *)
            error "Unsupported compression method: $method"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
    
    error "Failed to compress file: $file"
    return ${EXIT_FAILURE:-1}
}

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

decompress_file() {
    local file="$1"
    local dest="${2:-}"
    
    if [[ ! -f "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    case "$file" in
        *.gz)
            if [[ -n "$dest" ]]; then
                gunzip -c "$file" > "$dest"
            else
                gunzip "$file"
            fi
            ;;
        *.bz2)
            if [[ -n "$dest" ]]; then
                bunzip2 -c "$file" > "$dest"
            else
                bunzip2 "$file"
            fi
            ;;
        *.xz)
            if [[ -n "$dest" ]]; then
                unxz -c "$file" > "$dest"
            else
                unxz "$file"
            fi
            ;;
        *)
            error "Unsupported compression format: $file"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
    
    success "File decompressed: $file"
    return 0
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

create_archive() {
    local archive="$1"
    shift
    local sources=("$@")
    local method="${archive##*.}"
    
    case "$method" in
        "tar")
            if tar -cf "$archive" "${sources[@]}"; then
                success "Archive created: $archive"
                return 0
            fi
            ;;
        "tar.gz"|"tgz")
            if tar -czf "$archive" "${sources[@]}"; then
                success "Archive created: $archive"
                return 0
            fi
            ;;
        "tar.bz2"|"tbz")
            if tar -cjf "$archive" "${sources[@]}"; then
                success "Archive created: $archive"
                return 0
            fi
            ;;
        "tar.xz"|"txz")
            if tar -cJf "$archive" "${sources[@]}"; then
                success "Archive created: $archive"
                return 0
            fi
            ;;
        "zip")
            if zip -r "$archive" "${sources[@]}"; then
                success "Archive created: $archive"
                return 0
            fi
            ;;
        *)
            error "Unsupported archive format: $method"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
    
    error "Failed to create archive: $archive"
    return ${EXIT_FAILURE:-1}
}

extract_archive() {
    local archive="$1"
    local dest="${2:-.}"
    
    if [[ ! -f "$archive" ]]; then
        error "Archive not found: $archive"
        return ${EXIT_FAILURE:-1}
    fi
    
    mkdir -p "$dest"
    
    case "$archive" in
        *.tar)
            if tar -xf "$archive" -C "$dest"; then
                success "Archive extracted: $archive"
                return 0
            fi
            ;;
        *.tar.gz|*.tgz)
            if tar -xzf "$archive" -C "$dest"; then
                success "Archive extracted: $archive"
                return 0
            fi
            ;;
        *.tar.bz2|*.tbz)
            if tar -xjf "$archive" -C "$dest"; then
                success "Archive extracted: $archive"
                return 0
            fi
            ;;
        *.tar.xz|*.txz)
            if tar -xJf "$archive" -C "$dest"; then
                success "Archive extracted: $archive"
                return 0
            fi
            ;;
        *.zip)
            if unzip -q "$archive" -d "$dest"; then
                success "Archive extracted: $archive"
                return 0
            fi
            ;;
        *)
            error "Unsupported archive format: $archive"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
    
    error "Failed to extract archive: $archive"
    return ${EXIT_FAILURE:-1}
}

# File synchronization
sync_files() {
    local src="$1"
    local dest="$2"
    local method="${3:-rsync}"
    local delete="${4:-false}"
    local opts="${5:-}"
    
    if [[ ! -e "$src" ]]; then
        error "Source not found: $src"
        return ${EXIT_FAILURE:-1}
    fi
    
    case "$method" in
        "rsync")
            local rsync_opts="-av"
            if [[ "$delete" == "true" ]]; then
                rsync_opts="$rsync_opts --delete"
            fi
            if [[ -n "$opts" ]]; then
                rsync_opts="$rsync_opts $opts"
            fi
            
            if rsync $rsync_opts "$src/" "$dest/"; then
                success "Files synchronized: $src -> $dest"
                return 0
            fi
            ;;
        "cp")
            if [[ -d "$src" ]]; then
                if cp -r "$src/"* "$dest/"; then
                    success "Files synchronized: $src -> $dest"
                    return 0
                fi
            else
                if cp "$src" "$dest"; then
                    success "Files synchronized: $src -> $dest"
                    return 0
                fi
            fi
            ;;
        *)
            error "Unsupported sync method: $method"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
    
    error "Failed to synchronize files: $src -> $dest"
    return ${EXIT_FAILURE:-1}
}

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

# File validation
validate_file_path() {
    local path="$1"
    
    # Check if path is absolute or relative
    if [[ "$path" =~ ^/ ]]; then
        # Absolute path
        [[ -d "$(dirname "$path")" ]]
    else
        # Relative path
        [[ -d "$(dirname "$(pwd)/$path")" ]]
    fi
}

validate_filename() {
    local filename="$1"
    
    # Check for invalid characters
    [[ -n "$filename" ]]
}

sanitize_filename() {
    local filename="$1"
    local replacement="${2:-_}"
    
    # Replace invalid characters
    echo "$filename" | tr '/:*?"<>|' "$replacement"
}
    
    # Replace invalid characters
    echo "$filename" | sed 's/[\/:*?"<>|]/'"$replacement"'/g'

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

# File monitoring
watch_file() {
    local file="$1"
    local command="$2"
    local interval="${3:-1}"
    
    if [[ ! -e "$file" ]]; then
        error "File not found: $file"
        return ${EXIT_FAILURE:-1}
    fi
    
    local mtime
    mtime=$(get_file_info "$file" mtime)
    
    while true; do
        sleep "$interval"
        local new_mtime
        new_mtime=$(get_file_info "$file" mtime)
        
        if [[ "$new_mtime" -ne "$mtime" ]]; then
            mtime="$new_mtime"
            eval "$command"
        fi
    done
}

# Disk usage analysis
analyze_disk_usage() {
    local path="${1:-.}"
    local -n result_ref="$2"
    local max_depth="${3:-1}"
    
    if [[ ! -d "$path" ]]; then
        error "Directory not found: $path"
        return ${EXIT_FAILURE:-1}
    fi
    
    # Get disk usage for directories
    local -a usage_data
    mapfile -t usage_data < <(du -h --max-depth="$max_depth" "$path" 2>/dev/null | sort -hr)
    
    result_ref=()
    for line in "${usage_data[@]}"; do
        local size dir_path
        size=$(echo "$line" | awk '{print $1}')
        dir_path=$(echo "$line" | cut -f2-)
        result_ref+=("$size|$dir_path")
    done
}

# Cleanup operations
cleanup_temp_files() {
    local dir="${1:-/tmp}"
    local pattern="${2:-*}"
    local max_age="${3:-7}"  # days
    
    if [[ ! -d "$dir" ]]; then
        error "Directory not found: $dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    local find_cmd="find \"$dir\" -name \"$pattern\" -type f -mtime +$max_age -delete"
    if eval "$find_cmd" 2>/dev/null; then
        success "Temporary files cleaned up in: $dir"
        return 0
    else
        error "Failed to cleanup temporary files in: $dir"
        return ${EXIT_FAILURE:-1}
    fi
}

cleanup_empty_dirs() {
    local dir="${1:-.}"
    local max_depth="${2:-}"
    
    if [[ ! -d "$dir" ]]; then
        error "Directory not found: $dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    local find_cmd="find \"$dir\" -type d -empty -delete"
    if [[ -n "$max_depth" ]]; then
        find_cmd="find \"$dir\" -maxdepth $max_depth -type d -empty -delete"
    fi
    
    if eval "$find_cmd" 2>/dev/null; then
        success "Empty directories cleaned up in: $dir"
        return 0
    else
        error "Failed to cleanup empty directories in: $dir"
        return ${EXIT_FAILURE:-1}
    fi
}

# Export module functions
export_module fs \
    create_dir remove_dir copy_dir copy_tree move_dir move_tree \
    create_file remove_file copy_file move_file \
    read_lines write_lines append_lines \
    find_files find_dirs search_files find_by_content filter_files \
    get_file_info get_file_hash get_size get_modified get_permissions \
    compare_files \
    set_permissions set_owner \
    is_empty is_executable is_readable is_writable \
    backup_file restore_file \
    compress_file compress decompress_file decompress create_archive extract_archive \
    sync_files sync_dirs \
    validate_file_path validate_filename sanitize_filename validate_checksum \
    watch_file \
    analyze_disk_usage \
    cleanup_temp_files cleanup_empty_dirs