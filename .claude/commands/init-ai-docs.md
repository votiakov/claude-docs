# Initialize AI Documentation

Initialize comprehensive AI-optimized documentation for the project.

## Workflow

1. Create the ai_docs directory structure:
   - ai_docs/
   - ai_docs/architecture/
   - ai_docs/features/
   - ai_docs/api/
   - ai_docs/setup/
   - ai_docs/troubleshooting/
   - ai_docs/code_patterns/

2. Analyze the entire codebase to understand:
   - Project structure and main components
   - Technology stack and dependencies
   - Key features and functionality
   - API endpoints and data models
   - Common patterns and conventions

3. Generate comprehensive documentation:

   **ai_docs/README.md:**
   - Overview of the AI documentation structure
   - How to navigate and use these docs
   - Maintenance guidelines

   **ai_docs/project_context.md:**
   - Project name, purpose, and description
   - Main features (bulleted list)
   - Technology stack summary
   - Key architectural decisions
   - Business domain concepts

   **ai_docs/architecture/overview.md:**
   - System architecture diagram (ASCII or Mermaid)
   - Component descriptions and responsibilities
   - Data flow between components
   - External integrations

   **ai_docs/architecture/components.md:**
   - Detailed breakdown of each major component
   - File locations and naming conventions
   - Inter-component communication

   **ai_docs/architecture/tech_stack.md:**
   - Complete list of technologies used
   - Rationale for each choice
   - Version requirements
   - Key dependencies and their purposes

   **ai_docs/features/:** (create subfolder for each major feature)
   - overview.md: Feature description and business value
   - implementation.md: Technical implementation details
   - api.md: Related API endpoints (if applicable)

   **ai_docs/api/endpoints.md:**
   - All REST/GraphQL endpoints
   - Request/response formats
   - Authentication requirements
   - Rate limiting information

   **ai_docs/api/schemas.md:**
   - Data models and types
   - Validation rules
   - Database schemas

   **ai_docs/api/examples.md:**
   - Common use case examples
   - Full request/response cycles
   - Error handling examples

   **ai_docs/setup/installation.md:**
   - Prerequisites
   - Step-by-step installation
   - Environment setup
   - Verification steps

   **ai_docs/setup/configuration.md:**
   - All environment variables
   - Configuration files and options
   - Feature flags

   **ai_docs/troubleshooting/common_issues.md:**
   Format as Q&A pairs:
   ```
   ### Q: [Common problem]
   **A**: [Solution with steps]
   ```

   **ai_docs/code_patterns/conventions.md:**
   - Naming conventions
   - File organization
   - Code style guidelines
   - Git workflow

4. Create automation files:

   **.github/workflows/update-ai-docs.yml:**
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
             npx claude -p "Run /project:update-ai-docs to update documentation"
         - name: Commit changes
           run: |
             git config --local user.email "action@github.com"
             git config --local user.name "GitHub Action"
             git add ai_docs/
             git commit -m "docs: Update AI documentation" || echo "No changes"
         - name: Push changes
           uses: ad-m/github-push-action@master
   ```

   **package.json scripts:**
   ```json
   {
     "scripts": {
       "docs:init": "claude -p 'Run /project:init-ai-docs'",
       "docs:update": "claude -p 'Run /project:update-ai-docs'",
       "docs:lint": "markdownlint ai_docs/**/*.md"
     }
   }
   ```

5. Update CLAUDE.md with AI docs usage:
   ```markdown
   ## AI Documentation
   
   This project includes AI-optimized documentation in the `ai_docs/` folder.
   
   - To update docs: Run `/project:update-ai-docs`
   - Docs auto-update on commits to main branch
   - Each file is self-contained for AI comprehension
   ```

6. Create git hooks configuration in .git/hooks/pre-push:
   ```bash
   #!/bin/sh
   # Update AI docs before push
   if git diff --cached --name-only | grep -E '\.(js|ts|py|java|rb|go|php|c|cpp|cs|rs|swift|kt|scala|clj|ex|erl|pl|r|m|h)$'; then
     npm run docs:update
     git add ai_docs/
     git commit -m "docs: Auto-update AI documentation" || true
   fi
   ```

## Usage
Run: `/project:init-ai-docs`