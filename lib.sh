#!/usr/bin/bash 

# Enhanced Bash System Language - Module System
# Adds C/Zig-like import functionality to Bash

# Initialize associative arrays safely
declare -A BASH_IMPORTED_MODULES
declare -A BASH_MODULE_VERSIONS
declare -A BASH_MODULE_EXPORTS
declare -A UI_COLORS
declare -A UI_STYLES
declare -A CURRENT_THEME
declare -A THEMES
declare -A ASCII_THEMES
declare -A TEST_COLORS

# Module search paths
BASH_MODULE_PATHS=(
    "${PWD}/modules"
    "${PWD}"
    "${HOME}/.bash_modules"
    "/usr/local/share/bash_modules"
    "/usr/share/bash_modules"
)

# Error handling functions
error() { echo "Error: $*" >&2; return 1; }
fatal() { echo "Fatal: $*" >&2; exit 1; }
warn() { echo "Warning: $*" >&2; }
info() { echo "Info: $*"; }
success() { echo "Success: $*"; }

# Utility functions
repeat() { 
    local count="$1"
    local char="${2:- }"
    printf "%*s" "$count" | tr ' ' "$char"
}

# Import function - works like C's #include or Zig's @import
import() {
    local module="$1"
    local module_file="$2"
    
    # Check if already imported
    if [[ -n "${BASH_IMPORTED_MODULES[$module]:-}" ]]; then
        return 0
    fi
    
    # Find module file
    if [[ -n "$module_file" ]]; then
        if [[ ! -f "$module_file" ]]; then
            echo "Error: Module file '$module_file' not found" >&2
            return 1
        fi
    else
        module_file=$(find_module "$module")
        if [[ -z "$module_file" ]]; then
            echo "Error: Module '$module' not found" >&2
            return 1
        fi
    fi
    
    # Source the module
    if ! source "$module_file"; then
        echo "Error: Failed to import module '$module'" >&2
        return 1
    fi
    
    # Mark as imported
    BASH_IMPORTED_MODULES[$module]="$module_file"
    return 0
}

# Find module in search paths
find_module() {
    local module="$1"
    local module_name
    
    # Convert dots to slashes for nested modules
    module_name="${module//./\/}"
    
    # Try different extensions
    local extensions=(".sh" ".bash" "")
    
    for path in "${BASH_MODULE_PATHS[@]}"; do
        if [[ -d "$path" ]]; then
            for ext in "${extensions[@]}"; do
                local candidate="$path/${module_name}${ext}"
                if [[ -f "$candidate" ]]; then
                    echo "$candidate"
                    return 0
                fi
            done
        fi
    done
    
    return 1
}

# List imported modules
list_imports() {
    for module in "${!BASH_IMPORTED_MODULES[@]}"; do
        echo "$module -> ${BASH_IMPORTED_MODULES[$module]}"
    done
}

# Clear imported modules (for reloading)
clear_imports() {
    BASH_IMPORTED_MODULES=()
}

