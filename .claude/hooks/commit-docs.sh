#!/bin/bash
# Commit documentation updates if any

if git diff --staged --name-only | grep -q '^ai_docs/'; then
  git commit -m "docs: Auto-update AI documentation [skip ci]" || true
  echo "Documentation updates committed"
fi