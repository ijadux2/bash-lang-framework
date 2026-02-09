#!/bin/bash

# Build Module
# Provides project management, build automation, and packaging utilities

module_version build 1.0.0

# Project structure templates
declare -A PROJECT_TEMPLATES=(
    ["basic"]="# Basic Bash Project
#!/bin/bash

# Main script
main() {
    echo \"Hello, World!\"
}

main \"\$@\"
"
    ["module"]="# Module-based Bash Project
#!/bin/bash

# Import required modules
source lib.sh

import core.system
import string
import ui

# Main function
main() {
    print_header \"Module Project\"
    echo \"This is a module-based project\"
    print_footer
}

main \"\$@\"
"
    ["cli"]="# CLI Application Project
#!/bin/bash

# Import required modules
source lib.sh

import core.system
import string
import ui
import io

# CLI application
main() {
    local command=\"\${1:-help}\"
    
    case \"\$command\" in
        \"run\")
            echo \"Running application...\"
            ;;
        \"test\")
            echo \"Running tests...\"
            ;;
        \"build\")
            echo \"Building project...\"
            ;;
        \"help\"|\"--help\"|\"-h\")
            show_help
            ;;
        *)
            echo \"Unknown command: \$command\"
            show_help
            exit 1
            ;;
    esac
}

show_help() {
    echo \"Usage: \$0 [command]\"
    echo \"Commands:\"
    echo \"  run     - Run the application\"
    echo \"  test    - Run tests\"
    echo \"  build   - Build the project\"
    echo \"  help    - Show this help message\"
}

main \"\$@\"
"
    ["library"]="# Library Project
#!/bin/bash

# Library project template
# This project provides reusable modules

# Version information
LIB_VERSION=\"1.0.0\"

# Export function
export_lib() {
    echo \"Library v\$LIB_VERSION\"
}
"
)

# Build configuration file
BUILD_CONFIG="build.yaml"

# Initialize project
init_project() {
    local project_name="$1"
    local template="${2:-basic}"
    local directory="${3:-.}"
    
    if [[ -z "$project_name" ]]; then
        error "Project name required"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ -z "${PROJECT_TEMPLATES[$template]}" ]]; then
        error "Unknown template: $template"
        return ${EXIT_FAILURE:-1}
    fi
    
    local project_dir="$directory/$project_name"
    
    if [[ -d "$project_dir" ]]; then
        error "Project directory already exists: $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    # Create project directory
    mkdir -p "$project_dir"
    
    # Create main script
    local main_script="$project_dir/${project_name}.sh"
    echo "${PROJECT_TEMPLATES[$template]}" > "$main_script"
    chmod +x "$main_script"
    
    # Create modules directory
    mkdir -p "$project_dir/modules"
    
    # Create lib.sh symlink/copy
    if [[ -f "lib.sh" ]]; then
        cp "lib.sh" "$project_dir/"
    else
        echo "#!/bin/bash" > "$project_dir/lib.sh"
        echo "# Placeholder lib.sh" >> "$project_dir/lib.sh"
    fi
    
    # Create README
    cat > "$project_dir/README.md" << EOF
# $project_name

A Bash project created with the Bash System Language framework.

## Usage

