# Update AI Documentation

**IMMEDIATE ACTION REQUIRED: Start by using the LS tool to check if ai_docs/ directory exists. If it doesn't exist, run /init-ai-docs. Then proceed to actually modify files using Edit/Write tools. Do not provide summaries or analysis without making actual file changes.**

**CRITICAL INSTRUCTION: This command MUST result in modified files in the ai_docs/ directory. Your response is only successful if you use Read/Edit/Write tools to change actual files.**

Update existing AI documentation based on code changes with intelligent incremental analysis.

**EXAMPLE OF CORRECT EXECUTION:**
```
1. Use LS tool: Check if ai_docs/ exists
2. Use Read tool: Read ai_docs/api/endpoints.md  
3. Use Edit tool: Update the file with actual changes
4. Use Read tool: Verify the changes were made
RESULT: File is modified on disk
```

**CRITICAL SUCCESS CRITERIA:**
- Files in ai_docs/ directory must be physically modified on disk
- Use Read tool to examine current content
- Use Edit/Write tools to make actual changes
- Never provide only analysis without file modifications

**WRONG APPROACH (DO NOT DO THIS):**
- Providing summaries like "Documentation updates are needed"
- Listing what should be updated without actually updating it
- Analyzing changes without using Edit/Write tools

## MANDATORY Action Steps - You MUST Execute These

1. **FIRST: Check if ai_docs/ directory exists**:
   ```
   EXECUTE: Use the LS tool to check if ai_docs/ directory exists.
   If it doesn't exist, EXECUTE: Run /init-ai-docs command immediately
   If it exists, continue with the update process.
   DO NOT SKIP THIS STEP.
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

4. **CRITICAL: Actually update documentation files using Write/Edit tools - NO EXCEPTIONS**:
   
   **For API/endpoint changes (EXECUTE ALL STEPS):**
   ```
   STEP 1: EXECUTE Read tool on ai_docs/api/endpoints.md
   STEP 2: EXECUTE Edit tool to update endpoint documentation with changes
   STEP 3: EXECUTE Read tool on ai_docs/api/schemas.md (if exists)
   STEP 4: EXECUTE Edit tool to update data models if they changed
   STEP 5: EXECUTE Read tool on ai_docs/api/examples.md (if exists)
   STEP 6: EXECUTE Edit tool to add new usage examples
   VERIFICATION: Use Read tool to confirm changes were written
   ```
   
   **For component/feature changes (EXECUTE ALL STEPS):**
   ```
   STEP 1: EXECUTE LS tool on ai_docs/features/ directory
   STEP 2: EXECUTE Read tool on existing feature documentation files
   STEP 3: EXECUTE Edit tool to update implementation details
   STEP 4: EXECUTE Write tool to create new feature files if needed
   VERIFICATION: Use Read tool to confirm all changes were written
   ```
   
   **For configuration changes (EXECUTE ALL STEPS):**
   ```
   STEP 1: EXECUTE Read tool on ai_docs/setup/configuration.md
   STEP 2: EXECUTE Edit tool to update configuration documentation
   STEP 3: EXECUTE Read tool on ai_docs/setup/installation.md
   STEP 4: EXECUTE Edit tool to update installation steps if needed
   STEP 5: EXECUTE Read tool on ai_docs/architecture/tech_stack.md
   STEP 6: EXECUTE Edit tool to update technology stack
   VERIFICATION: Use Read tool to confirm all changes were written
   ```
   
   **For architectural changes (EXECUTE ALL STEPS):**
   ```
   STEP 1: EXECUTE Read tool on ai_docs/architecture/overview.md
   STEP 2: EXECUTE Edit tool to update system architecture documentation
   STEP 3: EXECUTE Read tool on ai_docs/architecture/components.md
   STEP 4: EXECUTE Edit tool to modify component descriptions
   STEP 5: EXECUTE Read tool on ai_docs/project_context.md
   STEP 6: EXECUTE Edit tool to update project context
   VERIFICATION: Use Read tool to confirm all changes were written
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

**CRITICAL SUCCESS REQUIREMENT:** Documentation files MUST be physically modified on disk using Edit/Write tools. 

**FAILURE INDICATORS:**
- Only providing text summaries or analysis
- Not using Read/Edit/Write tools
- Not verifying changes were written
- Saying "updates are needed" without making them

**SUCCESS INDICATORS:**
- Edit/Write tools were used on specific files
- Read tool confirms changes are present
- Specific files show modifications when checked

## Usage Examples
- `claude --permission-mode acceptEdits --print "Run /update-ai-docs --changed-files='src/api/users.js,src/components/UserList.jsx'"` (incremental)
- `claude --permission-mode acceptEdits --print "Run /update-ai-docs api/users"` (manual feature update)
- `claude --permission-mode acceptEdits --print "Run /update-ai-docs"` (full analysis - fallback mode)