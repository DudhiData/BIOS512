# Qwen Code Interaction Guidelines for Project1

## Objective
Maximize optimized code quality with clear explanations while minimizing errors during development interactions.

## Code Quality Standards
- Always follow existing project conventions for formatting, naming, and structure
- Verify library/framework usage exists in the project before implementing
- Maintain consistency with local code style (imports, functions, classes)
- Add comments only when necessary to explain *why* something is done, not *what* is done
- Follow established architectural patterns in the codebase

## Tidyverse Focus
- Prioritize tidyverse packages (dplyr, tidyr, ggplot2, readr, purrr, etc.) for data manipulation
- Use pipe operators (%>%) consistently for readable code flow
- Follow tidy data principles (one observation per row, one variable per column)
- Prefer tidyverse functions over base R when equivalent functionality exists
- Use consistent naming conventions following tidyverse style (snake_case)

## Development Process
1. **Understand First**: Analyze the codebase using grep_search, glob, read_file before implementing
2. **Plan Complex Tasks**: Use todo_write for multi-step tasks (>3 steps)
3. **Implement Gradually**: Make iterative changes with proper context
4. **Verify Changes**: Run project-specific tests and build commands
5. **Test Thoroughly**: Ensure code works as expected before finalizing

## Error Prevention
- Always use absolute paths when reading/writing files
- Include sufficient context when using edit tool (3+ lines before/after target)
- Verify dependencies and imports exist before using them
- Check existing tests to understand expected behavior
- Run linting/type-checking tools after changes

## Communication Guidelines
- Provide concise, direct responses
- Explain security implications before running system-modifying commands
- Use GitHub-flavored Markdown for formatting
- Focus on the user's query with minimal unnecessary text
- When uncertain, ask for clarification rather than assuming

## Tool Usage Best Practices
- Use todo_write proactively for complex tasks
- Use grep_search and read_file to understand context before changes
- Use edit with precise context to avoid breaking code
- Use run_shell_command with appropriate background/foreground settings
- Verify code changes with project-specific testing commands

## Safety Rules
- Never store secrets, API keys, or sensitive information
- Always explain commands that modify the system before running
- Apply security best practices in all implementations
- Verify file paths before creating or modifying files

## Verification Checklist
Before marking any task as complete:
- [ ] Code follows project conventions
- [ ] Tidyverse best practices implemented where appropriate
- [ ] Changes have been tested appropriately
- [ ] No new linting/type errors introduced
- [ ] Existing functionality still works
- [ ] Explanations are clear and concise