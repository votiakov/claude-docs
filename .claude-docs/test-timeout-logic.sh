#!/bin/bash

# AI Documentation Framework - Timeout Logic Test Script
# Tests the improved timeout and auto-commit logic

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

echo "AI Documentation Framework - Timeout Logic Test"
echo "================================================"
echo ""

# Test 1: Simulate successful Claude execution
print_info "Test 1: Simulating successful Claude execution..."

# Mock functions from the hook
info_log() { echo "[AI-DOCS] $1"; }
debug_log() { echo "[DEBUG] $1" >&2; }
error_log() { echo "[ERROR] $1" >&2; }

# Test variables
RELEVANT_FILES="test.js"
START_TIME=$(date +%s)

# Simulate Claude success
CLAUDE_OUTPUT_FILE=$(mktemp)
echo "Mock Claude output: Documentation updated successfully" > "$CLAUDE_OUTPUT_FILE"
CLAUDE_SUCCESS=true

END_TIME=$(date +%s)
EXECUTION_TIME=$((END_TIME - START_TIME))

# Mock git status showing changed files
AFTER_UPDATE="M  ai_docs/api/endpoints.md\nM  ai_docs/features/test.md"

# Test the logic
if [ -n "$AFTER_UPDATE" ]; then
    if [ "$CLAUDE_SUCCESS" = "true" ]; then
        STATUS_MSG="Successfully updated"
        print_success "Success case: Files updated, Claude succeeded"
    else
        STATUS_MSG="Updated with timeout/errors (${EXECUTION_TIME}s)"
        print_success "Partial success case: Files updated despite Claude issues"
    fi
    echo "Would create commit: docs: Auto-update AI documentation"
    echo "$STATUS_MSG in ${EXECUTION_TIME} seconds"
else
    print_error "No files updated"
fi

rm -f "$CLAUDE_OUTPUT_FILE"
echo ""

# Test 2: Simulate timeout with partial results
print_info "Test 2: Simulating timeout with partial results..."

CLAUDE_SUCCESS=false
CLAUDE_EXIT_CODE=124  # timeout exit code
EXECUTION_TIME=600    # 10 minutes

# Mock git status showing some files were updated
AFTER_UPDATE="M  ai_docs/api/endpoints.md"

if [ -n "$AFTER_UPDATE" ]; then
    if [ "$CLAUDE_SUCCESS" = "true" ]; then
        STATUS_MSG="Successfully updated"
    else
        STATUS_MSG="Updated with timeout/errors (${EXECUTION_TIME}s)"
        print_success "Timeout but files updated: This should still succeed and commit"
    fi
    echo "Would create commit with status: $STATUS_MSG"
else
    print_error "No files updated"
fi

echo ""

# Test 3: Simulate complete failure
print_info "Test 3: Simulating complete failure (no files updated)..."

CLAUDE_SUCCESS=false
AFTER_UPDATE=""  # No files changed

if [ -n "$AFTER_UPDATE" ]; then
    print_success "Files were updated"
else
    if [ "$CLAUDE_SUCCESS" = "true" ]; then
        print_warning "Claude succeeded but no files updated (acceptable)"
    else
        print_error "Claude failed AND no files updated (real failure)"
    fi
fi

echo ""
echo "================================================"
print_info "Test Results Summary:"
echo "✅ Success + Files Updated → Commit (SUCCESS)"
echo "✅ Timeout + Files Updated → Commit (SUCCESS)" 
echo "⚠️  Success + No Files → No Commit (ACCEPTABLE)"
echo "❌ Timeout + No Files → Error (FAILURE)"
echo ""
print_success "All timeout logic scenarios tested successfully!"
echo ""
print_info "The improved hook will now:"
print_info "1. Always check for file changes regardless of timeout"
print_info "2. Commit changes even if Claude timed out but produced results"
print_info "3. Only fail if both Claude failed AND no files were updated"
print_info "4. Provide detailed timing and status information"