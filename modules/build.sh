#!/usr/bin/bash

# Build System - Build automation and package management
module_version "build" "1.0.0"

# Build configuration file
BUILD_CONFIG="build.yaml"

# Create new project
project_init() {
    local name="$1"
    local type="${2:-script}"
    
    if [[ -z "$name" ]]; then
        error "Project name required"
        return 1
    fi
    
    mkdir -p "$name"
    cd "$name" || return 1
    
    # Create project structure
    mkdir -p {src,modules,tests,docs,build}
    
    # Create build configuration
    cat > "$BUILD_CONFIG" << EOF
project:
  name: "$name"
  version: "1.0.0"
  type: "$type"
  author: "$(git config user.name 2>/dev/null || echo 'Unknown')"

build:
  optimize: true
  embed_modules: true
  output_dir: "dist"

dependencies:
  - core.system
  - string
  - io

scripts:
  build: "bash lib.sh build"
  test: "bash lib.sh test"
  run: "bash lib.sh run"

modules:
  search_paths:
    - "./modules"
    - "../modules"
    - "~/.bash_modules"
EOF
    
    # Create main source file
    cat > "src/main.sh" << EOF
#!/usr/bin/bash

# $name - Main entry point
source ../lib.sh

# Import required modules
import core.system
import string
import io

main() {
    info "Starting $name..."
    
    # Your code here
    
    info "Done!"
}

# Run main function
if [[ "\${BASH_SOURCE[0]}" == "\${0}" ]]; then
    main "\$@"
fi
EOF
    
    chmod +x "src/main.sh"
    
    # Create test file
    cat > "tests/test_main.sh" << EOF
#!/usr/bin/bash

# Tests for $name
source ../lib.sh

test_main() {
    # Test cases here
    assert "1 -eq 1" || return 1
    info "All tests passed!"
}

# Run tests
test_main
EOF
    
    chmod +x "tests/test_main.sh"
    
    info "Project '$name' created successfully"
}

# Build project
build() {
    local config_file="${1:-$BUILD_CONFIG}"
    
    if [[ ! -f "$config_file" ]]; then
        error "Build configuration '$config_file' not found"
        return 1
    fi
    
    # Parse configuration (simplified YAML parser)
    local project_name
    local project_version
    local optimize="true"
    local output_dir="dist"
    
    while IFS=':' read -r key value; do
        key=$(echo "$key" | tr -d ' ')
        case "$key" in
            "name") project_name=$(echo "$value" | tr -d ' ') ;;
            "version") project_version=$(echo "$value" | tr -d ' ') ;;
            "optimize") optimize=$(echo "$value" | tr -d ' ') ;;
            "output_dir") output_dir=$(echo "$value" | tr -d ' ') ;;
        esac
    done < <(grep -E "^(project|build):" "$config_file" | sed 's/^[[:space:]]*//')
    
    if [[ -z "$project_name" ]]; then
        error "Project name not found in configuration"
        return 1
    fi
    
    mkdir -p "$output_dir"
    
    # Compile main source
    if [[ -f "src/main.sh" ]]; then
        info "Building $project_name..."
        
        if [[ "$optimize" == "true" ]]; then
            compile "src/main.sh" "$output_dir/$project_name" 1
        else
            cp "src/main.sh" "$output_dir/$project_name"
            chmod +x "$output_dir/$project_name"
        fi
        
        info "Build completed: $output_dir/$project_name"
    else
        error "Main source file 'src/main.sh' not found"
        return 1
    fi
}

# Run tests
test() {
    local test_dir="${1:-tests}"
    
    if [[ ! -d "$test_dir" ]]; then
        warn "Test directory '$test_dir' not found"
        return 0
    fi
    
    info "Running tests..."
    local failed=0
    local total=0
    
    for test_file in "$test_dir"/test_*.sh; do
        if [[ -f "$test_file" ]]; then
            ((total++))
            info "Running $(basename "$test_file")..."
            
            if bash "$test_file"; then
                info "✓ $(basename "$test_file") passed"
            else
                error "✗ $(basename "$test_file") failed"
                ((failed++))
            fi
        fi
    done
    
    echo
    if [[ $failed -eq 0 ]]; then
        info "All $total tests passed"
        return 0
    else
        error "$failed/$total tests failed"
        return 1
    fi
}

# Clean build artifacts
clean() {
    local dirs=("dist" "build" "*.compiled")
    
    info "Cleaning build artifacts..."
    
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            rm -rf "$dir"
            info "Removed directory: $dir"
        elif [[ -f "$dir" ]]; then
            rm -f "$dir"
            info "Removed file: $dir"
        fi
    done
    
    # Find and remove compiled files
    find . -name "*.compiled" -delete 2>/dev/null
    info "Cleanup completed"
}

# Install dependencies
install_deps() {
    local config_file="${1:-$BUILD_CONFIG}"
    
    if [[ ! -f "$config_file" ]]; then
        error "Configuration file '$config_file' not found"
        return 1
    fi
    
    info "Installing dependencies..."
    
    # Extract dependencies from config
    local deps=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+ ]]; then
            local dep=$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]+(.+)/\1/' | tr -d ' ')
            deps+=("$dep")
        fi
    done < <(sed -n '/^dependencies:/,/^$/{p;}' "$config_file")
    
    for dep in "${deps[@]}"; do
        if [[ -n "$dep" ]]; then
            info "Importing $dep..."
            import "$dep" || warn "Failed to import $dep"
        fi
    done
    
    info "Dependencies installed"
}

# Release project
release() {
    local version="$1"
    local config_file="${2:-$BUILD_CONFIG}"
    
    if [[ -z "$version" ]]; then
        error "Version number required"
        return 1
    fi
    
    # Update version in config
    sed -i "s/version: \".*\"/version: \"$version\"/" "$config_file"
    
    # Build project
    build || return 1
    
    # Create release package
    local project_name
    project_name=$(grep "^name:" "$config_file" | cut -d':' -f2 | tr -d ' ')
    
    if [[ -n "$project_name" ]]; then
        package "$project_name" "$version" "dist/$project_name" "releases"
        info "Release $project_name v$version created"
    else
        error "Project name not found in configuration"
        return 1
    fi
}

# Export functions
export_module "build" project_init build test clean install_deps release