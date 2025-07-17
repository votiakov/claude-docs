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

print_status "Downloading command files..."
curl -sSL "$GITHUB_REPO/.claude/commands/init-ai-docs.md" -o .claude/commands/init-ai-docs.md
curl -sSL "$GITHUB_REPO/.claude/commands/update-ai-docs.md" -o .claude/commands/update-ai-docs.md

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
cat > .claude/ai-docs-config.json << EOF
{
  "sourceDirectories": [$(echo "$SOURCE_DIRS" | sed 's/[^ ]*/\"&\"/g' | sed 's/ /,/g' | sed 's/,$//g')],
  "fileExtensions": [$(echo "$FILE_EXTENSIONS" | sed 's/[^ ]*/\"&\"/g' | sed 's/ /,/g' | sed 's/,$//g')],
  "ignorePatterns": ["node_modules/", "dist/", "build/", ".git/", "target/", "__pycache__/", ".next/", ".nuxt/", "vendor/", "coverage/"],
  "framework": "$FRAMEWORK"
}
EOF

print_status "Generated .claude/ai-docs-config.json with detected settings"
print_warning "Please review and customize .claude/ai-docs-config.json to match your project structure"

print_status "Downloading settings.json..."
if [ -f ".claude/settings.json" ]; then
    print_warning "settings.json already exists. Creating backup..."
    cp .claude/settings.json .claude/settings.json.backup
fi
curl -sSL "$GITHUB_REPO/.claude/settings.json" -o .claude/settings.json

print_status "Setting up git hooks..."

# Create post-commit hook (triggers after each commit)
if [ -f ".git/hooks/post-commit" ]; then
    print_warning "post-commit hook already exists. Creating backup..."
    cp .git/hooks/post-commit .git/hooks/post-commit.backup
fi

cat > .git/hooks/post-commit << 'EOF'
#!/bin/sh
# Update AI docs after commit if source files were changed

