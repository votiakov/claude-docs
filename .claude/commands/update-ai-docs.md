# Update AI Documentation

Update existing AI documentation based on code changes.

## Workflow

1. Identify changed files since last documentation update:
   - Check git diff for modified source files
   - Identify new features or removed functionality
   - Note architectural changes

2. Update affected documentation:
   
   **For modified files:**
   - Update related feature documentation
   - Refresh API documentation if endpoints changed
   - Update examples if behavior changed
   
   **For new features:**
   - Create new feature folder in ai_docs/features/
   - Generate overview.md, implementation.md, api.md
   - Update project_context.md with new feature
   
   **For architectural changes:**
   - Update ai_docs/architecture/overview.md
   - Modify component descriptions
   - Update tech stack if dependencies changed

3. Regenerate cross-references:
   - Update links between related documents
   - Ensure consistency across all documentation
   - Update the main README.md index

4. Update timestamps:
   - Add "Last updated: [date]" to modified files
   - Update changelog if exists

5. Validate documentation:
   - Check for broken internal links
   - Ensure code examples are valid
   - Verify API documentation matches implementation

## Arguments
- $ARGUMENTS: Specific paths or features to update (optional)

## Usage
Run: `/update-ai-docs` or `/update-ai-docs api/users`