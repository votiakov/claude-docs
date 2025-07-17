#!/bin/bash

# AI Documentation Framework for Claude Code - Installation Script
# This script installs the AI documentation framework into your project

set -e

echo "🚀 Installing AI Documentation Framework for Claude Code..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "This script must be run from the root of a git repository"
    exit 1
fi

# GitHub repository details
GITHUB_REPO="https://raw.githubusercontent.com/votiakov/claude-docs/main"

print_status "Creating Claude command directories..."
mkdir -p .claude/commands

print_status "Creating .claude-docs framework directory..."
mkdir -p .claude-docs/hooks

print_status "Downloading command files..."
curl -sSL "$GITHUB_REPO/.claude/commands/init-ai-docs.md" -o .claude/commands/init-ai-docs.md
curl -sSL "$GITHUB_REPO/.claude/commands/update-ai-docs.md" -o .claude/commands/update-ai-docs.md

print_status "Downloading framework files..."
curl -sSL "$GITHUB_REPO/.claude-docs/hooks/post-commit" -o .claude-docs/hooks/post-commit
curl -sSL "$GITHUB_REPO/.claude-docs/hooks/pre-push" -o .claude-docs/hooks/pre-push
curl -sSL "$GITHUB_REPO/.claude-docs/manage-hooks.sh" -o .claude-docs/manage-hooks.sh
chmod +x .claude-docs/manage-hooks.sh

print_status "Detecting project structure..."

# Function to detect framework/language
detect_framework() {
    if [ -f "package.json" ]; then
        if grep -q "react" package.json; then
            if grep -q "typescript" package.json; then
                echo "react-typescript"
            else
                echo "react-javascript"
            fi
        elif grep -q "vue" package.json; then
            echo "vue"
        elif grep -q "svelte" package.json; then
            echo "svelte"
        elif grep -q "next" package.json; then
            echo "nextjs"
        elif grep -q "express" package.json; then
            echo "nodejs-express"
        else
            echo "nodejs"
        fi
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        echo "python"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    elif [ -f "composer.json" ]; then
        echo "php"
    else
        echo "unknown"
    fi
}

# Function to detect source directories
detect_source_dirs() {
    local dirs=""
    
    # Common source directory patterns
    for dir in src lib app components pages utils helpers modules packages; do
        if [ -d "$dir" ]; then
            dirs="$dirs$dir/ "
        fi
    done
    
    # Framework-specific directories
    case "$1" in
        "react-"*|"vue"|"svelte")
            for dir in components hooks stores plugins; do
                if [ -d "$dir" ]; then
                    dirs="$dirs$dir/ "
                fi
            done
            ;;
        "nextjs")
            for dir in pages app components lib; do
                if [ -d "$dir" ]; then
                    dirs="$dirs$dir/ "
                fi
            done
            ;;
        "java")
            if [ -d "src/main/java" ]; then
                dirs="$dirs src/main/java/ "
            fi
            ;;
        "go")
            for dir in cmd pkg internal; do
                if [ -d "$dir" ]; then
                    dirs="$dirs$dir/ "
                fi
            done
            ;;
        "rust")
            for dir in src examples benches; do
                if [ -d "$dir" ]; then
                    dirs="$dirs$dir/ "
                fi
            done
            ;;
        "python")
            # Look for Python package directories
            for dir in src lib $(find . -maxdepth 1 -name "*.py" -exec dirname {} \; | sort -u | grep -v "^\\.$"); do
                if [ -d "$dir" ] && [ "$dir" != "." ]; then
                    dirs="$dirs$dir/ "
                fi
            done
            ;;
    esac
    
    # If no specific directories found, default to common ones
    if [ -z "$dirs" ]; then
        dirs="src/ lib/ "
    fi
    
    echo "$dirs" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Function to detect file extensions
