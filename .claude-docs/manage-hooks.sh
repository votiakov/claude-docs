#!/bin/bash

# AI Documentation Framework - Git Hooks Management Script
# Manages enabling and disabling of git hooks for documentation updates

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[HOOKS]${NC} $1"
}

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "This script must be run from the root of a git repository"
    exit 1
fi

# Check if .claude-docs exists
if [ ! -d ".claude-docs" ]; then
    print_error ".claude-docs directory not found. Please run the AI Documentation Framework installer first."
    exit 1
fi

# Function to show usage
show_usage() {
    echo "AI Documentation Framework - Git Hooks Manager"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  enable        Enable git hooks for automatic documentation updates"
    echo "  disable       Disable git hooks (backup originals if they exist)"
    echo "  status        Show current status of git hooks"
    echo "  reinstall     Reinstall hooks (useful after updates)"
    echo "  help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 enable     # Enable documentation hooks"
    echo "  $0 disable    # Disable hooks and restore backups"
    echo "  $0 status     # Check if hooks are active"
}

# Function to update config enabled status
update_config_status() {
    local enabled="$1"
    
    if [ -f ".claude-docs/config.json" ]; then
        # Use python to update the enabled status
        python3 << EOF
import json
import os

config_file = '.claude-docs/config.json'
if os.path.exists(config_file):
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
        config['enabled'] = $enabled
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        print("Updated config.json enabled status to $enabled")
    except Exception as e:
        print(f"Failed to update config: {e}")
else:
    # Create basic config if it doesn't exist
    config = {
        "enabled": $enabled,
        "sourceDirectories": ["src/", "lib/"],
        "fileExtensions": [".js", ".ts", ".py"],
        "ignorePatterns": ["node_modules/", "dist/", "build/", ".git/"],
        "framework": "unknown"
    }
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    print("Created config.json with enabled status $enabled")
EOF
    fi
}

# Function to enable hooks
enable_hooks() {
    print_status "Enabling AI documentation git hooks..."
    
    # Backup existing hooks if they exist
    for hook in post-commit pre-push; do
        if [ -f ".git/hooks/$hook" ] && [ ! -f ".git/hooks/$hook.ai-docs-backup" ]; then
            print_info "Backing up existing $hook hook..."
            cp ".git/hooks/$hook" ".git/hooks/$hook.ai-docs-backup"
        fi
    done
    
    # Install post-commit hook
    if [ -f ".claude-docs/hooks/post-commit" ]; then
        print_info "Installing post-commit hook..."
        cp ".claude-docs/hooks/post-commit" ".git/hooks/post-commit"
        chmod +x ".git/hooks/post-commit"
    else
        print_error "Hook template .claude-docs/hooks/post-commit not found"
        exit 1
    fi
    
    # Install pre-push hook
    if [ -f ".claude-docs/hooks/pre-push" ]; then
        print_info "Installing pre-push hook..."
        cp ".claude-docs/hooks/pre-push" ".git/hooks/pre-push"
        chmod +x ".git/hooks/pre-push"
    else
        print_error "Hook template .claude-docs/hooks/pre-push not found"
        exit 1
    fi
    
    # Update config to enabled
    update_config_status true
    
    print_status "✅ Git hooks enabled successfully!"
    echo ""
    print_info "Hooks installed:"
    print_info "  • post-commit: Updates documentation after each commit"
    print_info "  • pre-push: Ensures documentation is up to date before push"
    echo ""
    print_info "Configuration updated: .claude-docs/config.json (enabled: true)"
}

# Function to disable hooks
disable_hooks() {
    print_status "Disabling AI documentation git hooks..."
    
    # Remove our hooks and restore backups if they exist
    for hook in post-commit pre-push; do
        if [ -f ".git/hooks/$hook" ]; then
            print_info "Removing $hook hook..."
            rm ".git/hooks/$hook"
            
            # Restore backup if it exists
            if [ -f ".git/hooks/$hook.ai-docs-backup" ]; then
                print_info "Restoring original $hook hook from backup..."
                mv ".git/hooks/$hook.ai-docs-backup" ".git/hooks/$hook"
            fi
        fi
    done
    
    # Update config to disabled
    update_config_status false
    
    print_status "✅ Git hooks disabled successfully!"
    echo ""
    print_info "Hooks removed and original hooks restored (if they existed)"
    print_info "Configuration updated: .claude-docs/config.json (enabled: false)"
}

# Function to show status
show_status() {
    print_info "AI Documentation Framework Git Hooks Status"
    echo ""
    
    # Check if config exists and is enabled
    local config_enabled="unknown"
    if [ -f ".claude-docs/config.json" ]; then
        config_enabled=$(python3 -c "
import json
try:
    with open('.claude-docs/config.json', 'r') as f:
        config = json.load(f)
    print('true' if config.get('enabled', True) else 'false')
except:
    print('unknown')
" 2>/dev/null || echo "unknown")
    fi
    
    echo "Configuration status: $config_enabled"
    echo ""
    
    # Check each hook
    for hook in post-commit pre-push; do
        if [ -f ".git/hooks/$hook" ]; then
            if [ -x ".git/hooks/$hook" ]; then
                echo "✅ $hook: Installed and executable"
                # Check if it's our hook by looking for our signature
                if grep -q "AI Documentation Framework" ".git/hooks/$hook" 2>/dev/null; then
                    echo "   └─ AI Documentation Framework hook detected"
                else
                    echo "   └─ Custom hook (not from AI Documentation Framework)"
                fi
            else
                echo "⚠️  $hook: Installed but not executable"
            fi
            
            # Check for backup
            if [ -f ".git/hooks/$hook.ai-docs-backup" ]; then
                echo "   └─ Original hook backup exists"
            fi
        else
            echo "❌ $hook: Not installed"
        fi
    done
    
    echo ""
    
    # Show configuration details if available
    if [ -f ".claude-docs/config.json" ]; then
        echo "Current configuration (.claude-docs/config.json):"
        python3 -c "
import json
try:
    with open('.claude-docs/config.json', 'r') as f:
        config = json.load(f)
    print(f\"  Framework: {config.get('framework', 'unknown')}\")
    print(f\"  Source directories: {', '.join(config.get('sourceDirectories', []))}\")
    print(f\"  File extensions: {', '.join(config.get('fileExtensions', []))}\")
    print(f\"  Enabled: {config.get('enabled', True)}\")
except Exception as e:
    print(f\"  Error reading config: {e}\")
"
    else
        echo "No configuration file found (.claude-docs/config.json)"
    fi
}

# Function to reinstall hooks
reinstall_hooks() {
    print_status "Reinstalling AI documentation git hooks..."
    disable_hooks
    echo ""
    enable_hooks
}

# Main script logic
case "${1:-help}" in
    "enable")
        enable_hooks
        ;;
    "disable")
        disable_hooks
        ;;
    "status")
        show_status
        ;;
    "reinstall")
        reinstall_hooks
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac