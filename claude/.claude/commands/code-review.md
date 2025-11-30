---
allowed-tools: Read, Bash, Grep, Glob
argument-hint: [file-path] | [commit-hash] | --full
description: Comprehensive Go code quality review with security, performance, and production readiness analysis
---

# Go Code Quality Review

Perform comprehensive code quality review for Go project: $ARGUMENTS

## Current State

- Git status: !`git status --porcelain`
- Recent changes: !`git diff --stat HEAD~5`
- Repository info: !`git log --oneline -5`
- Go version: !`go version`
- Module info: !`cat go.mod 2>/dev/null | head -5 || echo "No go.mod found"`

## Task

Follow these steps to conduct a thorough Go code review:

1. **Repository Analysis**
   - Examine go.mod and go.sum for dependency management
   - Check project structure (cmd/, internal/, pkg/, api/)
   - Review README and documentation for Go-specific setup
   - Identify main packages and entry points

2. **Code Quality Assessment (Go-Specific)**
   - Run `go fmt ./...` to check formatting
   - Run `go vet ./...` for common Go issues
   - Run `golangci-lint run` for comprehensive linting (if available)
   - Check for idiomatic Go patterns (Effective Go guidelines)
   - Identify unused imports, variables, or dead code
   - Review error handling patterns (wrapping, sentinel errors)
   - Check context propagation in functions
   - Verify proper goroutine and channel usage

3. **Security Review (Go-Specific)**
   - Run `gosec ./...` for security vulnerabilities (if available)
   - Run `govulncheck ./...` for known vulnerabilities
   - Look for SQL injection in database queries (raw SQL vs parameterized)
   - Check for hardcoded secrets, API keys, passwords
   - Review authentication and authorization logic
   - Examine input validation and sanitization
   - Check for proper use of crypto packages
   - Review TLS configuration and certificate handling

4. **Performance Analysis (Go-Specific)**
   - Identify potential goroutine leaks
   - Check for race conditions: `go test -race ./...`
   - Review memory allocation patterns (consider profiling)
   - Check for inefficient algorithms or N+1 queries
   - Analyze connection pooling (database, HTTP clients)
   - Look for blocking operations without timeouts
   - Review use of sync.Pool for reusable objects

5. **Production Readiness**
   - Check for structured logging (slog, zap, zerolog)
   - Verify observability: metrics, tracing, health checks
   - Review graceful shutdown implementation
   - Check configuration management (env vars, config files)
   - Verify proper error handling and recovery
   - Review timeout and context usage
   - Check for proper resource cleanup (defer statements)

6. **Testing Coverage**
   - Run `go test -cover ./...` for coverage report
   - Check test organization and naming
   - Identify missing test cases for critical paths
   - Review table-driven tests and subtests
   - Check for integration tests with real dependencies
   - Assess benchmark tests for performance-critical code

7. **Architecture & Design (Go-Specific)**
   - Evaluate package organization and dependencies
   - Check for proper use of interfaces (consumer-side)
   - Review dependency injection patterns
   - Assess service layering (handler → service → repository)
   - Check for circular dependencies
   - Evaluate use of standard library vs external dependencies

8. **Concurrency Review**
   - Check for proper goroutine lifecycle management
   - Verify channel usage (buffered vs unbuffered, closing)
   - Review synchronization primitives (mutexes, RWMutex, atomic)
   - Look for potential deadlocks or race conditions
   - Check for proper use of select statements
   - Verify context cancellation handling

9. **Recommendations**
   - Prioritize issues by severity (critical, high, medium, low)
   - Provide specific, actionable recommendations with code examples
   - Suggest Go-specific tools and practices for improvement
   - Create a summary report with next steps

## Go Tooling Commands

Run these during the review:

```bash
# Format check
go fmt ./...

# Vet for common issues
go vet ./...

# Comprehensive linting (if golangci-lint is installed)
golangci-lint run --timeout 5m

# Security scanning (if gosec is installed)
gosec -quiet ./...

# Vulnerability checking
govulncheck ./...

# Race detection
go test -race ./...

# Test coverage
go test -cover ./...
go test -coverprofile=coverage.out ./...

# Dependency analysis
go list -m -u all  # Check for updates
go mod tidy        # Clean up dependencies
go mod verify      # Verify dependencies

# Build check
go build ./...
```

