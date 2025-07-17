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
claude -p "Run /init-ai-docs"

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
    "docs:init": "claude -p 'Run /init-ai-docs'",
    "docs:update": "claude -p 'Run /update-ai-docs'",
    "docs:lint": "markdownlint ai_docs/**/*.md"
  }
}
```

### Git Hooks

The framework automatically sets up git hooks to:
- Update documentation before pushing changes
- Commit documentation updates automatically
- Detect code changes and trigger updates

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
          npx claude -p "Run /update-ai-docs to update documentation"
```

## Quick Example

```bash
# 1. Install the framework in your project directory
curl -sSL https://raw.githubusercontent.com/votiakov/claude-docs/main/install.sh | bash

# 2. Initialize documentation
claude -p "Run /init-ai-docs"

# 3. Your ai_docs/ folder is now populated with comprehensive documentation!
ls ai_docs/
# README.md  project_context.md  architecture/  features/  api/  setup/  troubleshooting/  code_patterns/
```

## Configuration

### Claude Settings

The framework creates `.claude/settings.json` with:

```json
{
  "hooks": {
    "PostToolUse": {
      "Edit|MultiEdit|Write": "if git diff --name-only | grep -E '\\.(js|ts|py|java|rb|go|php|c|cpp|cs|rs|swift|kt|scala|clj|ex|erl|pl|r|m|h)$'; then echo 'Code files modified, updating AI docs...'; claude -p 'Run /update-ai-docs' || echo 'Failed to update docs'; fi"
    }
  },
  "projectSettings": {
    "aiDocsEnabled": true,
    "autoUpdateDocs": true,
    "documentationPaths": ["ai_docs/"]
  }
}
```

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
claude -p "Update AI documentation for these modified files: src/auth.js src/api.js"

# Update specific sections
claude -p "Run /update-ai-docs features/authentication"
```

### Troubleshooting

#### Common Issues

**Q: Documentation not updating automatically**
A: Check that git hooks are properly installed and executable:
```bash
ls -la .git/hooks/pre-push
chmod +x .git/hooks/pre-push
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