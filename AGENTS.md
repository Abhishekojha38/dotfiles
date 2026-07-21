# Abhishek's agent instructions

These are common instructions for Abhishek's agents across all scenarios.

# General Guidelines

- Never use the em dash "—".
- When writing commit messages, NEVER auto add your agent name as co-author.
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.
- When writing or editing markdown files or adoc, put each full sentence onto one physical line and also keep 80 char limit per line. Avoid wrapping multiple sentences into one line. 
- When making technical decisions, do not give much weight to development cost.
- When doing a bug fixes, always start with reproducing the bug in an End to End setting as closely aligned with how an end user would experiance it as possible. This make sure you find the real problem so your fix will actually solve it.
- Prefer quality, simplicity, robustness, scalability, and long term maintainability, when makeing technical decisions and implementations.

# When stuck
- ask a clarifying question, propose a short plan, or open a draft PR with notes.
- do not push large speculative changes without confirmation.

# Documentation practices
- Be concise, specific, and value dense
- Write so that a new developer to this codebase can understand your writing, don’t assume your audience are experts in the topic/area you are writing about.

# Git Workflow & Commit Guidelines

When preparing or executing git commits, you MUST follow these constraints:

## Rules & Safety
- **Explicit Permission Only:** NEVER execute `git commit` automatically. Always generate the message, present it to the user, and ask for confirmation first.
- **Selective Staging:** Never use broad commands like `git add .` or `git add -A`. Inspect changes and stage files explicitly.
- **Secrets Boundary:** Scan the diff before staging. NEVER commit files containing secrets, API keys, credentials, or `.env` files.
- **Atomic Commits:** Keep commits small and focused on a single logical change. If changes are unrelated, split them into separate commits.

## Writing Style:
- **Imperative Mood:** Use the imperative, present tense in the description (e.g., "add feature" instead of "added feature" or "adds feature").
- **No Punctuation:** Do not end the subject line with a period.
- **Length Constraint:** Keep the subject line under 72 characters.
- **Format:** The output must be pure plain text. Do not use Markdown formatting (like backticks or bold text) inside the commit message string.
