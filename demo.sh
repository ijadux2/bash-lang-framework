#!/usr/bin/bash

# Example demonstration of Bash System Language capabilities
source ./lib.sh

# Import modules to showcase functionality
import core.system
import math.basic
import string
import ui
import io
import testing
import devtools
import fs

# Demo configuration
module_version "demo" "1.0.0"

demo_info() {
    ui.set_theme "neon"
    header "Bash System Language - Feature Demonstration" 80 "primary"
    
    info_msg "This demo showcases the enhanced Bash System Language features:"
    echo "  • C/Zig-like import system"
    echo "  • Module system with versioning"
    echo "  • Compilation to executables"
    echo "  • Advanced theming system"
    echo "  • Testing framework"
    echo "  • Development tools"
    echo "  • Rich standard library"
    echo
    
    themed_confirm "Continue with demonstration?" "y" || exit 0
}

demo_modules() {
    header "Module System" 60 "success"
    
    info_msg "Available modules:"
    list_imports
    echo
    
    info_msg "Module versions:"
    for module in core.system math.basic string ui io testing devtools fs demo; do
        local version
        version=$(get_module_version "$module")
        echo "  • $module: $version"
    done
    echo
}

demo_math() {
    header "Math Module" 60 "accent"
    
    info_msg "Basic arithmetic operations:"
    
    local a=15
    local b=7
    
    echo "  $a + $b = $(add $a $b)"
    echo "  $a - $b = $(subtract $a $b)"
    echo "  $a * $b = $(multiply $a $b)"
    echo "  $a / $b = $(divide $a $b)"
    echo "  $a ^ $b = $(power $a $b)"
    echo "  Max($a, $b, 20) = $(max $a $b 20)"
    echo "  Min($a, $b, 5) = $(min $a $b 5)"
    echo
}

demo_string() {
    header "String Module" 60 "info"
    
    local text="Hello, Bash System Language!"
    
    info_msg "String operations on: '$text'"
    echo "  Length: $(length "$text")"
    echo "  Upper: $(to_upper "$text")"
    echo "  Lower: $(to_lower "$text")"
    echo "  Capitalized: $(capitalize "$text")"
    echo "  Contains 'Bash': $(contains "$text" "Bash" && echo "Yes" || echo "No")"
    echo "  First 5 chars: $(substring "$text" 0 5)"
    echo
}

demo_ui() {
    header "UI/Theme System" 60 "magenta"
    
    info_msg "Available themes:"
    list_themes
    echo
    
    info_msg "Trying different themes:"
    
    local themes=("default" "dark" "light" "neon" "retro")
    for theme in "${themes[@]}"; do
        set_theme "$theme"
        success "Theme: $theme"
        box "This is a $theme themed box!" 40 "primary"
        echo
    done
    
    # Restore neon theme
    ui.set_theme "neon"
}

demo_interactive() {
    header "Interactive Components" 60 "cyan"
    
    info_msg "Interactive menu example:"
    local options=("Option 1: Show system info" "Option 2: Calculate something" "Option 3: Exit demo")
    local choice
    choice=$(themed_menu "Choose an option" "${options[@]}")
    
    case "$choice" in
        "Option 1: Show system info")
            info_msg "System Information:"
            echo "  OS: $(get_os)"
            echo "  Architecture: $(get_arch)"
            echo "  Kernel: $(get_kernel)"
            echo "  Hostname: $(get_hostname)"
            ;;
        "Option 2: Calculate something")
            local num1 num2
            num1=$(themed_prompt "Enter first number" "10")
            num2=$(themed_prompt "Enter second number" "5")
            
            local sum
            sum=$(add "$num1" "$num2")
            success "$num1 + $num2 = $sum"
            ;;
        "Option 3: Exit demo")
            info_msg "Exiting interactive demo..."
            return 0
            ;;
    esac
    echo
}

