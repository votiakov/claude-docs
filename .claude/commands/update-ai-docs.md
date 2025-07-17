# Update AI Documentation

Update existing AI documentation based on code changes with intelligent incremental analysis.

## Workflow

1. **Load project configuration**:
   - Read `.claude-docs/config.json` to understand project structure
   - Get source directories, file extensions, and framework information
   - If config doesn't exist, use generic fallback patterns for common frameworks

2. **Analyze changed files** (if `--changed-files` provided):
   - Parse comma-separated list of changed files
   - Filter files based on detected source directories and extensions
   - Categorize changes by type (API, components, config, etc.)
   - Use parallel Task agents for efficient analysis of changed files only

3. **Smart documentation updates**:
   
   **For API/endpoint changes:**
   - Update `ai_docs/api/endpoints.md` with new/modified endpoints
   - Refresh `ai_docs/api/schemas.md` if data models changed
   - Update `ai_docs/api/examples.md` with new usage patterns
   
   **For component/feature changes:**
   - Update or create feature documentation in `ai_docs/features/[feature]/`
   - Refresh implementation details in `implementation.md`
   - Update feature overview if functionality changed
   
   **For configuration changes:**
   - Update `ai_docs/setup/configuration.md`
   - Refresh `ai_docs/setup/installation.md` if setup changed
   - Update `ai_docs/architecture/tech_stack.md` if dependencies changed
   
   **For architectural changes:**
   - Update `ai_docs/architecture/overview.md`
   - Modify component descriptions in `ai_docs/architecture/components.md`
   - Update project context if major changes occurred

4. **Incremental analysis approach**:
   - Use Task agents to analyze only changed files in parallel
   - Maintain context from existing documentation
   - Update only affected sections rather than regenerating everything
   - Preserve unchanged documentation to maintain consistency

5. **Cross-reference maintenance**:
   - Update links between related documents
   - Ensure consistency across all documentation
   - Update timestamps on modified sections only

6. **Validation and cleanup**:
   - Check for broken internal links
   - Ensure code examples are still valid
   - Verify API documentation matches implementation
   - Update analysis metadata if needed

## Performance Optimizations

- **Incremental processing**: Only analyze files that actually changed
- **Parallel analysis**: Use multiple Task agents for changed files
- **Context preservation**: Keep existing documentation context for unchanged areas
- **Smart categorization**: Route changes to appropriate documentation sections
- **Efficient updates**: Update only affected documentation files

## Arguments
- `--changed-files='file1.js,file2.ts,file3.py'`: Comma-separated list of changed files for incremental analysis
- `$ARGUMENTS`: Specific paths or features to update (optional, for manual updates)

## Usage Examples
- `claude -p "Run /update-ai-docs --changed-files='src/api/users.js,src/components/UserList.jsx'"` (incremental)
- `claude -p "Run /update-ai-docs api/users"` (manual feature update)
- `claude -p "Run /update-ai-docs"` (full analysis - fallback mode)