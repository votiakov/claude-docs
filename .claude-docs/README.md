# AI Documentation Framework - Internal Files

This directory contains the internal files for the AI Documentation Framework.

## Structure

```
.claude-docs/
├── config.json              # Project-specific configuration (created during installation)
├── config.template.json     # Template for config.json
├── manage-hooks.sh          # Git hooks management script
├── hooks/                   # Git hook templates
│   ├── post-commit         # Post-commit hook template
│   └── pre-push            # Pre-push hook template
└── README.md               # This file
```

## Files

### config.json
Project-specific configuration file created during installation. Contains:
- `sourceDirectories`: Directories to monitor for code changes
- `fileExtensions`: File types to track for documentation updates
- `ignorePatterns`: Patterns to ignore during analysis
- `framework`: Detected project framework
- `enabled`: Whether the framework is active

### manage-hooks.sh
Script for managing git hooks. Commands:
- `./manage-hooks.sh status` - Show current hook status
- `./manage-hooks.sh enable` - Install git hooks
- `./manage-hooks.sh disable` - Remove hooks and restore backups
- `./manage-hooks.sh reinstall` - Reinstall hooks

### hooks/
Template files for git hooks that are installed into `.git/hooks/` when enabled.

## Usage

After installing the AI Documentation Framework:

1. Review and customize `config.json` for your project
2. Use `./manage-hooks.sh status` to check hook status
3. Use `./manage-hooks.sh enable|disable` to control automatic documentation updates

This directory should not be modified manually unless you're contributing to the framework itself.