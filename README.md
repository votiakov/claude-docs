# AI Documentation Framework for Claude Code

A comprehensive framework for generating and maintaining AI-optimized documentation for your projects using Claude Code.

## Features

- **Automated Documentation Generation**: Generate comprehensive documentation from your codebase
- **AI-Optimized Structure**: Documentation structured for optimal AI comprehension
- **Real-time Updates**: Auto-update documentation when code changes
- **Multiple Export Formats**: Support for various documentation formats
- **Git Integration**: Automatic documentation updates via git hooks
- **GitHub Actions**: Continuous documentation updates on push
- **Custom Claude Commands**: Easy-to-use slash commands for documentation management

## Quick Start

### One-Line Installation

```bash
# Run this in your project directory
curl -sSL https://raw.githubusercontent.com/votiakov/claude-docs/main/install.sh | bash
```

### Manual Installation

```bash
# In your project directory
curl -sSL https://raw.githubusercontent.com/votiakov/claude-docs/main/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

### From Source

```bash
# Clone this repository
git clone https://github.com/votiakov/claude-docs.git
cd claude-docs

# Copy install.sh to your project and run it
cp install.sh /path/to/your/project/
cd /path/to/your/project
./install.sh
```

### Initialize Documentation

```bash
# Initialize your project's AI documentation
claude --permission-mode acceptEdits "Run /init-ai-docs"

# Or using npm script
npm run docs:init
```

## Documentation Structure

After initialization, your project will have:

```
ai_docs/
├── README.md                    # Documentation overview
├── project_context.md           # High-level project context
├── architecture/
│   ├── overview.md             # System architecture
│   ├── components.md           # Component breakdown
│   └── tech_stack.md           # Technology stack
├── features/
│   └── [feature-name]/
│       ├── overview.md         # Feature description
│       ├── implementation.md   # Technical details
│       └── api.md             # API documentation
├── api/
│   ├── endpoints.md           # API endpoints
│   ├── schemas.md             # Data models
│   └── examples.md            # Usage examples
├── setup/
│   ├── installation.md        # Installation guide
│   └── configuration.md       # Configuration options
├── troubleshooting/
│   └── common_issues.md       # Q&A format issues
└── code_patterns/
    └── conventions.md         # Code style and patterns
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `/init-ai-docs` | Initialize documentation (first time only) |
| `/update-ai-docs` | Update documentation after code changes |
| `/update-ai-docs api/users` | Update specific feature documentation |

### NPM Scripts

```json
{
  "scripts": {
    "docs:init": "claude --permission-mode acceptEdits 'Run /init-ai-docs'",
    "docs:update": "claude --permission-mode acceptEdits 'Run /update-ai-docs'",
    "docs:lint": "markdownlint ai_docs/**/*.md"
  }
}
```

### Git Hooks

The framework automatically sets up git hooks to:
- **post-commit**: Update documentation after each commit that modifies source files
- **pre-push**: Fallback check to ensure documentation is up to date before pushing
- Automatically create documentation commits when changes are detected

### GitHub Actions

Automatic documentation updates on push to main branch:

```yaml
name: Update AI Documentation
on:
  push:
    branches: [main]
jobs:
  update-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Update AI Docs
        run: |
          npx claude --permission-mode acceptEdits "Run /update-ai-docs to update documentation"
```

## Quick Example

```bash
# 1. Install the framework in your project directory
curl -sSL https://raw.githubusercontent.com/votiakov/claude-docs/main/install.sh | bash

# 2. Customize configuration (optional but recommended)
# Edit .claude-docs/config.json to match your project structure

# 3. Initialize documentation
claude --permission-mode acceptEdits "Run /init-ai-docs"

# 4. Your ai_docs/ folder is now populated with comprehensive documentation!
ls ai_docs/
# README.md  project_context.md  architecture/  features/  api/  setup/  troubleshooting/  code_patterns/
```

## Configuration

### Project Configuration

After installation, customize `.claude-docs/config.json` to match your project:

```json
{
  "sourceDirectories": ["src/", "lib/", "components/"],
  "fileExtensions": [".js", ".ts", ".jsx", ".tsx"],
  "ignorePatterns": ["node_modules/", "dist/", "build/", ".git/"],
  "framework": "react-typescript",
  "enabled": true
}
```

