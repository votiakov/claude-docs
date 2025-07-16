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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Creating Claude command directories..."
mkdir -p .claude/commands .claude/hooks

print_status "Copying command files..."
cp "$SCRIPT_DIR/.claude/commands/init-ai-docs.md" .claude/commands/
cp "$SCRIPT_DIR/.claude/commands/update-ai-docs.md" .claude/commands/

print_status "Copying hook scripts..."
cp "$SCRIPT_DIR/.claude/hooks/update-docs.sh" .claude/hooks/
cp "$SCRIPT_DIR/.claude/hooks/commit-docs.sh" .claude/hooks/

print_status "Making hooks executable..."
chmod +x .claude/hooks/*.sh

print_status "Copying settings.json..."
if [ -f ".claude/settings.json" ]; then
    print_warning "settings.json already exists. Creating backup..."
    cp .claude/settings.json .claude/settings.json.backup
fi
cp "$SCRIPT_DIR/.claude/settings.json" .claude/settings.json

print_status "Setting up git hooks..."
if [ -f ".git/hooks/pre-push" ]; then
    print_warning "pre-push hook already exists. Creating backup..."
    cp .git/hooks/pre-push .git/hooks/pre-push.backup
fi

# Create pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/sh
# Update AI docs before push
if git diff --cached --name-only | grep -E '\.(js|ts|py|java|rb|go|php|c|cpp|cs|rs|swift|kt|scala|clj|ex|erl|pl|r|m|h)$'; then
    echo "Updating AI documentation before push..."
    if command -v claude >/dev/null 2>&1; then
        claude -p "Run /project:update-ai-docs" || echo "Failed to update docs"
        git add ai_docs/ 2>/dev/null || true
        git commit -m "docs: Auto-update AI documentation" || true
    else
        echo "Claude CLI not found. Skipping doc update."
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

cp "$SCRIPT_DIR/templates/update-ai-docs.yml" .github/workflows/

print_status "Updating package.json with documentation scripts..."
if [ -f "package.json" ]; then
    # Use node to update package.json
    node << 'EOF'
const fs = require('fs');
try {
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    pkg.scripts = pkg.scripts || {};
    pkg.scripts['docs:init'] = "claude -p 'Run /project:init-ai-docs'";
    pkg.scripts['docs:update'] = "claude -p 'Run /project:update-ai-docs'";
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
        echo "- \`/project:init-ai-docs\` - Initialize documentation (first time only)" >> CLAUDE.md
        echo "- \`/project:update-ai-docs\` - Update documentation after code changes" >> CLAUDE.md
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
- `/project:init-ai-docs` - Initialize documentation (first time only)
- `/project:update-ai-docs` - Update documentation after code changes

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
echo "1. Run: claude -p 'Run /project:init-ai-docs' to initialize documentation"
echo "2. Verify installation: ls -la .claude/"
echo "3. Check your first AI documentation: cat ai_docs/README.md"
echo ""
echo "📚 Available commands:"
echo "- claude -p 'Run /project:init-ai-docs'     # Initialize documentation"
echo "- claude -p 'Run /project:update-ai-docs'  # Update documentation"
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