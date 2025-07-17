# Update AI Documentation

Update existing AI documentation based on code changes with intelligent incremental analysis.

## Action Steps

1. **FIRST: Check if ai_docs/ directory exists**:
   ```
   Use the LS tool to check if ai_docs/ directory exists.
   If it doesn't exist, immediately run: /init-ai-docs
   If it exists, continue with the update process.
   ```

2. **Load project configuration**:
   ```
   Use the Read tool to read `.claude-docs/config.json` if it exists.
   Extract sourceDirectories, fileExtensions, and framework information.
   If config doesn't exist, use these defaults:
   - sourceDirectories: ["src/", "lib/", "app/", "components/"]
   - fileExtensions: [".js", ".ts", ".jsx", ".tsx", ".py", ".java", ".go"]
   ```

3. **Analyze changed files** (if `--changed-files` provided):
   ```
   Parse the comma-separated list of changed files from the arguments.
   Use the Read tool to examine each changed file.
   Categorize changes by type (API, components, config, architectural).
   Use Task tools to analyze multiple files in parallel for efficiency.
   ```

4. **CRITICAL: Actually update documentation files using Write/Edit tools**:
   
   **For API/endpoint changes:**
   ```
   Use the Read tool to examine ai_docs/api/endpoints.md
   Use the Edit tool to update endpoint documentation with new/modified endpoints
   Use the Read tool to examine ai_docs/api/schemas.md
   Use the Edit tool to update data models if they changed
   Use the Read tool to examine ai_docs/api/examples.md
   Use the Edit tool to add new usage examples
   ```
   
   **For component/feature changes:**
   ```
   Use the LS tool to check ai_docs/features/ directory structure
   Use the Read tool to examine existing feature documentation
   Use the Edit tool to update implementation details in relevant files
   Use the Write tool to create new feature documentation if needed
   ```
   
   **For configuration changes:**
   ```
   Use the Read tool to examine ai_docs/setup/configuration.md
   Use the Edit tool to update configuration documentation
   Use the Read tool to examine ai_docs/setup/installation.md
   Use the Edit tool to update installation steps if needed
   Use the Read tool to examine ai_docs/architecture/tech_stack.md
   Use the Edit tool to update technology stack if dependencies changed
   ```
   
   **For architectural changes:**
   ```
   Use the Read tool to examine ai_docs/architecture/overview.md
   Use the Edit tool to update system architecture documentation
   Use the Read tool to examine ai_docs/architecture/components.md
   Use the Edit tool to modify component descriptions
   Use the Read tool to examine ai_docs/project_context.md
   Use the Edit tool to update project context if major changes occurred
   ```

5. **MANDATORY: Use Task agents for parallel processing**:
   ```
   Launch 2-4 Task agents simultaneously using the Task tool:
   - Agent 1: Handle API documentation updates
   - Agent 2: Handle feature/component documentation
   - Agent 3: Handle architecture/configuration updates
   - Agent 4: Handle cross-references and validation
   Each agent MUST use Read/Edit/Write tools to actually modify files.
   ```

6. **ESSENTIAL: Validation and file writing**:
   ```
   Use the Read tool to verify each updated file
   Use the Edit tool to fix any broken internal links
   Use the Edit tool to update timestamps on modified sections
   Ensure all documentation files have been actually written to disk
   ```

## CRITICAL REQUIREMENTS

- **Must use Read/Write/Edit tools**: Every documentation update MUST use these tools to actually modify files
- **Must check file existence**: Always verify ai_docs/ exists before updating
- **Must use Task agents**: Launch parallel agents for efficiency, each agent must write files
- **Must validate changes**: Use Read tool to confirm files were actually updated
- **Must preserve existing content**: Only update relevant sections, don't overwrite entire files unnecessarily

## Arguments
- `--changed-files='file1.js,file2.ts,file3.py'`: Comma-separated list of changed files for incremental analysis
- `$ARGUMENTS`: Specific paths or features to update (optional, for manual updates)

## EXECUTION REQUIREMENTS

**You MUST:**
1. Use the LS tool to check if ai_docs/ exists
2. Use the Read tool to examine current documentation
3. Use the Edit/Write tools to actually modify documentation files
4. Use Task tools to launch parallel agents for efficiency
5. Verify that files were actually written using Read tool

**Success means:** Documentation files are actually updated on disk, not just analyzed.

## Usage Examples
- `claude -p "Run /update-ai-docs --changed-files='src/api/users.js,src/components/UserList.jsx'"` (incremental)
- `claude -p "Run /update-ai-docs api/users"` (manual feature update)
- `claude -p "Run /update-ai-docs"` (full analysis - fallback mode)