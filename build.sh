#!/bin/bash

# SignBridge Build Script
# Automates the build process for development and release

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    print_success "Flutter found: $(flutter --version | head -n 1)"
}

# Clean previous builds
clean_build() {
    print_header "Cleaning Previous Builds"
    flutter clean
    print_success "Clean complete"
}

# Get dependencies
get_dependencies() {
    print_header "Getting Dependencies"
    flutter pub get
    print_success "Dependencies installed"
}

# Run code analysis
analyze_code() {
    print_header "Analyzing Code"
    if flutter analyze; then
        print_success "Code analysis passed"
    else
        print_error "Code analysis failed"
        exit 1
    fi
}

# Run tests
run_tests() {
    print_header "Running Tests"
    if flutter test; then
        print_success "All tests passed"
    else
        print_warning "Some tests failed"
    fi
}

# Build debug APK
build_debug() {
    print_header "Building Debug APK"
    flutter build apk --debug
    print_success "Debug APK built successfully"
    print_info "Location: build/app/outputs/flutter-apk/app-debug.apk"
}

# Build release APK
build_release() {
    print_header "Building Release APK"
    flutter build apk --release
    print_success "Release APK built successfully"
    print_info "Location: build/app/outputs/flutter-apk/app-release.apk"
}

# Build split APKs
build_split() {
    print_header "Building Split APKs"
    flutter build apk --release --split-per-abi
    print_success "Split APKs built successfully"
    print_info "Locations:"
    print_info "  - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
    print_info "  - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
    print_info "  - build/app/outputs/flutter-apk/app-x86_64-release.apk"
}

# Build app bundle
build_bundle() {
    print_header "Building App Bundle"
    flutter build appbundle --release
    print_success "App bundle built successfully"
    print_info "Location: build/app/outputs/bundle/release/app-release.aab"
}

# Install on device
install_apk() {
    print_header "Installing APK on Device"
    
    # Check if device is connected
    if ! adb devices | grep -q "device$"; then
        print_error "No device connected"
        exit 1
    fi
    
    # Install the APK
    if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
        adb install -r build/app/outputs/flutter-apk/app-debug.apk
        print_success "APK installed successfully"
    else
        print_error "APK not found. Build it first."
        exit 1
    fi
}

# Show APK info
show_apk_info() {
    print_header "APK Information"
    
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        local size=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        print_info "Release APK size: $size"
    fi
    
    if [ -f "build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" ]; then
        local size=$(du -h build/app/outputs/flutter-apk/app-arm64-v8a-release.apk | cut -f1)
        print_info "ARM64 APK size: $size"
    fi
    
    if [ -f "build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk" ]; then
        local size=$(du -h build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk | cut -f1)
        print_info "ARMv7 APK size: $size"
    fi
}

# Main menu
show_menu() {
    echo ""
    print_header "SignBridge Build Menu"
    echo "1) Quick Build (debug)"
    echo "2) Full Build (release)"
    echo "3) Split APKs (release)"
    echo "4) App Bundle (release)"
    echo "5) Clean & Build (debug)"
    echo "6) Clean & Build (release)"
    echo "7) Run Tests"
    echo "8) Analyze Code"
    echo "9) Install on Device"
    echo "10) Show APK Info"
    echo "0) Exit"
    echo ""
}

# Process menu choice
process_choice() {
    case $1 in
        1)
            check_flutter
            get_dependencies
            build_debug
            show_apk_info
            ;;
        2)
            check_flutter
            get_dependencies
            analyze_code
            build_release
            show_apk_info
            ;;
        3)
            check_flutter
            get_dependencies
            analyze_code
            build_split
            show_apk_info
            ;;
        4)
            check_flutter
            get_dependencies
            analyze_code
            build_bundle
            ;;
        5)
            check_flutter
            clean_build
            get_dependencies
            build_debug
            show_apk_info
            ;;
        6)
            check_flutter
            clean_build
            get_dependencies
            analyze_code
            run_tests
            build_release
            show_apk_info
            ;;
        7)
            check_flutter
            run_tests
            ;;
        8)
            check_flutter
            analyze_code
            ;;
        9)
            install_apk
            ;;
        10)
            show_apk_info
            ;;
        0)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Main script
main() {
    # Check if running with arguments
    if [ $# -gt 0 ]; then
        case $1 in
            --debug)
                check_flutter
                get_dependencies
                build_debug
                ;;
            --release)
                check_flutter
                get_dependencies
                analyze_code
                build_release
                ;;
            --split)
                check_flutter
                get_dependencies
                analyze_code
                build_split
                ;;
            --bundle)
                check_flutter
                get_dependencies
                analyze_code
                build_bundle
                ;;
            --clean)
                check_flutter
                clean_build
                ;;
            --test)
                check_flutter
                run_tests
                ;;
            --analyze)
                check_flutter
                analyze_code
                ;;
            --install)
                install_apk
                ;;
            --full)
                check_flutter
                clean_build
                get_dependencies
                analyze_code
                run_tests
                build_release
                show_apk_info
                ;;
            --help)
                echo "SignBridge Build Script"
                echo ""
                echo "Usage: ./build.sh [option]"
                echo ""
                echo "Options:"
                echo "  --debug      Build debug APK"
                echo "  --release    Build release APK"
                echo "  --split      Build split APKs"
                echo "  --bundle     Build app bundle"
                echo "  --clean      Clean build directory"
                echo "  --test       Run tests"
                echo "  --analyze    Analyze code"
                echo "  --install    Install APK on device"
                echo "  --full       Full build (clean, test, analyze, release)"
                echo "  --help       Show this help"
                echo ""
                echo "No option: Show interactive menu"
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    else
        # Interactive mode
        while true; do
            show_menu
            read -p "Enter your choice: " choice
            process_choice $choice
            echo ""
            read -p "Press Enter to continue..."
        done
    fi
}

# Run main
main "$@"