# Module validation
validate_module() {
    local module_file="$1"
    
    # Check for required shebang
    if [[ -f "$module_file" ]]; then
        local first_line
        read -r first_line < "$module_file"
        if [[ ! "$first_line" =~ ^#! ]]; then
            echo "Warning: Module '$module_file' has no shebang" >&2
        fi
        return 0
    fi
    
    return 1
}

# Export module function
export_module() {
    local module_name="$1"
    local safe_name="${module_name//./_}"
    local functions=("${@:2}")
    
    # Mark exported functions
    for func in "${functions[@]}"; do
        if declare -f "$func" > /dev/null; then
            export -f "$func"
        fi
    done
    
    # Register module exports
    declare -g "BASH_MODULE_EXPORTS_${safe_name}=${functions[*]}"
}

# Get module exports
get_module_exports() {
    local module_name="$1"
    local safe_name="${module_name//./_}"
    var_name="BASH_MODULE_EXPORTS_${safe_name}"
    if [[ -n "${!var_name:-}" ]]; then
        echo "${!var_name}"
    fi
}

# Module version info
module_version() {
    local module="$1"
    local version="$2"
    local safe_module="${module//./_}"
    
    declare -g "BASH_MODULE_VERSION_${safe_module}=$version"
}

get_module_version() {
    local module="$1"
    local safe_module="${module//./_}"
    var_name="BASH_MODULE_VERSION_${safe_module}"
    echo "${!var_name:-unknown}"
}

# Conditional import
import_if() {
    local condition="$1"
    local module="$2"
    local module_file="$3"
    
    if eval "$condition"; then
        import "$module" "$module_file"
    fi
}

# Try import (non-fatal)
try_import() {
    local module="$1"
    local module_file="$2"
    
    import "$module" "$module_file" 2>/dev/null || true
}

# Module dependency checker
check_dependencies() {
    local module="$1"
    shift
    local deps=("$@")
    
    for dep in "${deps[@]}"; do
        if [[ -z "${BASH_IMPORTED_MODULES[$dep]:-}" ]]; then
            echo "Error: Module '$module' requires dependency '$dep'" >&2
            return 1
        fi
    done
    return 0
}

# Add module search path
add_module_path() {
    local path="$1"
    if [[ -d "$path" ]] && [[ ":${BASH_MODULE_PATHS[*]}:" != *":$path:"* ]]; then
        BASH_MODULE_PATHS=("$path" "${BASH_MODULE_PATHS[@]}")
    fi
}

# Initialize module system
init_module_system() {
    # Create standard directories if they don't exist
    mkdir -p "${HOME}/.bash_modules"
    
    # Load configuration if exists
    if [[ -f "${HOME}/.bash_module_config" ]]; then
        source "${HOME}/.bash_module_config"
    fi
}

# Compilation system - Create executable bash programs
compile() {
    local source="$1"
    local output="$2"
    local optimize="${3:-1}"
    
    if [[ ! -f "$source" ]]; then
        error "Source file '$source' not found"
        return 1
    fi
    
    # Create temporary working directory
    local workdir=$(mktemp -d)
    trap "rm -rf $workdir" RETURN
    
    # Parse source and extract dependencies
    local compiled_file="$workdir/compiled.sh"
    echo "#!/usr/bin/bash" > "$compiled_file"
    echo "# Compiled from $source by Bash System Language" >> "$compiled_file"
    echo "# Generated: $(date)" >> "$compiled_file"
    echo "" >> "$compiled_file"
    
    # Extract imports and embed dependencies
    extract_imports "$source" "$compiled_file"
    
    # Add optimized source
    if [[ "$optimize" == "1" ]]; then
        optimize_source "$source" >> "$compiled_file"
    else
        cat "$source" >> "$compiled_file"
    fi
    
    # Make executable
    chmod +x "$compiled_file"
    
    # Copy to output location
    if [[ -z "$output" ]]; then
        output="${source%.sh}.compiled"
    fi
    
    cp "$compiled_file" "$output"
    chmod +x "$output"
    
    info "Compiled '$source' to '$output'"
    return 0
}

# Extract and embed imported modules
extract_imports() {
    local source="$1"
    local output="$2"
    local processed_modules=()
    
    # Read source file
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*import[[:space:]]+ ]]; then
            # Extract module name
            local module=$(echo "$line" | sed -E 's/^[[:space:]]*import[[:space:]]+([^[:space:]]+).*/\1/')
            
            # Skip if already processed
            if [[ " ${processed_modules[*]} " == *" $module "* ]]; then
                continue
            fi
            
            processed_modules+=("$module")
            
            # Find and embed module
            local module_file
            module_file=$(find_module "$module")
            if [[ -n "$module_file" ]]; then
                echo "# Embedded module: $module from $module_file" >> "$output"
                extract_imports "$module_file" "$output" 2>/dev/null || true
                cat "$module_file" >> "$output"
                echo "" >> "$output"
            else
                warn "Module '$module' not found during compilation"
            fi
        fi
    done < "$source"
}

# Optimize source code
optimize_source() {
    local source="$1"
    local temp_file=$(mktemp)
    
    # Remove comments (except shebang)
    sed '/^#!/!s/#.*//' "$source" | \
    # Remove empty lines
    sed '/^$/d' | \
    # Remove excessive whitespace
    sed 's/^[[:space:]]*//' | \
    # Combine multiple consecutive spaces
    sed 's/  */ /g' > "$temp_file"
    
    cat "$temp_file"
    rm "$temp_file"
}