## Review Checklist

### Code Quality
- [ ] Code is properly formatted (`go fmt`)
- [ ] No vet warnings (`go vet`)
- [ ] Passes golangci-lint checks
- [ ] Follows Effective Go guidelines
- [ ] Functions and variables are well-named (exported/unexported conventions)
- [ ] No duplicated code
- [ ] Clear package boundaries

### Error Handling
- [ ] All errors are checked (no `_, _ = ...`)
- [ ] Errors are wrapped with context (`fmt.Errorf("%w", err)`)
- [ ] Sentinel errors are defined for business logic
- [ ] No panics in library code
- [ ] Errors are logged with proper context

### Concurrency
- [ ] Goroutines have exit conditions
- [ ] Channels are properly closed
- [ ] No race conditions (`go test -race`)
- [ ] Proper synchronization (mutexes, channels, atomic)
- [ ] Context used for cancellation

### Production Readiness
- [ ] Structured logging with correlation IDs
- [ ] Health and readiness endpoints
- [ ] Graceful shutdown implemented
- [ ] Prometheus metrics exposed
- [ ] Distributed tracing configured
- [ ] Configuration from environment variables
- [ ] No secrets in code or logs

### Security
- [ ] No hardcoded secrets or API keys
- [ ] SQL queries are parameterized
- [ ] Input validation implemented
- [ ] Authentication/authorization in place
- [ ] HTTPS enforced
- [ ] No known vulnerabilities (`govulncheck`)
- [ ] Dependencies are up to date and secure

### Performance
- [ ] No goroutine leaks
- [ ] Connection pooling configured
- [ ] Timeouts on all I/O operations
- [ ] Efficient data structures used
- [ ] Database queries are optimized
- [ ] Benchmarks for critical paths

### Testing
- [ ] Test coverage >80% for critical paths
- [ ] Table-driven tests with subtests
- [ ] Integration tests with testcontainers
- [ ] Mocks for external dependencies
- [ ] Benchmark tests for performance
- [ ] Tests pass with race detector

### Architecture
- [ ] Clear package structure
- [ ] Minimal dependencies
- [ ] Interfaces defined at point of use
- [ ] Dependency injection used
- [ ] Layered architecture (handler/service/repo)
- [ ] No circular dependencies

## Example Issues

### 🔴 Critical: Goroutine Leak
```go
// Bad: Goroutine never exits
go func() {
    for {
        doWork()
        time.Sleep(1 * time.Second)
    }
}()

// Good: Cancellable goroutine
go func() {
    ticker := time.NewTicker(1 * time.Second)
    defer ticker.Stop()
    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            doWork()
        }
    }
}()
```

### 🔴 Critical: SQL Injection
```go
// Bad: SQL injection risk
query := fmt.Sprintf("SELECT * FROM users WHERE name = '%s'", name)
db.Query(query)

// Good: Parameterized query
db.Query("SELECT * FROM users WHERE name = $1", name)
```

### 🟡 Warning: Missing Error Context
```go
// Bad: Lost error context
if err != nil {
    return err
}

// Good: Wrapped with context
if err != nil {
    return fmt.Errorf("failed to get user %s: %w", userID, err)
}
```

### 🟡 Warning: No Context Timeout
```go
// Bad: No timeout
func GetUser(id string) (*User, error) {
    return db.Query("SELECT * FROM users WHERE id = $1", id)
}

// Good: Context with timeout
func GetUser(ctx context.Context, id string) (*User, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()
    return db.QueryContext(ctx, "SELECT * FROM users WHERE id = $1", id)
}
```

### 🟢 Suggestion: Use Interfaces
```go
// Before: Tight coupling
type UserService struct {
    repo *UserRepository
}

// After: Loose coupling with interface
type UserRepository interface {
    GetByID(ctx context.Context, id string) (*User, error)
}

type UserService struct {
    repo UserRepository
}
```

Remember to be constructive, provide specific examples with file paths and line numbers, and focus on production readiness, security, and Go idioms.
