#!/bin/bash

# AI Documentation Framework - Hook Testing Script
# Tests the git hooks to ensure they work correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "This script must be run from the root of a git repository"
    exit 1
fi

# Check if .claude-docs exists
if [ ! -d ".claude-docs" ]; then
    print_error ".claude-docs directory not found. Please install the AI Documentation Framework first."
    exit 1
fi

echo "AI Documentation Framework - Hook Testing"
echo "=========================================="
echo ""

# Test 1: Check if hooks are installed
print_info "Test 1: Checking if git hooks are installed..."

HOOKS_INSTALLED=true
for hook in post-commit pre-push; do
    if [ -f ".git/hooks/$hook" ]; then
        if grep -q "AI Documentation Framework" ".git/hooks/$hook" 2>/dev/null; then
            print_success "$hook hook is installed and is from AI Documentation Framework"
        else
            print_warning "$hook hook exists but is not from AI Documentation Framework"
            HOOKS_INSTALLED=false
        fi
    else
        print_error "$hook hook is not installed"
        HOOKS_INSTALLED=false
    fi
done

if [ "$HOOKS_INSTALLED" = "false" ]; then
    print_info "To install hooks, run: ./.claude-docs/manage-hooks.sh enable"
    echo ""
fi

# Test 2: Check if Claude CLI is available
print_info "Test 2: Checking if Claude CLI is available..."

if command -v claude >/dev/null 2>&1; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    print_success "Claude CLI is available (version: $CLAUDE_VERSION)"
else
    print_error "Claude CLI not found. Please install Claude CLI for hooks to work."
    echo ""
fi

# Test 3: Check configuration
print_info "Test 3: Checking configuration..."

if [ -f ".claude-docs/config.json" ]; then
    print_success "Configuration file exists (.claude-docs/config.json)"
    
    # Check if enabled
    ENABLED=$(python3 -c "
import json
try:
    with open('.claude-docs/config.json', 'r') as f:
        config = json.load(f)
    print('true' if config.get('enabled', True) else 'false')
except:
    print('unknown')
" 2>/dev/null || echo "unknown")
    
    if [ "$ENABLED" = "true" ]; then
        print_success "Framework is enabled in configuration"
    elif [ "$ENABLED" = "false" ]; then
        print_warning "Framework is disabled in configuration"
    else
        print_warning "Could not determine if framework is enabled"
    fi
else
    print_warning "Configuration file not found. Using default settings."
fi

# Test 4: Check Claude commands
print_info "Test 4: Checking Claude commands..."

for cmd in init-ai-docs update-ai-docs; do
    if [ -f ".claude/commands/$cmd.md" ]; then
        print_success "Command /$cmd is available"
    else
        print_error "Command /$cmd is missing (.claude/commands/$cmd.md)"
    fi
done

# Test 5: Simulate hook execution (dry run)
print_info "Test 5: Testing hook logic (dry run)..."

# Enable debug mode for testing
export AI_DOCS_DEBUG=1

if [ -f ".git/hooks/post-commit" ]; then
    print_info "Testing post-commit hook logic..."
    
    # Create a temporary test by checking if the hook can parse configuration
    if sh -n ".git/hooks/post-commit"; then
        print_success "post-commit hook syntax is valid"
    else
        print_error "post-commit hook has syntax errors"
    fi
else
    print_warning "post-commit hook not found"
fi

if [ -f ".git/hooks/pre-push" ]; then
    print_info "Testing pre-push hook logic..."
    
    if sh -n ".git/hooks/pre-push"; then
        print_success "pre-push hook syntax is valid"
    else
        print_error "pre-push hook has syntax errors"
    fi
else
    print_warning "pre-push hook not found"
fi

echo ""
echo "=========================================="
echo "Test Summary:"
echo ""

if [ "$HOOKS_INSTALLED" = "true" ] && command -v claude >/dev/null 2>&1; then
    print_success "All critical components are working!"
    echo ""
    print_info "To test the full workflow:"
    print_info "1. Make a change to a source file"
    print_info "2. Commit it: git add . && git commit -m 'test: trigger docs update'"
    print_info "3. Check if documentation was updated"
    print_info ""
    print_info "For verbose debugging, set: export AI_DOCS_DEBUG=1"
else
    print_warning "Some components need attention. Please review the test results above."
fi

echo ""