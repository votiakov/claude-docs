#!/bin/bash
# Auto-update documentation after code changes

# Check if source files were modified
if git diff --name-only | grep -E '\.(js|ts|py|java|rb|go|php|c|cpp|cs|rs|swift|kt|scala|clj|ex|erl|pl|r|m|h)$'; then
  echo "Source files modified, updating AI documentation..."
  
  # Get list of modified files
  MODIFIED=$(git diff --name-only | grep -E '\.(js|ts|py|java|rb|go|php|c|cpp|cs|rs|swift|kt|scala|clj|ex|erl|pl|r|m|h)$')
  
  # Run targeted documentation update
  npx claude -p "Update AI documentation for these modified files: $MODIFIED" --output-format json
  
  # Stage documentation changes
  git add ai_docs/
fi