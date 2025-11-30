---
allowed-tools: Read, Write, Edit, Bash
argument-hint: [file-path] | [package-name]
description: Generate comprehensive Go test suite with table-driven tests, mocks, and benchmarks
---

# Generate Go Tests

Generate comprehensive test suite for: $ARGUMENTS

## Current Testing Setup

- Go version: !`go version`
- Existing tests: !`find . -name "*_test.go" | head -10`
- Test coverage: !`go test -cover ./... 2>&1 | grep coverage || echo "Run 'go test -cover ./...' to see coverage"`
- Target file/package: @$ARGUMENTS (if file path or package provided)

## Task

I'll analyze the target Go code and create comprehensive test coverage including:

1. **Table-driven tests** for all functions and methods
2. **Subtests** using `t.Run()` for organized test cases
3. **Mock implementations** using interfaces and mockery
4. **Integration tests** with testcontainers (if needed)
5. **Benchmark tests** for performance-critical code
6. **Test helpers** and fixtures for common setup
7. **Edge cases** and error handling tests

## Process

I'll follow these steps:

1. Analyze the target file/package structure
2. Identify all testable functions, methods, and behaviors
3. Examine existing test patterns in the project
4. Create `*_test.go` files following Go conventions
5. Implement table-driven tests with comprehensive test cases
6. Add mocks for external dependencies using interfaces
7. Verify test coverage with `go test -cover`

## Test Types

### Unit Tests

Table-driven tests for:
- Individual functions with various inputs
- Struct methods with different receivers
- Error handling and edge cases
- Validation logic

```go
func TestUserService_CreateUser(t *testing.T) {
    t.Parallel()

    tests := []struct {
        name    string
        input   CreateUserRequest
        want    *User
        wantErr error
    }{
        {
            name: "valid user",
            input: CreateUserRequest{
                Email: "test@example.com",
                Name:  "Test User",
            },
            want: &User{
                Email: "test@example.com",
                Name:  "Test User",
            },
            wantErr: nil,
        },
        {
            name: "invalid email",
            input: CreateUserRequest{
                Email: "invalid",
                Name:  "Test",
            },
            want:    nil,
            wantErr: ErrInvalidEmail,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()

            svc := NewUserService(/* deps */)
            got, err := svc.CreateUser(context.Background(), tt.input)

            if !errors.Is(err, tt.wantErr) {
                t.Errorf("CreateUser() error = %v, wantErr %v", err, tt.wantErr)
                return
            }

            if tt.want != nil && got != nil {
                assert.Equal(t, tt.want.Email, got.Email)
                assert.Equal(t, tt.want.Name, got.Name)
            }
        })
    }
}
```

### Integration Tests

Using testcontainers for real dependencies:

```go
func TestUserRepository_Integration(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test")
    }

    ctx := context.Background()

    // Start PostgreSQL container
    pgContainer, err := postgres.RunContainer(ctx,
        testcontainers.WithImage("postgres:15-alpine"),
        postgres.WithDatabase("testdb"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
    )
    require.NoError(t, err)
    defer pgContainer.Terminate(ctx)

    connString, err := pgContainer.ConnectionString(ctx)
    require.NoError(t, err)

    // Run tests against real database
    db, err := sql.Open("postgres", connString)
    require.NoError(t, err)
    defer db.Close()

    // Run migrations
    require.NoError(t, runMigrations(db))

    // Test repository
    repo := NewUserRepository(db)

    t.Run("Create and Get User", func(t *testing.T) {
        user := &User{Email: "test@example.com", Name: "Test"}
        err := repo.Create(ctx, user)
        require.NoError(t, err)

        got, err := repo.GetByID(ctx, user.ID)
        require.NoError(t, err)
        assert.Equal(t, user.Email, got.Email)
    })
}
```

### Mocking with Interfaces

