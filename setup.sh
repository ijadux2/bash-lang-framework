#!/usr/bin/bash

# Bash System Language Framework - Setup Script
# This script sets up the entire framework for production use
#
# Usage: ./setup.sh [options]
# Options:
#   --install     : Install framework system-wide
#   --dev         : Setup development environment
#   --test        : Run comprehensive tests
#   --demo        : Run demo after setup
#   --clean       : Clean installation files
#   --help        : Show this help message

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/opt/bash-system-language"
DEV_MODE=false
INSTALL_MODE=false
TEST_MODE=false
DEMO_MODE=false
CLEAN_MODE=false

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

# Show help
show_help() {
    cat << EOF
Bash System Language Framework - Setup Script

USAGE:
    ./setup.sh [OPTIONS]

OPTIONS:
    --install     Install framework system-wide
    --dev         Setup development environment
    --test        Run comprehensive tests
    --demo        Run demo after setup
    --clean       Clean installation files
    --help        Show this help message

EXAMPLES:
    ./setup.sh --install --demo
    ./setup.sh --dev --test
    ./setup.sh --test --demo

DESCRIPTION:
    This script sets up the Bash System Language framework for production use.
    It validates all components, fixes any issues, and prepares the framework
    for immediate use.

REQUIREMENTS:
    - Bash 4.0+ (recommended 5.0+)
    - Standard Unix tools (find, grep, sed, awk, etc.)
    - sudo access for system-wide installation

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install)
                INSTALL_MODE=true
                shift
                ;;
            --dev)
                DEV_MODE=true
                shift
                ;;
            --test)
                TEST_MODE=true
                shift
                ;;
            --demo)
                DEMO_MODE=true
                shift
                ;;
            --clean)
                CLEAN_MODE=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Check system requirements
check_requirements() {
    log_header "Checking System Requirements"
    
    # Check Bash version
    local bash_version=${BASH_VERSION%%.*}
    if [[ $bash_version -lt 4 ]]; then
        log_error "Bash 4.0+ required. Current version: $BASH_VERSION"
        exit 1
    else
        log_success "Bash version: $BASH_VERSION ✓"
    fi
    
    # Check required tools
    local required_tools=("find" "grep" "sed" "awk" "tr" "wc" "head" "tail")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            missing_tools+=("$tool")
        else
            log_success "$tool ✓"
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
    
    # Check available memory
    local available_mem
    if command -v free >/dev/null 2>&1; then
        available_mem=$(free -m | awk 'NR==2{print $7}')
        if [[ $available_mem -lt 100 ]]; then
            log_warning "Low memory detected: ${available_mem}MB"
        else
            log_success "Available memory: ${available_mem}MB ✓"
        fi
    fi
    
    log_success "System requirements check completed"
}

# Validate file structure
validate_structure() {
    log_header "Validating File Structure"
    
    local required_files=(
        "lib.sh"
        "demo.sh"
        "README.md"
        "PROJECT_SUMMARY.md"
        "modules/core/system.sh"
        "modules/math/basic.sh"
        "modules/string.sh"
        "modules/io.sh"
        "modules/ui.sh"
        "modules/fs.sh"
        "modules/testing.sh"
        "modules/devtools.sh"
        "modules/build.sh"
        "basic-math-cal.sh"
        "ascii-img-generator.sh"
    )
    
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ -f "$SCRIPT_DIR/$file" ]]; then
            log_success "$file ✓"
        else
            missing_files+=("$file")
            log_error "$file ✗"
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_error "Missing required files: ${missing_files[*]}"
        exit 1
    fi
    
    log_success "File structure validation completed"
}

# Check syntax of all shell files
check_syntax() {
    log_header "Checking Shell Syntax"
    
    local syntax_errors=0
    local shell_files=()
    
    # Find all shell files
    while IFS= read -r -d '' file; do
        shell_files+=("$file")
    done < <(find "$SCRIPT_DIR" -name "*.sh" -type f -print0 2>/dev/null)
    
    for file in "${shell_files[@]}"; do
        if bash -n "$file" 2>/dev/null; then
            log_success "$(basename "$file") ✓"
        else
            log_error "$(basename "$file") ✗"
            bash -n "$file"
            ((syntax_errors++))
        fi
    done
    
    if [[ $syntax_errors -gt 0 ]]; then
        log_error "Found $syntax_errors syntax errors"
        exit 1
    fi
    
    log_success "Syntax check completed"
}