\`\`\`bash
./${project_name}.sh
\`\`\`

## Project Structure

- \`${project_name}.sh\` - Main script
- \`lib.sh\` - System language library
- \`modules/\` - Project modules
- \`README.md\` - This file

## Development

This project uses the Bash System Language framework for enhanced Bash programming.

EOF
    
    # Create .gitignore
    cat > "$project_dir/.gitignore" << EOF
# Bash
*.bashpkg
*.compiled

# Logs
*.log
debug.log

# Backup files
*.bak
*.backup

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

EOF
    
    success "Project initialized: $project_dir"
    echo "Main script: $main_script"
    echo "Template: $template"
}

# Create new project (for compatibility)
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
build_project() {
    local project_dir="${1:-.}"
    local output_dir="${2:-./dist}"
    local optimize="${3:-1}"
    
    if [[ ! -d "$project_dir" ]]; then
        error "Project directory not found: $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    mkdir -p "$output_dir"
    
    # Find main script
    local main_script
    for script in "$project_dir"/*.sh; do
        if [[ -f "$script" && -x "$script" ]]; then
            main_script="$script"
            break
        fi
    done
    
    if [[ -z "$main_script" ]]; then
        error "No executable main script found in $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    local script_name=$(basename "$main_script" .sh)
    local output_file="$output_dir/${script_name}.compiled"
    
    # Compile the script
    if compile "$main_script" "$output_file" "$optimize"; then
        success "Project built: $output_file"
        return 0
    else
        error "Build failed"
        return ${EXIT_FAILURE:-1}
    fi
}

# Build project (for compatibility)
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

# Clean project
clean_project() {
    local project_dir="${1:-.}"
    local dist_dir="${2:-./dist}"
    
    if [[ -d "$dist_dir" ]]; then
        rm -rf "$dist_dir"
        success "Cleaned distribution directory: $dist_dir"
    fi
    
    # Remove compiled files
    if [[ -d "$project_dir" ]]; then
        find "$project_dir" -name "*.compiled" -delete 2>/dev/null || true
        find "$project_dir" -name "*.bashpkg" -delete 2>/dev/null || true
        success "Cleaned compiled files"
    fi
    
    # Remove log files
    find "$project_dir" -name "*.log" -delete 2>/dev/null || true
}

# Clean build artifacts (for compatibility)
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

# Test project
test_project() {
    local project_dir="${1:-.}"
    local test_dir="${2:-tests}"
    
    if [[ ! -d "$project_dir" ]]; then
        error "Project directory not found: $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    # Look for test files
    local test_files=()
    if [[ -d "$project_dir/$test_dir" ]]; then
        mapfile -t test_files < <(find "$project_dir/$test_dir" -name "test_*.sh" 2>/dev/null)
    elif [[ -d "$test_dir" ]]; then
        mapfile -t test_files < <(find "$test_dir" -name "test_*.sh" 2>/dev/null)
    fi
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        warn "No test files found"
        return 0
    fi
    
    echo "Running tests..."
    local failed=0
    
    for test_file in "${test_files[@]}"; do
        echo "Testing: $(basename "$test_file")"
        if bash "$test_file"; then
            success "✓ $(basename "$test_file")"
        else
            error "✗ $(basename "$test_file")"
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        success "All tests passed"
        return 0
    else
        error "$failed tests failed"
        return ${EXIT_FAILURE:-1}
    fi
}

# Run tests (for compatibility)
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

# Package project
package_project() {
    local project_dir="${1:-.}"
    local name="${2:-}"
    local version="${3:-1.0.0}"
    local output_dir="${4:-./packages}"
    
    if [[ ! -d "$project_dir" ]]; then
        error "Project directory not found: $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    # Get project name from directory if not provided
    if [[ -z "$name" ]]; then
        name=$(basename "$project_dir")
    fi
    
    # Find main script
    local main_script
    for script in "$project_dir"/*.sh; do
        if [[ -f "$script" && -x "$script" ]]; then
            main_script="$script"
            break
        fi
    done
    
    if [[ -z "$main_script" ]]; then
        error "No executable main script found in $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    # Create package
    if package "$name" "$version" "$main_script" "$output_dir"; then
        success "Project packaged: $output_dir/${name}-${version}.bashpkg"
        return 0
    else
        error "Packaging failed"
        return ${EXIT_FAILURE:-1}
    fi
}

# Install project dependencies
install_dependencies() {
    local project_dir="${1:-.}"
    local deps_file="${2:-dependencies.txt}"
    
    if [[ ! -d "$project_dir" ]]; then
        error "Project directory not found: $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    local deps_file_path="$project_dir/$deps_file"
    
    if [[ ! -f "$deps_file_path" ]]; then
        warn "No dependencies file found: $deps_file_path"
        return 0
    fi
    
    echo "Installing dependencies..."
    
    while IFS= read -r dep; do
        # Skip comments and empty lines
        [[ "$dep" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$dep" ]] && continue
        
        echo "Installing: $dep"
        
        # Handle different dependency types
        if [[ "$dep" =~ ^git\+ ]]; then
            # Git dependency
            local repo="${dep#git+}"
            local target_dir="$project_dir/modules/$(basename "$repo" .git)"
            
            if [[ ! -d "$target_dir" ]]; then
                git clone "$repo" "$target_dir" || {
                    error "Failed to clone repository: $repo"
                    return ${EXIT_FAILURE:-1}
                }
            fi
        elif [[ "$dep" =~ ^http ]]; then
            # HTTP/HTTPS dependency
            local target_file="$project_dir/modules/$(basename "$dep")"
            
            if [[ ! -f "$target_file" ]]; then
                curl -o "$target_file" "$dep" || {
                    error "Failed to download: $dep"
                    return ${EXIT_FAILURE:-1}
                }
            fi
        else
            # Local file dependency
            local dep_file="$project_dir/$dep"
            
            if [[ ! -f "$dep_file" ]]; then
                error "Dependency not found: $dep"
                return ${EXIT_FAILURE:-1}
            fi
        fi
    done < "$deps_file_path"
    
    success "Dependencies installed"
}

# Install dependencies (for compatibility)
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

# Create release
create_release() {
    local project_dir="${1:-.}"
    local version="${2:-}"
    local release_dir="${3:-./releases}"
    
    if [[ ! -d "$project_dir" ]]; then
        error "Project directory not found: $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    # Get version from project if not provided
    if [[ -z "$version" ]]; then
        if [[ -f "$project_dir/VERSION" ]]; then
            version=$(cat "$project_dir/VERSION")
        else
            version="1.0.0"
        fi
    fi
    
    local project_name=$(basename "$project_dir")
    local release_name="${project_name}-v${version}"
    local release_path="$release_dir/$release_name"
    
    # Create release directory
    mkdir -p "$release_path"
    
    # Copy project files
    cp -r "$project_dir"/* "$release_path/"
    
    # Remove development files
    rm -rf "$release_path/.git" 2>/dev/null || true
    rm -f "$release_path/.gitignore" 2>/dev/null || true
    find "$release_path" -name "*.log" -delete 2>/dev/null || true
    find "$release_path" -name "*.backup" -delete 2>/dev/null || true
    
    # Create release info
    cat > "$release_path/RELEASE_INFO.txt" << EOF
Release: $release_name
Version: $version
Date: $(date)
Created by: Bash System Language Build System

Files included:
$(find "$release_path" -type f | sort)

EOF
    
    # Create archive
    local archive_file="$release_dir/${release_name}.tar.gz"
    tar -czf "$archive_file" -C "$release_dir" "$release_name"
    
    # Clean up release directory
    rm -rf "$release_path"
    
    success "Release created: $archive_file"
}

# Release project (for compatibility)
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

# Deploy project
deploy_project() {
    local project_dir="${1:-.}"
    local target="${2:-}"
    local method="${3:-scp}"
    
    if [[ ! -d "$project_dir" ]]; then
        error "Project directory not found: $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    if [[ -z "$target" ]]; then
        error "Target deployment location required"
        return ${EXIT_FAILURE:-1}
    fi
    
    # Build project first
    build_project "$project_dir" "./deploy" || {
        error "Build failed, cannot deploy"
        return ${EXIT_FAILURE:-1}
    }
    
    case "$method" in
        "scp")
            local archive_file="${project_dir##*/}.tar.gz"
            tar -czf "$archive_file" -C "$project_dir" .
            scp "$archive_file" "$target"
            rm "$archive_file"
            ;;
        "rsync")
            rsync -av "$project_dir/" "$target/"
            ;;
        "git")
            if [[ -d "$project_dir/.git" ]]; then
                cd "$project_dir" || return ${EXIT_FAILURE:-1}
                git push "$target"
                cd - || return ${EXIT_FAILURE:-1}
            else
                error "Not a git repository"
                return ${EXIT_FAILURE:-1}
            fi
            ;;
        *)
            error "Unknown deployment method: $method"
            return ${EXIT_FAILURE:-1}
            ;;
    esac
    
    success "Project deployed to: $target"
}

# Project status
project_status() {
    local project_dir="${1:-.}"
    
    if [[ ! -d "$project_dir" ]]; then
        error "Project directory not found: $project_dir"
        return ${EXIT_FAILURE:-1}
    fi
    
    local project_name=$(basename "$project_dir")
    
    echo "Project Status: $project_name"
    echo "========================"
    
    # Project info
    echo "Directory: $project_dir"
    echo "Size: $(du -sh "$project_dir" | cut -f1)"
    echo "Files: $(find "$project_dir" -type f | wc -l)"
    echo "Directories: $(find "$project_dir" -type d | wc -l)"
    echo
    
    # Main script
    local main_script
    for script in "$project_dir"/*.sh; do
        if [[ -f "$script" && -x "$script" ]]; then
            main_script="$script"
            break
        fi
    done
    
    if [[ -n "$main_script" ]]; then
        echo "Main script: $(basename "$main_script")"
        echo "Size: $(wc -l < "$main_script") lines"
        echo "Executable: ✓"
    else
        echo "Main script: Not found"
    fi
    echo
    
    # Modules
    if [[ -d "$project_dir/modules" ]]; then
        local module_count=$(find "$project_dir/modules" -name "*.sh" | wc -l)
        echo "Modules: $module_count"
        if [[ $module_count -gt 0 ]]; then
            echo "Module files:"
            find "$project_dir/modules" -name "*.sh" -exec basename {} \; | sed 's/^/  /'
        fi
    else
        echo "Modules: None"
    fi
    echo
    
    # Tests
    local test_count=$(find "$project_dir" -name "test_*.sh" 2>/dev/null | wc -l)
    echo "Tests: $test_count"
    
    # Build artifacts
    if [[ -d "$project_dir/dist" ]]; then
        echo "Build artifacts: $(find "$project_dir/dist" -type f | wc -l) files"
    fi
    
    # Git status
    if [[ -d "$project_dir/.git" ]]; then
        echo
        echo "Git Status:"
        cd "$project_dir" || return ${EXIT_FAILURE:-1}
        git status --porcelain | head -10
        cd - || return ${EXIT_FAILURE:-1}
    fi
}

# List available templates
list_templates() {
    echo "Available project templates:"
    for template in "${!PROJECT_TEMPLATES[@]}"; do
        echo "  $template"
    done
}

# Show template preview
show_template() {
    local template="$1"
    
    if [[ -z "${PROJECT_TEMPLATES[$template]}" ]]; then
        error "Unknown template: $template"
        return ${EXIT_FAILURE:-1}
    fi
    
    echo "Template: $template"
    echo "================"
    echo "${PROJECT_TEMPLATES[$template]}"
}

# Export module functions
export_module build \
    init_project project_init build_project build clean_project clean test_project test \
    package_project install_dependencies install_deps create_release release \
    deploy_project project_status \
    list_templates show_template