```go
// Define interface for mocking
type UserRepository interface {
    GetByID(ctx context.Context, id string) (*User, error)
    Create(ctx context.Context, user *User) error
}

// Use mockery to generate mocks
// Run: mockery --name=UserRepository --output=mocks --outpkg=mocks

func TestUserService_GetUser(t *testing.T) {
    t.Parallel()

    tests := []struct {
        name    string
        userID  string
        mockFn  func(m *mocks.UserRepository)
        want    *User
        wantErr error
    }{
        {
            name:   "user found",
            userID: "123",
            mockFn: func(m *mocks.UserRepository) {
                m.On("GetByID", mock.Anything, "123").
                    Return(&User{ID: "123", Email: "test@example.com"}, nil)
            },
            want:    &User{ID: "123", Email: "test@example.com"},
            wantErr: nil,
        },
        {
            name:   "user not found",
            userID: "999",
            mockFn: func(m *mocks.UserRepository) {
                m.On("GetByID", mock.Anything, "999").
                    Return(nil, ErrNotFound)
            },
            want:    nil,
            wantErr: ErrNotFound,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()

            mockRepo := new(mocks.UserRepository)
            tt.mockFn(mockRepo)

            svc := NewUserService(mockRepo)
            got, err := svc.GetUser(context.Background(), tt.userID)

            if !errors.Is(err, tt.wantErr) {
                t.Errorf("GetUser() error = %v, wantErr %v", err, tt.wantErr)
            }

            if tt.want != nil {
                assert.Equal(t, tt.want, got)
            }

            mockRepo.AssertExpectations(t)
        })
    }
}
```

### Benchmark Tests

```go
func BenchmarkUserService_CreateUser(b *testing.B) {
    svc := NewUserService(/* deps */)
    req := CreateUserRequest{
        Email: "bench@example.com",
        Name:  "Benchmark User",
    }

    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        _, _ = svc.CreateUser(context.Background(), req)
    }
}

// Parallel benchmark
func BenchmarkUserService_GetUser_Parallel(b *testing.B) {
    svc := NewUserService(/* deps */)

    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            _, _ = svc.GetUser(context.Background(), "123")
        }
    })
}
```

### Test Helpers

```go
// test_helpers.go or *_test.go

// Test fixtures
func newTestUser(t *testing.T) *User {
    t.Helper()
    return &User{
        ID:    uuid.New().String(),
        Email: "test@example.com",
        Name:  "Test User",
    }
}

// Setup and teardown
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper()
    // Setup code
    t.Cleanup(func() {
        // Cleanup code
    })
    return db
}

// Custom assertions
func assertUserEqual(t *testing.T, want, got *User) {
    t.Helper()
    assert.Equal(t, want.Email, got.Email)
    assert.Equal(t, want.Name, got.Name)
}
```

## Testing Best Practices

### Test Structure
- Use table-driven tests with `t.Run()` for subtests
- Call `t.Parallel()` at the start of each test and subtest to enable parallel execution
- Follow AAA pattern: Arrange, Act, Assert
- Name tests descriptively: `TestFunction_Scenario_ExpectedResult`
- Use `t.Helper()` in test helper functions

### Mocking Strategy
- Mock external dependencies (databases, APIs, services)
- Use interfaces for dependency injection
- Generate mocks with mockery: `mockery --all`
- Avoid over-mocking internal functions

### Coverage Goals
- Run: `go test -cover ./...`
- Detailed: `go test -coverprofile=coverage.out ./...`
- HTML report: `go tool cover -html=coverage.out`
- Aim for 80%+ coverage on critical paths
- Focus on business logic, not boilerplate

### Test Organization
```
package/
├── user.go
├── user_test.go          # Unit tests
├── user_integration_test.go  # Integration tests (build tag)
├── user_benchmark_test.go    # Benchmarks
└── mocks/
    └── user_repository.go    # Generated mocks
```

## Running Tests

```bash
# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Detailed coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run specific package
go test ./internal/service/...

# Run specific test
go test -run TestUserService_CreateUser ./...

# Skip integration tests
go test -short ./...

# Run with race detector
go test -race ./...

# Run benchmarks
go test -bench=. ./...
go test -bench=. -benchmem ./...

# Parallel execution
go test -parallel 4 ./...

# Verbose output
go test -v ./...
```

## Tools & Libraries

- **testing**: Standard library testing framework
- **testify**: Assertions and mocking (`github.com/stretchr/testify`)
- **mockery**: Mock generation (`github.com/vektra/mockery`)
- **testcontainers**: Real dependencies in tests (`github.com/testcontainers/testcontainers-go`)
- **go-cmp**: Deep comparison (`github.com/google/go-cmp/cmp`)
- **httptest**: HTTP testing (`net/http/httptest`)

I'll adapt to your project's testing framework and follow established patterns from existing tests.