detect_file_extensions() {
    local framework="$1"
    local source_dirs="$2"
    local extensions=""
    
    # Find actual file extensions in source directories
    for dir in $source_dirs; do
        if [ -d "$dir" ]; then
            extensions="$extensions$(find "$dir" -type f -name "*.*" | sed 's/.*\./\./' | sort -u | tr '\n' ' ')"
        fi
    done
    
    # Framework-specific extensions
    case "$framework" in
        "react-typescript"|"nextjs")
            extensions="$extensions .ts .tsx .js .jsx"
            ;;
        "react-javascript")
            extensions="$extensions .js .jsx"
            ;;
        "vue")
            extensions="$extensions .vue .js .ts"
            ;;
        "svelte")
            extensions="$extensions .svelte .js .ts"
            ;;
        "nodejs"*)
            extensions="$extensions .js .ts .mjs"
            ;;
        "python")
            extensions="$extensions .py .pyx .pyi"
            ;;
        "java")
            extensions="$extensions .java .kt .scala"
            ;;
        "go")
            extensions="$extensions .go"
            ;;
        "rust")
            extensions="$extensions .rs"
            ;;
        "ruby")
            extensions="$extensions .rb .rake"
            ;;
        "php")
            extensions="$extensions .php .phtml"
            ;;
    esac
    
    # Clean up and deduplicate
    echo "$extensions" | tr ' ' '\n' | grep -E "^\\.." | sort -u | tr '\n' ' '
}

# Detect project characteristics
FRAMEWORK=$(detect_framework)
SOURCE_DIRS=$(detect_source_dirs "$FRAMEWORK")
FILE_EXTENSIONS=$(detect_file_extensions "$FRAMEWORK" "$SOURCE_DIRS")

print_status "Detected framework: $FRAMEWORK"
print_status "Source directories: $SOURCE_DIRS"
print_status "File extensions: $FILE_EXTENSIONS"

# Generate AI docs configuration with detected defaults
cat > .claude-docs/config.json << EOF
{
  "sourceDirectories": [$(echo "$SOURCE_DIRS" | sed 's/[^ ]*/\"&\"/g' | sed 's/ /,/g' | sed 's/,$//g')],
  "fileExtensions": [$(echo "$FILE_EXTENSIONS" | sed 's/[^ ]*/\"&\"/g' | sed 's/ /,/g' | sed 's/,$//g')],
  "ignorePatterns": ["node_modules/", "dist/", "build/", ".git/", "target/", "__pycache__/", ".next/", ".nuxt/", "vendor/", "coverage/"],
  "framework": "$FRAMEWORK",
  "enabled": true
}
EOF

print_status "Generated .claude-docs/config.json with detected settings"
print_warning "Please review and customize .claude-docs/config.json to match your project structure"

print_status "Downloading settings.json..."
if [ -f ".claude/settings.json" ]; then
    print_warning "settings.json already exists. Creating backup..."
    cp .claude/settings.json .claude/settings.json.backup
fi
curl -sSL "$GITHUB_REPO/.claude/settings.json" -o .claude/settings.json

print_status "Setting up git hooks using framework templates..."

# Use the manage-hooks.sh script to install hooks
if [ -f ".claude-docs/manage-hooks.sh" ]; then
    print_status "Installing git hooks via manage-hooks.sh..."
    ./.claude-docs/manage-hooks.sh enable
else
    print_error "manage-hooks.sh not found. Manual hook installation required."
fi

print_status "Creating GitHub Actions workflow template..."
mkdir -p .github/workflows
if [ -f ".github/workflows/update-ai-docs.yml" ]; then
    print_warning "GitHub Actions workflow already exists. Creating backup..."
    cp .github/workflows/update-ai-docs.yml .github/workflows/update-ai-docs.yml.backup
fi

curl -sSL "$GITHUB_REPO/templates/update-ai-docs.yml" -o .github/workflows/update-ai-docs.yml

print_status "Updating package.json with documentation scripts..."
if [ -f "package.json" ]; then
    # Use node to update package.json
    node << 'EOF'
const fs = require('fs');
try {
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    pkg.scripts = pkg.scripts || {};
    pkg.scripts['docs:init'] = "claude --permission-mode acceptEdits --print 'Run /init-ai-docs'";
    pkg.scripts['docs:update'] = "claude --permission-mode acceptEdits --print 'Run /update-ai-docs'";
    pkg.scripts['docs:lint'] = "markdownlint ai_docs/**/*.md";
    fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
    console.log('✅ Updated package.json with documentation scripts');
} catch (e) {
    console.log('⚠️  Could not update package.json:', e.message);
}
EOF
else
    print_warning "No package.json found. Skipping npm script setup."
