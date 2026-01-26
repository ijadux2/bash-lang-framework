# Bash System Language

An enhanced Bash framework that transforms Bash into a powerful system programming language with C/Zig-like features.

## Features

### 🔧 Core System
- **C/Zig-like Import System**: `import module.name` syntax
- **Module Management**: Version tracking, dependency resolution
- **Compilation**: Create standalone executables from bash scripts
- **Package Management**: Create and distribute bash packages

### 📚 Rich Standard Library
- **core.system**: System utilities, environment, error handling
- **math.basic**: Arithmetic operations, comparisons, range checking
- **string**: String manipulation, validation, formatting
- **io**: File operations, user input, tables, progress bars
- **ui**: Advanced theming system, interactive components
- **fs**: File system operations, compression, synchronization
- **testing**: Comprehensive testing framework
- **devtools**: Debugger, profiler, code analyzer, formatter
- **build**: Project initialization, build automation

### 🎨 Theming System
- Multiple built-in themes (default, dark, light, neon, retro)
- Color-aware output components
- Interactive menus, confirmations, prompts
- Professional UI components

### 🛠️ Development Tools
- Debugging with breakpoints and stack traces
- Performance monitoring and profiling
- Code linting and formatting
- Interactive development server

## Quick Start

### Basic Usage
```bash
#!/usr/bin/bash
source lib.sh

# Import modules
import core.system
import ui
import math.basic

# Use enhanced features
ui.set_theme "neon"
ui.header "My Application" 60 "primary"

local result=$(math.basic.add 10 20)
ui.success "Result: $result"
```

### Module Creation
```bash
#!/usr/bin/bash
# modules/myapp/calculator.sh

module_version "myapp.calculator" "1.0.0"

add() { echo $(($1 + $2)); }
multiply() { echo $(($1 * $2)); }

export_module "myapp.calculator" add multiply
```

### Project Structure
```bash
# Initialize new project
bash lib.sh project_init myapp
cd myapp

# Build the project
bash lib.sh build

# Run tests
bash lib.sh test

# Create release
bash lib.sh release 1.0.0
```

## Module System

### Import Modules
```bash
import core.system
import math.basic
import ui.themes
import custom.module
```

### Available Modules
- **core.system**: System utilities, error handling, debugging
- **math.basic**: Arithmetic, comparisons, min/max, range checking
- **string**: Manipulation, validation, case conversion, splitting
- **io**: File operations, user input, tables, progress bars
- **ui**: Theming, interactive components, colored output
- **fs**: File operations, compression, synchronization, validation
- **testing**: Unit testing framework with assertions
- **devtools**: Debugger, profiler, code analyzer, formatter
- **build**: Project management, build automation, packaging

## UI/Them Examples

### Set Theme
```bash
ui.set_theme "neon"  # Available: default, dark, light, neon, retro
```

### Interactive Components
```bash
# Menu
choice=$(ui.themed_menu "Select option" "Option 1" "Option 2" "Option 3")

# Confirmation
if ui.themed_confirm "Continue?" "y"; then
    ui.success "User agreed!"
fi

# Input
name=$(ui.themed_prompt "Enter your name" "Default")

# Progress bar
for i in {1..100}; do
    ui.themed_progress_bar $i 100 50 "Processing"
    sleep 0.1
done
```

### Display Components
```bash
ui.header "Application Title" 60 "primary"
ui.box "Important message" 50 "warning"
ui.separator "─" 60 "accent"
ui.footer "End of section" 60 "secondary"
```

## Testing Framework

### Write Tests
```bash
#!/usr/bin/bash
source lib.sh
import testing

describe "Math Operations"

it "should add numbers correctly"
assert_equals "5" "$(math.basic.add 2 3)" "2 + 3 should equal 5"

it "should handle division by zero"
assert_false "math.basic.divide 5 0" "Division by zero should fail"

it "should validate input"
assert_true "string.is_numeric 123" "123 should be numeric"
```

### Run Tests
```bash
# Run single test file
bash lib.sh test test_math.sh

# Run all tests
bash lib.sh test
```

## Compilation

### Compile to Executable
```bash
# Basic compilation
bash lib.sh compile myscript.sh myscript.exec

# Optimized compilation
bash lib.sh compile myscript.sh myscript.opt 1
```

### Create Package
```bash
bash lib.sh package myapp 1.0.0 src/main.sh
```

## Development Tools

### Debugging
```bash
#!/usr/bin/bash
source lib.sh
import devtools

enable_debug 2 "debug.log"

breakpoint "some_condition" "Debug point reached"

debug_log 1 "Information message"
debug_log 2 "Detailed debug information"
```

### Code Analysis
```bash
# Analyze code
bash lib.sh analyze myscript.sh

# Lint code
bash lib.sh lint myscript.sh

# Format code
bash lib.sh format myscript.sh
```

## Project Examples

### Enhanced Calculator
The `basic-math-cal.sh` demonstrates the module system with:
- Themed UI components
- Input validation
- Interactive menus
- Error handling
- History tracking

### ASCII Art Generator
The `ascii-img-generator.sh` showcases:
- Advanced file operations
- Theme support
- Interactive configuration
- Multiple output formats
- Error handling

### Demo Script
Run the comprehensive demo:
```bash
./demo.sh
```

## Directory Structure

```
bash/libs/
├── lib.sh              # Main library with module system
├── demo.sh             # Comprehensive feature demonstration
├── modules/            # Standard library modules
│   ├── core/           # System utilities
│   ├── math/           # Mathematics operations
│   ├── string/         # String manipulation
│   ├── io/             # Input/output utilities
│   ├── ui/             # User interface theming
│   ├── fs/             # File system operations
│   ├── testing/        # Testing framework
│   ├── devtools/       # Development tools
│   └── build/          # Build system
└── scripts/            # Example applications
    ├── basic-math-cal.sh
    ├── ascii-img-generator.sh
    └── ascii-video-generator.sh
```

## Advanced Features

### Conditional Imports
```bash
import_if "debug.tools" "$DEBUG_MODE"
try_import "optional.module"
```

### Module Dependencies
```bash
check_dependencies "myapp" "core.system" "ui" "math.basic"
```

### Version Management
```bash
module_version "myapp" "2.1.0"
get_module_version "myapp"
```

### Performance Monitoring
```bash
enable_profiler
profile_function my_function arg1 arg2
disable_profiler
```

## Installation

1. Clone or download this repository
2. Make `lib.sh` executable: `chmod +x lib.sh`
3. Source the library in your scripts: `source lib.sh`
4. Start importing modules!

## Contributing

The Bash System Language is designed to be extensible. You can:
- Create new modules in the `modules/` directory
- Add themes to the UI system
- Extend the testing framework
- Build applications on top of the framework

Transform your Bash scripts into professional, maintainable applications with the Bash System Language! 🚀