demo_testing() {
    header "Testing Framework" 60 "yellow"
    
    info_msg "Running demonstration tests:"
    
    # Simple test suite
    describe "Basic Math Tests"
    
    it "should add numbers correctly"
    assert_equals "5" "$(math.basic.add 2 3)" "2 + 3 should equal 5"
    
    it "should multiply numbers correctly"
    assert_equals "6" "$(math.basic.multiply 2 3)" "2 * 3 should equal 6"
    
    it "should handle division by zero"
    assert_false "math.basic.divide 5 0" "Division by zero should fail"
    
    describe "String Tests"
    
    it "should convert to uppercase"
    assert_equals "HELLO" "$(string.to_upper hello)" "hello should become HELLO"
    
    it "should check string length"
    assert_equals "5" "$(string.length hello)" "hello should have length 5"
    
    echo
    info_msg "Test demonstration completed!"
    echo
}

demo_compilation() {
    header "Compilation System" 60 "green"
    
    info_msg "Creating a demo executable..."
    
    # Create a simple demo script
    local demo_script="demo_script.sh"
    cat > "$demo_script" << 'EOF'
#!/usr/bin/bash

source ./lib.sh
import ui
import math.basic

set_theme "neon"
header "Compiled Demo Application" 60 "primary"

info_msg "This is a compiled bash application!"
success "Calculation: 10 + 20 = $(add 10 20)"
box "Compilation successful!" 40 "success"
EOF
    
    chmod +x "$demo_script"
    
    info_msg "Compiling $demo_script to executable..."
    
    if compile "$demo_script" "demo_compiled" 1; then
        success "Compilation successful!"
        info_msg "Running compiled executable..."
        echo
        ./demo_compiled
        echo
        
        # Cleanup
        rm -f "$demo_script" "demo_compiled"
    else
        error_msg "Compilation failed!"
    fi
}

demo_filesystem() {
    header "File System Module" 60 "bright_cyan"
    
    info_msg "File system operations demonstration:"
    
    # Create test directory
    local test_dir="demo_test_dir"
    fs.create_dir "$test_dir"
    
    # Create test files
    echo "Hello, World!" > "$test_dir/test1.txt"
    echo "Line 1"$'\n'"Line 2"$'\n'"Line 3" > "$test_dir/test2.txt"
    
    info_msg "Created test directory and files"
    
    # Demonstrate file operations
    echo "  Test directory size: $(fs.get_size "$test_dir") bytes"
    echo "  test1.txt size: $(fs.get_size "$test_dir/test1.txt") bytes"
    echo "  test1.txt is readable: $(fs.is_readable "$test_dir/test1.txt" && echo "Yes" || echo "No")"
    
    # Read specific lines
    echo "  First line of test2.txt: $(fs.read_lines "$test_dir/test2.txt" 1 1)"
    echo "  Lines 2-3 of test2.txt:"
    fs.read_lines "$test_dir/test2.txt" 2 2 | sed 's/^/    /'
    
    # Cleanup
    rm -rf "$test_dir"
    info_msg "Test files cleaned up"
    echo
}

demo_devtools() {
    header "Development Tools" 60 "bright_magenta"
    
    info_msg "Development tools demonstration:"
    
    # Enable debugging
    enable_debug 2 "demo_debug.log"
    
    debug_log 1 "This is a debug message"
    debug_log 2 "This is a detailed debug message"
    
    # Code analysis
    local demo_code="demo_analysis.sh"
    cat > "$demo_code" << 'EOF'
#!/usr/bin/bash

# Simple demo script for analysis
demo_function() {
    local var="hello"
    echo "$var"
    
    # This is a comment
    if [[ "$var" == "hello" ]]; then
        echo "Condition true"
    fi
}
EOF
    
    info_msg "Analyzing demo code:"
    analyze_code "$demo_code"
    
    # Lint code
    echo
    info_msg "Linting demo code:"
    lint_code "$demo_code"
    
    # Cleanup
    rm -f "$demo_code" "demo_debug.log"
    
    disable_debug
    echo
}

