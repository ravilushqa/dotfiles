---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git log:*), Bash(go:*)
argument-hint: [message] | --no-verify | --amend
description: Create well-formatted commits with Go pre-commit checks and conventional commit format
---

# Smart Git Commit for Go Projects

Create well-formatted commit: $ARGUMENTS

## Current Repository State

- Git status: !`git status --porcelain`
- Current branch: !`git branch --show-current`
- Staged changes: !`git diff --cached --stat`
- Unstaged changes: !`git diff --stat`
- Recent commits: !`git log --oneline -5`
- Go version: !`go version 2>/dev/null || echo "Go not found"`

## What This Command Does

1. Unless specified with `--no-verify`, automatically runs Go pre-commit checks:
   - `go fmt ./...` to format code
   - `go vet ./...` to check for common issues
   - `go test ./...` to ensure tests pass
   - `golangci-lint run` for comprehensive linting (if available)
   - `go build ./...` to verify the build succeeds
2. Checks which files are staged with `git status`
3. If 0 files are staged, automatically adds all modified and new files with `git add`
4. Performs a `git diff` to understand what changes are being committed
5. Analyzes the diff to determine if multiple distinct logical changes are present
6. If multiple distinct changes are detected, suggests breaking the commit into multiple smaller commits
7. For each commit (or the single commit if not split), creates a commit message using emoji conventional commit format

## Best Practices for Commits

- **Verify before committing**: Ensure Go code is formatted, linted, tested, and builds correctly
- **Atomic commits**: Each commit should contain related changes that serve a single purpose
- **Split large changes**: If changes touch multiple concerns, split them into separate commits
- **Conventional commit format**: Use the format `<type>: <description>` where type is one of:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `docs`: Documentation changes
  - `style`: Code style changes (formatting, etc)
  - `refactor`: Code changes that neither fix bugs nor add features
  - `perf`: Performance improvements
  - `test`: Adding or fixing tests
  - `chore`: Changes to the build process, tools, etc.
- **Present tense, imperative mood**: Write commit messages as commands (e.g., "add feature" not "added feature")
- **Concise first line**: Keep the first line under 72 characters
- **Emoji**: Each commit type is paired with an appropriate emoji:
  - ✨ `feat`: New feature
  - 🐛 `fix`: Bug fix
  - 📝 `docs`: Documentation
  - 💄 `style`: Formatting/style
  - ♻️ `refactor`: Code refactoring
  - ⚡️ `perf`: Performance improvements
  - ✅ `test`: Tests
  - 🔧 `chore`: Tooling, configuration
  - 🚀 `ci`: CI/CD improvements
  - 🗑️ `revert`: Reverting changes
  - 🧪 `test`: Add a failing test
  - 🚨 `fix`: Fix compiler/linter warnings
  - 🔒️ `fix`: Fix security issues
  - 👥 `chore`: Add or update contributors
  - 🚚 `refactor`: Move or rename resources
  - 🏗️ `refactor`: Make architectural changes
  - 🔀 `chore`: Merge branches
  - 📦️ `chore`: Add or update compiled files or packages
  - ➕ `chore`: Add a dependency
  - ➖ `chore`: Remove a dependency
  - 🌱 `chore`: Add or update seed files
  - 🧑‍💻 `chore`: Improve developer experience
  - 🧵 `feat`: Add or update code related to multithreading or concurrency
  - 🔍️ `feat`: Improve SEO
  - 🏷️ `feat`: Add or update types
  - 💬 `feat`: Add or update text and literals
  - 🌐 `feat`: Internationalization and localization
  - 👔 `feat`: Add or update business logic
  - 📱 `feat`: Work on responsive design
  - 🚸 `feat`: Improve user experience / usability
  - 🩹 `fix`: Simple fix for a non-critical issue
  - 🥅 `fix`: Catch errors
  - 👽️ `fix`: Update code due to external API changes
  - 🔥 `fix`: Remove code or files
  - 🎨 `style`: Improve structure/format of the code
  - 🚑️ `fix`: Critical hotfix
  - 🎉 `chore`: Begin a project
  - 🔖 `chore`: Release/Version tags
  - 🚧 `wip`: Work in progress
  - 💚 `fix`: Fix CI build
  - 📌 `chore`: Pin dependencies to specific versions
  - 👷 `ci`: Add or update CI build system
  - 📈 `feat`: Add or update analytics or tracking code
  - ✏️ `fix`: Fix typos
  - ⏪️ `revert`: Revert changes
  - 📄 `chore`: Add or update license
  - 💥 `feat`: Introduce breaking changes
  - 🍱 `assets`: Add or update assets
  - ♿️ `feat`: Improve accessibility
  - 💡 `docs`: Add or update comments in source code
  - 🗃️ `db`: Perform database related changes
  - 🔊 `feat`: Add or update logs
  - 🔇 `fix`: Remove logs
  - 🤡 `test`: Mock things
  - 🥚 `feat`: Add or update an easter egg
  - 🙈 `chore`: Add or update .gitignore file
  - 📸 `test`: Add or update snapshots
  - ⚗️ `experiment`: Perform experiments
  - 🚩 `feat`: Add, update, or remove feature flags
  - 💫 `ui`: Add or update animations and transitions
  - ⚰️ `refactor`: Remove dead code
  - 🦺 `feat`: Add or update code related to validation
  - ✈️ `feat`: Improve offline support