fi

print_status "Updating CLAUDE.md..."
if [ -f "CLAUDE.md" ]; then
    if ! grep -q "AI Documentation System" CLAUDE.md; then
        echo "" >> CLAUDE.md
        echo "## AI Documentation System" >> CLAUDE.md
        echo "" >> CLAUDE.md
        echo "This project uses AI-optimized documentation stored in \`ai_docs/\`." >> CLAUDE.md
        echo "" >> CLAUDE.md
        echo "### Quick Commands" >> CLAUDE.md
        echo "- \`/init-ai-docs\` - Initialize documentation (first time only)" >> CLAUDE.md
        echo "- \`/update-ai-docs\` - Update documentation after code changes" >> CLAUDE.md
        echo "" >> CLAUDE.md
        echo "### Automation" >> CLAUDE.md
        echo "- Documentation auto-updates on push to main branch" >> CLAUDE.md
        echo "- Pre-push hooks update docs for local changes" >> CLAUDE.md
        echo "- Each document is self-contained for optimal AI comprehension" >> CLAUDE.md
        echo "" >> CLAUDE.md
        echo "### Structure" >> CLAUDE.md
        echo "- \`project_context.md\` - High-level project overview" >> CLAUDE.md
        echo "- \`architecture/\` - System design documentation" >> CLAUDE.md
        echo "- \`features/\` - Feature-specific guides" >> CLAUDE.md
        echo "- \`api/\` - API references and examples" >> CLAUDE.md
        echo "- \`troubleshooting/\` - Common issues in Q&A format" >> CLAUDE.md
        echo "" >> CLAUDE.md
        echo "For detailed guidelines, see \`ai_docs/README.md\` after initialization." >> CLAUDE.md
        print_status "Updated CLAUDE.md with AI documentation section"
    else
        print_warning "CLAUDE.md already contains AI documentation section"
    fi
else
    print_warning "No CLAUDE.md found. Creating one..."
    cat > CLAUDE.md << 'EOF'
# Project Documentation

## AI Documentation System

This project uses AI-optimized documentation stored in `ai_docs/`.

### Quick Commands
- `/init-ai-docs` - Initialize documentation (first time only)
- `/update-ai-docs` - Update documentation after code changes

### Automation
- Documentation auto-updates on push to main branch
- Pre-push hooks update docs for local changes
- Each document is self-contained for optimal AI comprehension

### Structure
- `project_context.md` - High-level project overview
- `architecture/` - System design documentation
- `features/` - Feature-specific guides
- `api/` - API references and examples
- `troubleshooting/` - Common issues in Q&A format

For detailed guidelines, see `ai_docs/README.md` after initialization.
EOF
fi

print_status "✅ Installation complete!"
echo ""
echo "🎉 Next steps:"
echo "1. Review and customize: .claude-docs/config.json (optional but recommended)"
echo "2. Run: claude --permission-mode acceptEdits --print 'Run /init-ai-docs' to initialize documentation"
echo "3. Verify installation: ls -la .claude/ .claude-docs/"
echo "4. Check your first AI documentation: cat ai_docs/README.md"
echo "5. Manage hooks: ./.claude-docs/manage-hooks.sh status"
echo ""
echo "📚 Available commands:"
echo "- claude --permission-mode acceptEdits --print 'Run /init-ai-docs'     # Initialize documentation"
echo "- claude --permission-mode acceptEdits --print 'Run /update-ai-docs'  # Update documentation"
echo "- npm run docs:init                        # Alternative npm script"
echo "- npm run docs:update                      # Alternative npm script"
echo ""
echo "🔧 Features enabled:"
echo "- ✅ Custom Claude commands"
echo "- ✅ Git hooks for auto-updates (managed via .claude-docs/manage-hooks.sh)"
echo "- ✅ GitHub Actions workflow"
echo "- ✅ NPM scripts (if package.json exists)"
echo "- ✅ Claude hooks for real-time updates"
echo "- ✅ Framework configuration system (.claude-docs/config.json)"
echo ""
print_status "Happy documenting! 🚀"