demo_project_structure() {
    header "Build System - Project Creation" 60 "bright_green"
    
    info_msg "Creating a sample project structure..."
    
    # Import build module
    import build
    
    # Create sample project
    build.project_init "sample_project" "application"
    
    if [[ -d "sample_project" ]]; then
        success "Project created successfully!"
        
        info_msg "Project structure:"
        find sample_project -type f | sed 's/^/  /'
        
        # Cleanup
        rm -rf sample_project
    else
        error_msg "Project creation failed!"
    fi
    echo
}

# Enhanced comprehensive demo
comprehensive_demo() {
    ui.set_theme "neon"
    clear
    
    header "🚀 Bash System Language - Comprehensive Demo 🚀" 80 "primary"
    echo
    center_text "Complete Programming Framework for Bash" 80
    echo
    center_text "Version 1.0.0 | Production Ready" 80
    echo
    separator "═" 80 "accent"
    echo
    
    info_msg "This comprehensive demo showcases ALL framework capabilities:"
    echo
    
    local -a all_features=(
        "Import System (C/Zig-like syntax)"
        "Module System with Versioning"
        "String Operations & Validation"
        "Math Functions & Number Theory"
        "File System Operations"
        "Interactive UI Components"
        "Advanced Theming System"
        "Testing Framework (BDD-style)"
        "Development Tools & Debugger"
        "Build System & Project Management"
        "Compilation to Executables"
        "ASCII Art Generator"
        "Package Management"
    )
    
    for feature in "${all_features[@]}"; do
        echo "  ✓ $feature"
    done
    echo
    
    separator "═" 80 "accent"
    themed_confirm "Run comprehensive demonstration?" "y" || return 0
    
    # Run all demo sections
    demo_info
    demo_modules
    demo_math
    demo_string
    demo_ui
    demo_interactive
    demo_testing
    demo_compilation
    demo_filesystem
    demo_devtools
    demo_project_structure
    demo_ascii_art
    demo_performance
    
    header "🎉 Comprehensive Demo Complete! 🎉" 80 "success"
    success "Bash System Language framework is fully operational!"
    echo
    info_msg "Framework Summary:"
    echo "  • 14 core modules implemented"
    echo "  • 5 built-in themes with custom support"
    echo "  • Complete testing framework"
    echo "  • Build and package management"
    echo "  • Development tools and debugger"
    echo "  • ASCII art generation"
    echo "  • C/Zig-like import system"
    echo "  • Compilation to standalone executables"
    echo
    box "🚀 Bash is now a powerful system programming language! 🚀" 70 "primary"
}

# ASCII Art Generator Demo
demo_ascii_art() {
    header "ASCII Art Generator" 60 "bright_cyan"
    
    info_msg "ASCII Art Generation capabilities:"
    
    if [[ -f "./ascii-img-generator.sh" ]]; then
        success_msg "✓ ASCII generator found!"
        echo
        
        info_msg "Available patterns:"
        echo "  • Checkerboard pattern"
        echo "  • Diamond shape"
        echo "  • Heart shape"
        echo "  • Star pattern"
        echo "  • Tree pattern"
        echo "  • Text to ASCII"
        echo
        
        # Generate a sample pattern
        info_msg "Generating sample ASCII art..."
        echo
        ./ascii-img-generator.sh -t pattern -p checkerboard -s small
        echo
    else
        warning_msg "ASCII generator not found"
    fi
}