# Create package
package() {
    local name="$1"
    local version="$2"
    local main_file="$3"
    local output_dir="${4:-packages}"
    
    if [[ -z "$name" || -z "$version" || -z "$main_file" ]]; then
        error "Usage: package <name> <version> <main_file> [output_dir]"
        return 1
    fi
    
    if [[ ! -f "$main_file" ]]; then
        error "Main file '$main_file' not found"
        return 1
    fi
    
    mkdir -p "$output_dir"
    local package_file="$output_dir/${name}-${version}.bashpkg"
    
    # Create package header
    {
        echo "#!/usr/bin/bash"
        echo "# Bash Package: $name v$version"
        echo "# Generated: $(date)"
        echo ""
        echo "# Package metadata"
        echo "BASH_PKG_NAME='$name'"
        echo "BASH_PKG_VERSION='$version'"
        echo "BASH_PKG_MAIN='$main_file'"
        echo ""
        echo "# Package loader"
        echo "bash_pkg_main() {"
        echo "    local temp_dir=\$(mktemp -d)"
        echo "    trap 'rm -rf \$temp_dir' RETURN"
        echo ""
        echo "    # Extract package content"
        echo "    sed '1,/^# END_HEADER/d' \"\${BASH_SOURCE[0]}\" > \"\$temp_dir/package.sh\""
        echo "    chmod +x \"\$temp_dir/package.sh\""
        echo ""
        echo "    # Execute main file"
        echo "    bash \"\$temp_dir/package.sh\" \"\$@\""
        echo "}"
        echo ""
        echo "# Execute if called directly"
        echo 'if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then'
        echo "    bash_pkg_main \"\$@\""
        echo "fi"
        echo ""
        echo "# END_HEADER"
        echo ""
        echo "# Package content below"
        cat "$main_file"
    } > "$package_file"
    
    chmod +x "$package_file"
    info "Package created: $package_file"
}

# Install package
install_pkg() {
    local package_file="$1"
    local install_dir="${2:-${HOME}/.bash_modules}"
    
    if [[ ! -f "$package_file" ]]; then
        error "Package file '$package_file' not found"
        return 1
    fi
    
    # Extract package name from file
    local pkg_name
    pkg_name=$(grep "^# Bash Package:" "$package_file" | sed 's/# Bash Package: //' | cut -d' ' -f1)
    
    if [[ -z "$pkg_name" ]]; then
        error "Invalid package file"
        return 1
    fi
    
    mkdir -p "$install_dir"
    local target_dir="$install_dir/$pkg_name"
    
    # Extract package
    mkdir -p "$target_dir"
    sed '1,/^# END_HEADER/d' "$package_file" > "$target_dir/main.sh"
    chmod +x "$target_dir/main.sh"
    
    info "Package '$pkg_name' installed to $target_dir"
}

# Run compiled program
run() {
    local program="$1"
    shift
    
    if [[ -f "$program" ]]; then
        bash "$program" "$@"
    elif command -v "$program" > /dev/null; then
        "$program" "$@"
    else
        error "Program '$program' not found"
        return 1
    fi
}

# Development server for hot-reloading
dev_server() {
    local port="${1:-8080}"
    local watch_dir="${2:-.}"
    
    info "Development server started on port $port"
    info "Watching directory: $watch_dir"
    
    while true; do
        inotifywait -r -e modify,create,delete "$watch_dir" 2>/dev/null && {
            echo "Files changed. Restarting..."
            # Restart logic here
        }
    done
}

# Auto-initialize
init_module_system

# Initialize some basic color definitions if not set
if [[ ${#UI_COLORS[@]} -eq 0 ]]; then
    declare -A UI_COLORS=(
        ["reset"]="\033[0m"
        ["black"]="\033[30m"
        ["red"]="\033[31m"
        ["green"]="\033[32m"
        ["yellow"]="\033[33m"
        ["blue"]="\033[34m"
        ["magenta"]="\033[35m"
        ["cyan"]="\033[36m"
        ["white"]="\033[37m"
    )
fi 