# Read AI docs configuration
if [ -f ".claude/ai-docs-config.json" ]; then
    # Extract source directories and file extensions from config
    SOURCE_DIRS=$(python3 -c "
import json
try:
    with open('.claude/ai-docs-config.json', 'r') as f:
        config = json.load(f)
    dirs = config.get('sourceDirectories', ['src/', 'lib/'])
    print('|'.join([d.rstrip('/') + '/' for d in dirs]))
except:
    print('src/|lib/')
" 2>/dev/null || echo "src/|lib/")
    
    FILE_EXTENSIONS=$(python3 -c "
import json
try:
    with open('.claude/ai-docs-config.json', 'r') as f:
        config = json.load(f)
    exts = config.get('fileExtensions', ['.js', '.ts', '.py'])
    print('|'.join([ext.lstrip('.') for ext in exts]))
except:
    print('js|ts|py')
" 2>/dev/null || echo "js|ts|py")
else
    # Fallback to generic defaults (covers most common scenarios)
    SOURCE_DIRS="src/|lib/|app/|components/|pages/|utils/|helpers/|modules/|packages/"
    FILE_EXTENSIONS="js|ts|jsx|tsx|py|java|rb|go|php|c|cpp|cs|rs|swift|kt|scala|clj|ex|erl|pl|r|m|h|vue|svelte"
fi

# Check if any files in detected source directories with detected extensions changed
CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)
if echo "$CHANGED_FILES" | grep -E "^($SOURCE_DIRS).*\.($FILE_EXTENSIONS)$" >/dev/null 2>&1; then
    echo "Source files were modified in last commit. Updating AI documentation..."
    if command -v claude >/dev/null 2>&1; then
        # Pass changed files to update command for incremental analysis
        RELEVANT_FILES=$(echo "$CHANGED_FILES" | grep -E "^($SOURCE_DIRS).*\.($FILE_EXTENSIONS)$" | tr '\n' ',' | sed 's/,$//')
        claude -p "Run /update-ai-docs --changed-files='$RELEVANT_FILES'" || echo "Failed to update docs"
        
        # Check if docs were actually updated
        if [ -n "$(git status --porcelain ai_docs/)" ]; then
            echo "AI documentation was updated. Creating documentation commit..."
            git add ai_docs/
            git commit -m "docs: Auto-update AI documentation

Generated from commit $(git rev-parse HEAD~1 | cut -c1-7)
Modified files: $RELEVANT_FILES" || echo "Failed to commit docs"
        else
            echo "No documentation changes needed."
        fi
    else
        echo "Claude CLI not found. Skipping doc update."
    fi
else
    echo "No source files modified in last commit. Skipping documentation update."
fi
EOF

chmod +x .git/hooks/post-commit

# Also create pre-push hook as a fallback
if [ -f ".git/hooks/pre-push" ]; then
    print_warning "pre-push hook already exists. Creating backup..."
    cp .git/hooks/pre-push .git/hooks/pre-push.backup
fi

cat > .git/hooks/pre-push << 'EOF'
#!/bin/sh
# Fallback: Update AI docs before push if not already done

# Read AI docs configuration
if [ -f ".claude/ai-docs-config.json" ]; then
    SOURCE_DIRS=$(python3 -c "
import json
try:
    with open('.claude/ai-docs-config.json', 'r') as f:
        config = json.load(f)
    dirs = config.get('sourceDirectories', ['src/', 'lib/'])
    print('|'.join([d.rstrip('/') + '/' for d in dirs]))
except:
    print('src/|lib/')
" 2>/dev/null || echo "src/|lib/")
    
    FILE_EXTENSIONS=$(python3 -c "
import json
try:
    with open('.claude/ai-docs-config.json', 'r') as f:
        config = json.load(f)
    exts = config.get('fileExtensions', ['.js', '.ts', '.py'])
    print('|'.join([ext.lstrip('.') for ext in exts]))
except:
    print('js|ts|py')
" 2>/dev/null || echo "js|ts|py")
else
    # Fallback to generic defaults (covers most common scenarios)
    SOURCE_DIRS="src/|lib/|app/|components/|pages/|utils/|helpers/|modules/|packages/"
    FILE_EXTENSIONS="js|ts|jsx|tsx|py|java|rb|go|php|c|cpp|cs|rs|swift|kt|scala|clj|ex|erl|pl|r|m|h|vue|svelte"
fi

# Check if docs are up to date
if [ -z "$(git log --oneline -1 | grep 'docs: Auto-update AI documentation')" ]; then
    if git diff --name-only HEAD~5..HEAD | grep -E "^($SOURCE_DIRS).*\.($FILE_EXTENSIONS)$" >/dev/null 2>&1; then
        echo "Source files were modified recently but docs may not be up to date. Updating..."
        if command -v claude >/dev/null 2>&1; then
            RECENT_FILES=$(git diff --name-only HEAD~5..HEAD | grep -E "^($SOURCE_DIRS).*\.($FILE_EXTENSIONS)$" | tr '\n' ',' | sed 's/,$//')
            claude -p "Run /update-ai-docs --changed-files='$RECENT_FILES'" || echo "Failed to update docs"
            if [ -n "$(git status --porcelain ai_docs/)" ]; then
                echo "Documentation was updated. Please commit and push again."
                exit 1
            fi
        fi
    fi
fi
EOF

chmod +x .git/hooks/pre-push

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
    pkg.scripts['docs:init'] = "claude -p 'Run /init-ai-docs'";
    pkg.scripts['docs:update'] = "claude -p 'Run /update-ai-docs'";
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
echo "1. Review and customize: .claude/ai-docs-config.json (optional but recommended)"
echo "2. Run: claude -p 'Run /init-ai-docs' to initialize documentation"
echo "3. Verify installation: ls -la .claude/"
echo "4. Check your first AI documentation: cat ai_docs/README.md"
echo ""
echo "📚 Available commands:"
echo "- claude -p 'Run /init-ai-docs'     # Initialize documentation"
echo "- claude -p 'Run /update-ai-docs'  # Update documentation"
echo "- npm run docs:init                        # Alternative npm script"
echo "- npm run docs:update                      # Alternative npm script"
echo ""
echo "🔧 Features enabled:"
echo "- ✅ Custom Claude commands"
echo "- ✅ Git hooks for auto-updates"
echo "- ✅ GitHub Actions workflow"
echo "- ✅ NPM scripts (if package.json exists)"
echo "- ✅ Claude hooks for real-time updates"
echo ""
print_status "Happy documenting! 🚀"