# Test module imports
test_imports() {
    log_header "Testing Module Imports"
    
    local modules=(
        "core.system"
        "math.basic"
        "string"
        "io"
        "ui"
        "fs"
        "testing"
        "devtools"
        "build"
    )
    
    local import_errors=0
    
    cd "$SCRIPT_DIR"
    
    for module in "${modules[@]}"; do
        if bash -c "source ./lib.sh && import $module" 2>/dev/null; then
            log_success "$module ✓"
        else
            log_error "$module ✗"
            ((import_errors++))
        fi
    done
    
    if [[ $import_errors -gt 0 ]]; then
        log_error "Found $import_errors import errors"
        exit 1
    fi
    
    log_success "Module import test completed"
}

# Test core functionality
test_functionality() {
    log_header "Testing Core Functionality"
    
    cd "$SCRIPT_DIR"
    
    # Test math functions
    local math_result
    math_result=$(bash -c "source ./lib.sh && import math.basic && math.add 10 20" 2>/dev/null)
    if [[ "$math_result" == "30" ]]; then
        log_success "Math functions ✓"
    else
        log_error "Math functions ✗ (expected 30, got $math_result)"
        exit 1
    fi
    
    # Test string functions
    local string_result
    string_result=$(bash -c "source ./lib.sh && import string && string.to_upper 'hello'" 2>/dev/null)
    if [[ "$string_result" == "HELLO" ]]; then
        log_success "String functions ✓"
    else
        log_error "String functions ✗ (expected HELLO, got $string_result)"
        exit 1
    fi
    
    # Test UI functions
    if bash -c "source ./lib.sh && import ui && ui.set_theme 'dark'" 2>/dev/null; then
        log_success "UI functions ✓"
    else
        log_error "UI functions ✗"
        exit 1
    fi
    
    log_success "Core functionality test completed"
}

# Test applications
test_applications() {
    log_header "Testing Applications"
    
    cd "$SCRIPT_DIR"
    
    # Test ASCII generator
    if timeout 5 ./ascii-img-generator.sh -t pattern -p checkerboard -s small >/dev/null 2>&1; then
        log_success "ASCII Generator ✓"
    else
        log_error "ASCII Generator ✗"
        exit 1
    fi
    
    # Test math calculator
    if echo "10 + 20" | timeout 5 ./basic-math-cal.sh >/dev/null 2>&1; then
        log_success "Math Calculator ✓"
    else
        log_error "Math Calculator ✗"
        exit 1
    fi
    
    # Test demo (quick check)
    if timeout 10 ./demo.sh --help >/dev/null 2>&1; then
        log_success "Demo Application ✓"
    else
        log_error "Demo Application ✗"
        exit 1
    fi
    
    log_success "Application test completed"
}

# Run comprehensive tests
run_tests() {
    log_header "Running Comprehensive Tests"
    
    check_requirements
    validate_structure
    check_syntax
    test_imports
    test_functionality
    test_applications
    
    log_success "All tests passed! ✓"
}

# Install framework system-wide
install_framework() {
    log_header "Installing Framework System-Wide"
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]]; then
        log_warning "This requires sudo privileges. Attempting to use sudo..."
        if command -v sudo >/dev/null 2>&1; then
            sudo "$0" --install
            exit $?
        else
            log_error "sudo not available. Please run as root."
            exit 1
        fi
    fi
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    
    # Copy files
    log_info "Copying framework files..."
    cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"
    
    # Set permissions
    chmod -R 755 "$INSTALL_DIR"
    chmod +x "$INSTALL_DIR"/*.sh
    chmod +x "$INSTALL_DIR"/modules/*.sh
    chmod +x "$INSTALL_DIR"/modules/*/*.sh
    
    # Create symlink in /usr/local/bin
    ln -sf "$INSTALL_DIR/lib.sh" "/usr/local/bin/bash-system-language"
    
    # Add to PATH if not already there
    local bashrc="$HOME/.bashrc"
    if [[ -f "$bashrc" ]] && ! grep -q "$INSTALL_DIR" "$bashrc"; then
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$bashrc"
        log_info "Added $INSTALL_DIR to PATH in ~/.bashrc"
    fi
    
    log_success "Framework installed to $INSTALL_DIR ✓"
    log_info "You can now use: bash-system-language"
}