## Guidelines for Splitting Commits

When analyzing the diff, consider splitting commits based on these criteria:

1. **Different concerns**: Changes to unrelated parts of the codebase
2. **Different types of changes**: Mixing features, fixes, refactoring, etc.
3. **File patterns**: Changes to different types of files (e.g., source code vs documentation)
4. **Logical grouping**: Changes that would be easier to understand or review separately
5. **Size**: Very large changes that would be clearer if broken down

## Go-Specific Commit Examples

Good commit messages for Go projects:
- ✨ feat: add user authentication service with JWT
- 🐛 fix: resolve goroutine leak in worker pool
- 📝 docs: update API documentation with gRPC examples
- ♻️ refactor: simplify error handling in repository layer
- 🚨 fix: resolve golangci-lint warnings in handlers
- 🧑‍💻 chore: improve developer tooling with Makefile
- 👔 feat: implement business logic for order validation
- 🩹 fix: address minor formatting issue in logger
- 🚑️ fix: patch critical race condition in cache
- 🎨 style: reorganize package structure for better readability
- 🔥 fix: remove deprecated legacy API endpoints
- 🦺 feat: add input validation for user registration
- 💚 fix: resolve failing CI pipeline tests
- 📈 feat: implement Prometheus metrics for HTTP handlers
- 🔒️ fix: strengthen password hashing with bcrypt
- ♿️ feat: improve API error responses for better DX
- 🧵 feat: add worker pool for concurrent task processing
- 🏷️ feat: add type definitions for API request/response models

Example of splitting commits:
- First commit: ✨ feat: add PostgreSQL connection pooling
- Second commit: 📝 docs: update database setup instructions
- Third commit: 🔧 chore: update go.mod dependencies
- Fourth commit: 🏷️ feat: add type-safe SQL queries with sqlc
- Fifth commit: 🚨 fix: resolve linting issues in repository package
- Sixth commit: ✅ test: add integration tests for database operations
- Seventh commit: 🔒️ fix: update pgx driver to patch security vulnerability

## Pre-Commit Checks for Go

By default, these checks will run before committing (unless `--no-verify` is specified):

```bash
# 1. Format code (auto-fixes)
go fmt ./...

# 2. Vet for common issues
go vet ./...

# 3. Run tests
go test ./...

# 4. Run linter (if golangci-lint is available)
golangci-lint run --timeout 5m 2>/dev/null || echo "golangci-lint not installed, skipping"

# 5. Build check
go build ./...

# Optional: Run these if available
# go test -race ./...          # Race detection (slower)
# govulncheck ./...            # Vulnerability scanning
# gosec ./...                  # Security scanning
```

## Terraform Pre-Commit Checks (if .tf files detected)

If the repository contains Terraform files, also run:

```bash
# Format Terraform files
terraform fmt -recursive

# Validate Terraform configuration
terraform validate 2>/dev/null || echo "terraform validate skipped (not initialized)"

# Terraform linting (if tflint is available)
tflint 2>/dev/null || echo "tflint not installed, skipping"
```

## Command Options

- `--no-verify`: Skip running the pre-commit checks (go fmt, go vet, go test, go build)
- `--amend`: Amend the previous commit instead of creating a new one

## Important Notes

- By default, pre-commit checks (`go fmt`, `go vet`, `go test`, `go build`) will run to ensure code quality
- If these checks fail, you'll be asked if you want to proceed with the commit anyway or fix the issues first
- If specific files are already staged, the command will only commit those files
- If no files are staged, it will automatically stage all modified and new files
- The commit message will be constructed based on the changes detected
- Before committing, the command will review the diff to identify if multiple commits would be more appropriate
- If suggesting multiple commits, it will help you stage and commit the changes separately
- Always reviews the commit diff to ensure the message matches the changes

## Example Workflow

```bash
# Make changes to Go code
vim internal/service/user.go

# Run commit command (pre-commit checks will run)
/commit

# If checks pass:
# - Changes are analyzed
# - Commit message is generated
# - Commit is created

# If checks fail:
# - Fix issues
# - Run /commit again

# Skip pre-commit checks (not recommended)
/commit --no-verify

# Amend previous commit
/commit --amend
```

## Integration with Git Hooks

If you have Git hooks configured (`.git/hooks/pre-commit`), they will run in addition to these checks. Make sure your hooks don't conflict with these pre-commit validations.

## Makefile Integration

Many Go projects use Makefiles for common tasks. If your project has a `Makefile` with these targets, they can be used instead:

```makefile
.PHONY: fmt vet test build lint

fmt:
	go fmt ./...

vet:
	go vet ./...

test:
	go test -v ./...

build:
	go build -o bin/app ./cmd/app

lint:
	golangci-lint run --timeout 5m

pre-commit: fmt vet lint test build
```

Then run: `make pre-commit` before committing.
