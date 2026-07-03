# Structured Queries Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-primitives/swift-structured-queries-primitives/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-primitives/swift-structured-queries-primitives/actions/workflows/ci.yml)

> Forked from [`pointfreeco/swift-structured-queries`](https://github.com/pointfreeco/swift-structured-queries), by way of [`coenttb/swift-structured-queries-postgres`](https://github.com/coenttb/swift-structured-queries-postgres).

Type-safe, composable SQL query building whose Swift API reads like the SQL it generates — `SELECT`, `INSERT`, `UPDATE`, `DELETE`, joins, common table expressions, and safe raw-SQL escapes, without an ORM's query language to learn.

---

## Key Features

- **Bindings separated from SQL text** — `QueryFragment` tracks raw SQL segments and bound values independently, so interpolating a Swift value never risks SQL injection the way naive string concatenation does.
- **Type-safe statement building** — `Table`, `Select`, `Insert`, `Update`, `Delete`, and `CTE` compose into full statements whose column references are checked against the table's declared `TableColumns` at compile time.
- **Typed query bindings and decoding** — `QueryBinding` models every bindable SQL value (text, int, bool, double, date, UUID, decimal, arrays, `jsonb`, …) with a matching `QueryDecoder` side for round-tripping results back into Swift types via `QueryRepresentable`.
- **`Tagged` integration** — phantom-typed wrappers from [`swift-tagged-primitives`](https://github.com/swift-primitives/swift-tagged-primitives) conform to `QueryBindable`, `QueryDecodable`, `QueryExpression`, and `QueryRepresentable` directly, so a `Tagged<UserID.Tag, Int>` primary key binds and decodes exactly like its `Underlying` type.
- **Views and window functions** — `Views`, `WindowSpec`, and `FrameClause` cover SQL surfaces beyond basic CRUD.

---

## Quick Start

`QueryFragment` is this package's building block: it separates literal SQL text from bound values so that interpolating a Swift value can never smuggle SQL into the query string.

```swift
import Structured_Queries_Primitives

// Naive string interpolation risks SQL injection — the value becomes part of the SQL text:
let userInput = "O'Brien"
let unsafe = "SELECT * FROM users WHERE name = '\(userInput)'"
// "SELECT * FROM users WHERE name = 'O'Brien'"  -- broken syntax, or worse, injectable

// QueryFragment keeps the value out of the SQL text as a separate binding:
let name = "O'Brien"
let fragment: QueryFragment = "SELECT * FROM \(quote: "users") WHERE name = \(name.queryBinding)"
let (sql, bindings) = fragment.prepare { offset in "$\(offset)" }
// sql:      SELECT * FROM "users" WHERE name = $1
// bindings: ['O''Brien']   -- QueryBinding.text("O'Brien"), rendered via its debugDescription
```

`\(quote:)` safely quotes identifiers (table and column names); interpolating a `QueryBinding` produces a `.binding` segment rather than splicing the value into the SQL text.

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-structured-queries-primitives.git", branch: "main")
]
```

Add a product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Structured Queries Primitives", package: "swift-structured-queries-primitives")
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

> Important: This package builds type-safe SQL statements; it does not include a database driver or the `@Table` / `@Selection` / `#sql` code-generation macros. It is the runtime core that macro-generated `Table` conformances (or hand-written ones, per `TableDefinition`) target.

---

## Architecture

| Product | Contents | When to import |
|---------|----------|----------------|
| `Structured Queries Primitives` | `QueryFragment`, `Table`, `Select`/`Insert`/`Update`/`Delete` statements, `QueryBinding`/`QueryDecoder`, CTEs, views, window functions | Building or executing SQL statements |
| `Structured Queries Primitives Support` | SQL identifier quoting and inflection helpers used internally by `QueryFragment` | Rarely imported directly; pulled in transitively |
| `Structured Queries Primitives Test Support` | Test-only fixtures for exercising `Table` conformances | Test targets only |

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |
| Swift Embedded   | —   | Pending (nightly-toolchain follow-up) |

---

## Related Packages

- [`swift-tagged-primitives`](https://github.com/swift-primitives/swift-tagged-primitives) — the phantom-typed `Tagged<Tag, Underlying>` wrapper this package conforms to `QueryBindable`, `QueryDecodable`, `QueryExpression`, and `QueryRepresentable`.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

## License

Apache 2.0 (Institute) with MIT attribution to the upstream `pointfreeco/swift-structured-queries` (Copyright (c) 2025 Point-Free, Inc.). The combined-license text — Institute Apache 2.0 + the upstream's preserved MIT block — is in [LICENSE.md](LICENSE.md). MIT requires preservation of the original copyright notice in derivative works; the Institute's Apache 2.0 governs new contributions on top of the fork point.