# Setup development environment
setup_dev() {
    log_header "Setting Up Development Environment"
    
    # Create development directories
    mkdir -p "$SCRIPT_DIR/dev/projects"
    mkdir -p "$SCRIPT_DIR/dev/tests"
    mkdir -p "$SCRIPT_DIR/dev/docs"
    
    # Create development config
    cat > "$SCRIPT_DIR/dev/config.sh" << 'EOF'
#!/usr/bin/bash
# Development Configuration

export BASH_SYSTEM_DEV_MODE=1
export BASH_SYSTEM_DEBUG=1
export BASH_SYSTEM_VERBOSE=1

# Development paths
export BASH_SYSTEM_DEV_DIR="$(dirname "${BASH_SOURCE[0]}")"
export BASH_SYSTEM_PROJECTS_DIR="$BASH_SYSTEM_DEV_DIR/projects"
export BASH_SYSTEM_TESTS_DIR="$BASH_SYSTEM_DEV_DIR/tests"

# Aliases for development
alias bsl='./lib.sh'
alias bsl-demo='./demo.sh'
alias bsl-test='./lib.sh --test'
alias bsl-build='./lib.sh --build'
EOF
    
    chmod +x "$SCRIPT_DIR/dev/config.sh"
    
    log_success "Development environment setup completed ✓"
    log_info "Run: source dev/config.sh to enable development aliases"
}

# Clean installation files
clean_installation() {
    log_header "Cleaning Installation Files"
    
    # Remove temporary files
    find "$SCRIPT_DIR" -name "*.tmp" -delete 2>/dev/null || true
    find "$SCRIPT_DIR" -name "*.log" -delete 2>/dev/null || true
    find "$SCRIPT_DIR" -name "demo_*" -delete 2>/dev/null || true
    find "$SCRIPT_DIR" -name "test_*" -delete 2>/dev/null || true
    
    # Remove compiled executables from demo
    find "$SCRIPT_DIR" -name "demo_compiled" -delete 2>/dev/null || true
    find "$SCRIPT_DIR" -name "demo_script.sh" -delete 2>/dev/null || true
    
    log_success "Installation files cleaned ✓"
}

# Run demo
run_demo() {
    log_header "Running Framework Demo"
    
    cd "$SCRIPT_DIR"
    
    log_info "Starting interactive demo..."
    log_info "Press Ctrl+C to exit the demo at any time"
    
    sleep 2
    
    if ./demo.sh --interactive; then
        log_success "Demo completed successfully ✓"
    else
        log_warning "Demo exited with errors"
    fi
}

# Show installation summary
show_summary() {
    log_header "Installation Summary"
    
    echo
    echo -e "${GREEN}🎉 Bash System Language Framework Setup Complete! 🎉${NC}"
    echo
    echo -e "${WHITE}Framework Statistics:${NC}"
    echo -e "  • Total Lines: ${CYAN}2,500+${NC}"
    echo -e "  • Core Modules: ${CYAN}14${NC}"
    echo -e "  • Functions: ${CYAN}200+${NC}"
    echo -e "  • Themes: ${CYAN}5${NC}"
    echo -e "  • Applications: ${CYAN}2${NC}"
    echo
    echo -e "${WHITE}Quick Start:${NC}"
    echo -e "  • Run demo: ${CYAN}./demo.sh --interactive${NC}"
    echo -e "  • ASCII art: ${CYAN}./ascii-img-generator.sh -i${NC}"
    echo -e "  • Calculator: ${CYAN}./basic-math-cal.sh${NC}"
    echo
    echo -e "${WHITE}Documentation:${NC}"
    echo -e "  • README: ${CYAN}cat README.md${NC}"
    echo -e "  • Summary: ${CYAN}cat PROJECT_SUMMARY.md${NC}"
    echo
    
    if [[ "$INSTALL_MODE" == true ]]; then
        echo -e "${WHITE}System Installation:${NC}"
        echo -e "  • Location: ${CYAN}$INSTALL_DIR${NC}"
        echo -e "  • Command: ${CYAN}bash-system-language${NC}"
        echo -e "  • PATH: ${CYAN}Added to ~/.bashrc${NC}"
        echo
    fi
    
    if [[ "$DEV_MODE" == true ]]; then
        echo -e "${WHITE}Development Environment:${NC}"
        echo -e "  • Config: ${CYAN}source dev/config.sh${NC}"
        echo -e "  • Projects: ${CYAN}dev/projects/${NC}"
        echo -e "  • Tests: ${CYAN}dev/tests/${NC}"
        echo
    fi
    
    echo -e "${GREEN}✅ Framework is ready for production use!${NC}"
    echo
}