# Performance Demo
demo_performance() {
    header "Performance Benchmarking" 60 "bright_yellow"
    
    info_msg "Running performance benchmarks..."
    echo
    
    # Benchmark string operations
    success_msg "String operations:"
    local start_time=$(date +%s.%N)
    
    for i in {1..1000}; do
        string.to_upper "test string $i" >/dev/null
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.001")
    echo "  • 1000 string.to_upper operations: ${duration}s"
    echo
    
    # Benchmark math operations
    success_msg "Math operations:"
    start_time=$(date +%s.%N)
    
    for i in {1..1000}; do
        math.add $i $((i+1)) >/dev/null
    done
    
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.001")
    echo "  • 1000 math.add operations: ${duration}s"
    echo
    
    success_msg "Performance benchmarking completed!"
}

# Interactive menu for demo selection
interactive_demo_menu() {
    while true; do
        clear
        header "Bash System Language Demo" 80 "primary"
        
        local options=(
            "🎯 Quick Demo (Original)"
            "🚀 Comprehensive Demo (Enhanced)"
            "🔧 Individual Demos"
            "📊 Performance Benchmarks"
            "🎨 ASCII Art Generator"
            "❌ Exit"
        )
        
        local choice
        choice=$(themed_menu "Select demo type" "${options[@]}")
        
        case "$choice" in
            "🎯 Quick Demo (Original)")
                main_demo
                ;;
            "🚀 Comprehensive Demo (Enhanced)")
                comprehensive_demo
                ;;
            "🔧 Individual Demos")
                individual_demos_menu
                ;;
            "📊 Performance Benchmarks")
                demo_performance
                ;;
            "🎨 ASCII Art Generator")
                demo_ascii_art
                ;;
            "❌ Exit")
                break
                ;;
        esac
        
        themed_confirm "Continue with demos?" "n" && break
    done
}

# Menu for individual demos
individual_demos_menu() {
    while true; do
        clear
        header "Individual Demos" 80 "info"
        
        local options=(
            "Import System"
            "Math Module"
            "String Module"
            "UI/Theme System"
            "Interactive Components"
            "Testing Framework"
            "Compilation System"
            "File System Module"
            "Development Tools"
            "Build System"
            "🔙 Back to Main Menu"
        )
        
        local choice
        choice=$(themed_menu "Select a demo" "${options[@]}")
        
        case "$choice" in
            "Import System") demo_modules ;;
            "Math Module") demo_math ;;
            "String Module") demo_string ;;
            "UI/Theme System") demo_ui ;;
            "Interactive Components") demo_interactive ;;
            "Testing Framework") demo_testing ;;
            "Compilation System") demo_compilation ;;
            "File System Module") demo_filesystem ;;
            "Development Tools") demo_devtools ;;
            "Build System") demo_project_structure ;;
            "🔙 Back to Main Menu") break ;;
        esac
        
        themed_confirm "Run another individual demo?" "n" && break
    done
}

main_demo() {
    set_theme "neon"
    
    # Check if we want interactive menu or original demo
    if [[ "$1" == "--interactive" ]]; then
        interactive_demo_menu
        return
    fi
    
    demo_info
    demo_modules
    demo_math
    demo_string
    demo_ui
    demo_testing
    demo_compilation
    demo_filesystem
    demo_devtools
    demo_project_structure
    
    header "Demo Complete!" 80 "success"
    success "Bash System Language demonstration completed successfully!"
    info_msg "The enhanced bash now provides:"
    echo "  • C/Zig-like import system with dependency management"
    echo "  • Rich standard library with 10+ modules"
    echo "  • Advanced theming and UI components"
    echo "  • Comprehensive testing framework"
    echo "  • Development tools and debugger"
    echo "  • Build system and package management"
    echo "  • Compilation to standalone executables"
    echo
    box "Bash is now a powerful system programming language!" 70 "primary"
}

# Export demo functions
export_module "demo" demo_info demo_modules demo_math demo_string demo_ui demo_interactive demo_testing demo_compilation demo_filesystem demo_devtools demo_project_structure demo_ascii_art demo_performance comprehensive_demo interactive_demo_menu individual_demos_menu main_demo

# Run demo if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_demo "$@"
fi