**Configuration Fields:**
- `sourceDirectories`: Directories containing your source code
- `fileExtensions`: File types to monitor for changes
- `ignorePatterns`: Directories/files to ignore during analysis
- `framework`: Detected framework for context-aware documentation
- `enabled`: Whether the framework is active (managed by hooks)

**Note:** If this config file doesn't exist, the framework uses generic fallbacks covering most common project structures.

### Git Hooks Integration

The framework sets up intelligent git hooks that use your configuration:

**Post-commit hook** (`.git/hooks/post-commit`):
- Triggers after each commit
- Checks if files in configured source directories were modified
- Only monitors configured file extensions
- Updates AI documentation automatically for relevant changes
- Creates a separate documentation commit

**Pre-push hook** (`.git/hooks/pre-push`):
- Fallback to catch any missed documentation updates
- Uses same configuration to detect relevant changes
- Prevents push if documentation is out of sync
- Ensures documentation is always up to date before sharing

### Hook Management

The framework includes a powerful hook management system:

```bash
# Check current status
./.claude-docs/manage-hooks.sh status

# Enable git hooks
./.claude-docs/manage-hooks.sh enable

# Disable git hooks (restores backups)
./.claude-docs/manage-hooks.sh disable

# Reinstall hooks (useful after updates)
./.claude-docs/manage-hooks.sh reinstall
```

**Features:**
- Automatic backup and restoration of existing hooks
- Configuration-aware hook installation
- Easy enable/disable functionality
- Status checking with detailed information

### Supported File Types

The framework monitors these file extensions for changes:
- JavaScript/TypeScript: `.js`, `.ts`, `.jsx`, `.tsx`
- Python: `.py`
- Java: `.java`
- Ruby: `.rb`
- Go: `.go`
- PHP: `.php`
- C/C++: `.c`, `.cpp`, `.h`
- C#: `.cs`
- Rust: `.rs`
- Swift: `.swift`
- Kotlin: `.kt`
- Scala: `.scala`
- And more...

## Advanced Usage

### Custom Documentation Updates

```bash
# Update documentation for specific files
claude --permission-mode acceptEdits "Update AI documentation for these modified files: src/auth.js src/api.js"

# Update specific sections
claude --permission-mode acceptEdits "Run /update-ai-docs features/authentication"
```

### Troubleshooting

#### Common Issues

**Q: Documentation not updating automatically**
A: Check git hooks status and reinstall if needed:
```bash
./.claude-docs/manage-hooks.sh status
./.claude-docs/manage-hooks.sh reinstall
```

**Q: Hook seems to hang or not write files**
A: Enable debugging to see what's happening:
```bash
export AI_DOCS_DEBUG=1
# Then make a commit to trigger the hook
git commit -m "test: debug hook execution"
```

**Q: Want to test the entire setup**
A: Run the built-in test script:
```bash
./.claude-docs/test-hooks.sh
```

**Q: Claude commands not found**
A: Ensure Claude CLI is installed and commands are in `.claude/commands/`:
```bash
ls -la .claude/commands/
```

**Q: GitHub Actions not working**
A: Verify the workflow file exists and Claude CLI is available in the runner:
```bash
ls -la .github/workflows/update-ai-docs.yml
```

## File Structure

```
your-project/
├── .claude/
│   ├── commands/
│   │   ├── init-ai-docs.md
│   │   └── update-ai-docs.md
│   └── settings.json
├── .claude-docs/                # ← Framework files
│   ├── config.json             # ← Project-specific configuration
│   ├── manage-hooks.sh         # ← Hook management script
│   └── hooks/
│       ├── post-commit         # ← Hook templates
│       └── pre-push
├── .github/
│   └── workflows/
│       └── update-ai-docs.yml
├── ai_docs/
│   └── [generated documentation]
└── CLAUDE.md (updated)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with a sample project
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues and questions:
- Open an issue on GitHub
- Check the troubleshooting section
- Review Claude Code documentation

---

Made with ❤️ for the Claude Code community