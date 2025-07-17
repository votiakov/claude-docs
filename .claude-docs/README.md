# AI Documentation Framework - Internal Files

This directory contains the internal files for the AI Documentation Framework.

## Structure

```
.claude-docs/
├── config.json              # Project-specific configuration (created during installation)
├── config.template.json     # Template for config.json
├── manage-hooks.sh          # Git hooks management script
├── test-hooks.sh            # Hook testing and debugging script
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

### test-hooks.sh
Testing and debugging script for the framework. Features:
- Tests if git hooks are properly installed
- Verifies Claude CLI availability
- Checks configuration validity
- Validates hook syntax
- Provides debugging guidance

### hooks/
Template files for git hooks that are installed into `.git/hooks/` when enabled.

## Usage

After installing the AI Documentation Framework:

1. Review and customize `config.json` for your project
2. Use `./manage-hooks.sh status` to check hook status
3. Use `./manage-hooks.sh enable|disable` to control automatic documentation updates
4. Use `./test-hooks.sh` to verify everything is working correctly

## Debugging

If documentation updates aren't working as expected:

1. **Run the test script**:
   ```bash
   ./.claude-docs/test-hooks.sh
   ```

2. **Enable debug mode**:
   ```bash
   export AI_DOCS_DEBUG=1
   git commit -m "test: debug documentation update"
   ```

3. **Check hook status**:
   ```bash
   ./.claude-docs/manage-hooks.sh status
   ```

4. **Reinstall hooks if needed**:
   ```bash
   ./.claude-docs/manage-hooks.sh reinstall
   ```

## Important Technical Notes

### Permission Modes
The framework uses `--permission-mode acceptEdits --print` to combine:
- `--permission-mode acceptEdits`: Allows Claude to execute Edit/Write tools
- `--print`: Runs in non-interactive mode (one-shot execution)

This ensures Claude can actually write files while running non-interactively in git hooks.

### Hook Architecture
Git hooks run in non-interactive environments, so they must use explicit permission modes. The framework automatically handles this by using `--permission-mode acceptEdits --print` in all automated commands.

This directory should not be modified manually unless you're contributing to the framework itself.