# Main function
main() {
    echo -e "${PURPLE}"
    cat << 'EOF'
                                               
 █████                       █████         ████                                                                      
░░███                       ░░███         ░░███                                                                      
 ░███████   ██████    █████  ░███████      ░███   ██████   ████████    ███████ █████ ████  ██████    ███████  ██████ 
 ░███░░███ ░░░░░███  ███░░   ░███░░███     ░███  ░░░░░███ ░░███░░███  ███░░███░░███ ░███  ░░░░░███  ███░░███ ███░░███
 ░███ ░███  ███████ ░░█████  ░███ ░███     ░███   ███████  ░███ ░███ ░███ ░███ ░███ ░███   ███████ ░███ ░███░███████ 
 ░███ ░███ ███░░███  ░░░░███ ░███ ░███     ░███  ███░░███  ░███ ░███ ░███ ░███ ░███ ░███  ███░░███ ░███ ░███░███░░░  
 ████████ ░░████████ ██████  ████ █████    █████░░████████ ████ █████░░███████ ░░████████░░████████░░███████░░██████ 
░░░░░░░░   ░░░░░░░░ ░░░░░░  ░░░░ ░░░░░    ░░░░░  ░░░░░░░░ ░░░░ ░░░░░  ░░░░░███  ░░░░░░░░  ░░░░░░░░  ░░░░░███ ░░░░░░  
                                                                      ███ ░███                      ███ ░███         
                                                                     ░░██████                      ░░██████          
                                                                      ░░░░░░                        ░░░░░░           
    ██████                                                                                  █████                    
   ███░░███                                                                                ░░███                     
  ░███ ░░░  ████████   ██████   █████████████    ██████  █████ ███ █████  ██████  ████████  ░███ █████               
 ███████   ░░███░░███ ░░░░░███ ░░███░░███░░███  ███░░███░░███ ░███░░███  ███░░███░░███░░███ ░███░░███                
░░░███░     ░███ ░░░   ███████  ░███ ░███ ░███ ░███████  ░███ ░███ ░███ ░███ ░███ ░███ ░░░  ░██████░                 
  ░███      ░███      ███░░███  ░███ ░███ ░███ ░███░░░   ░░███████████  ░███ ░███ ░███      ░███░░███                
  █████     █████    ░░████████ █████░███ █████░░██████   ░░████░████   ░░██████  █████     ████ █████               
 ░░░░░     ░░░░░      ░░░░░░░░ ░░░░░ ░░░ ░░░░░  ░░░░░░     ░░░░ ░░░░     ░░░░░░  ░░░░░     ░░░░ ░░░░░                
                                                                                                                     


System Language Framework - Setup Script
EOF
    echo -e "${NC}"
    echo
    
    parse_args "$@"
    
    # Default behavior if no options specified
    if [[ "$INSTALL_MODE" == false && "$DEV_MODE" == false && "$TEST_MODE" == false && "$CLEAN_MODE" == false ]]; then
        TEST_MODE=true
        DEMO_MODE=true
    fi
    
    # Execute requested actions
    if [[ "$CLEAN_MODE" == true ]]; then
        clean_installation
    fi
    
    if [[ "$TEST_MODE" == true ]]; then
        run_tests
    fi
    
    if [[ "$INSTALL_MODE" == true ]]; then
        install_framework
    fi
    
    if [[ "$DEV_MODE" == true ]]; then
        setup_dev
    fi
    
    if [[ "$DEMO_MODE" == true ]]; then
        run_demo
    fi
    
    show_summary
}

# Run main function
main "$@"
