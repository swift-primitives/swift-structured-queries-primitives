# Audit: swift-structured-queries-primitives

## Migration Plan Deviations — 2026-03-27

### Scope

- **Target**: swift-structured-queries-primitives (Phase 1 of coenttb → Swift Institute migration)
- **Plan**: `/Users/coen/.claude/plans/gentle-soaring-eclipse.md`, Phase 1 section
- **Handoff**: `/Users/coen/Developer/HANDOFF.md`
- **Files**: 77 source files, 1 test file

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | CRITICAL | [PRIM-FOUND-001] | 12 files (see §Detail-1) | Foundation imported in 12 source files. `QueryBinding` enum structurally depends on `Date`, `UUID`, `Decimal`, `Data` as case payloads. Plan did not account for this; only mentioned `PrettyPrinting.swift`. Removing Foundation would require replacing these types with platform-independent equivalents — a full refactor beyond migration scope. | DEFERRED — accepted as known violation for this migration pass; follow-up to extract Foundation types |
| 2 | HIGH | Plan §Package.swift | QueryFragment.swift:1 | `public import Structured_Queries_Primitives_Support` required. Plan listed Support as a target dependency but did not anticipate that `MemberImportVisibility` forces every file using Support types to import it explicitly, and `InternalImportsByDefault` requires the import in QueryFragment.swift to be `public` because `QuoteDelimiter` appears in the public `appendInterpolation(quote:delimiter:)` signature. | DEFERRED — structural consequence of ecosystem settings; revisit if Support module is restructured |
| 3 | HIGH | Plan §Import replacements | 15 files (see §Detail-3) | `import Structured_Queries_Primitives_Support` added to 15 additional files. Plan's import replacement table only listed 3 imports (IssueReporting, CasePaths, Tagged). It did not account for `MemberImportVisibility` requiring every file that uses `\(quote: ...)` interpolation, `.quoted()`, `.lowerCamelCased()`, or `.pluralized()` to explicitly import the Support module. | DEFERRED — structural consequence of ecosystem settings; no action needed unless Support target is restructured |
| 4 | HIGH | Plan §Import replacements | 7 files (see §Detail-4) | `import Foundation` changed to `public import Foundation` in 7 files. Plan did not mention `InternalImportsByDefault`, which makes all imports internal by default. Files declaring public conformances on Foundation types (`extension Date: QueryBindable`, `extension UUID: QueryBindable`, etc.) require `public import Foundation` so the types are visible to consumers. | DEFERRED — structural consequence of ecosystem settings and Foundation dependency (see #1) |
| 5 | HIGH | Plan §Tagged API difference | Traits/Tagged.swift:5-14 | Tagged conformances required explicit protocol witness implementations, not just conditional conformance declarations. Plan noted `Tagged(rawValue:)` → `Tagged(__unchecked:(), ...)` API change but did not account for the fact that ecosystem Tagged does NOT conform to `RawRepresentable` (Point-Free's did). Original code relied on `QueryBindable where Self: RawRepresentable` and `QueryDecodable where Self: RawRepresentable` default implementations. Explicit `queryBinding` and `init(decoder:)` implementations were added. | DEFERRED — correct for ecosystem Tagged; revisit only if ecosystem Tagged gains RawRepresentable conformance |
| 6 | HIGH | Plan §Tagged API difference | Traits/Tagged.swift:1 | `public import Tagged_Primitives` required (not just `import`). Same `InternalImportsByDefault` issue as #4: Tagged appears in public API (`QueryOutput` typealias, public inits), so the import must be public. Plan said `import Tagged_Primitives`. | DEFERRED — structural consequence of ecosystem settings |
| 7 | HIGH | Plan §Tagged API difference | Traits/Tagged.swift:3,5,11,17,23 | All Tagged extension constraints include `Tag: ~Copyable`. Point-Free Tagged had implicit `Tag: Copyable`; ecosystem Tagged has `Tag: ~Copyable`. Original conformances like `extension Tagged: QueryBindable where RawValue: QueryBindable {}` became `extension Tagged: QueryBindable where Tag: ~Copyable, RawValue: QueryBindable {}`. This is required for the extension to apply to all `Tagged` instances since `Tag` is `~Copyable` by default. | DEFERRED — correct for ecosystem Tagged; no action needed |
| 8 | MEDIUM | Plan §Import replacements | Insert.swift:190 | `reportIssue(...)` replaced with `assertionFailure(...)`. Plan mentioned removing `import IssueReporting` from `PrettyPrinting.swift` but did not mention Insert.swift, which also imported IssueReporting and called `reportIssue(...)` for invalid WHERE clauses. `assertionFailure` has different semantics: crashes in debug, no-op in release (vs. `reportIssue` which logs and fails tests without crashing). | DEFERRED — acceptable for migration pass; consider ecosystem equivalent if one exists at a higher layer |
| 9 | MEDIUM | Plan §Steps, step 6 | Select+GroupBy.swift:37,52,69 | Private method `_group(by:)` renamed to `_groupSingleJoin(by:)` for the `where Joins: Table` overload. Swift 6.2 under ecosystem settings produced "ambiguous use of `_group(by:)`" because the variadic generic overload (`where Joins == (repeat each J)`) and the single-join overload (`where Joins: Table`) were equally good matches. Original code compiled under Swift 6.1 without ecosystem settings. | DEFERRED — internal rename only; no API impact; original ambiguity may be a compiler regression |
| 10 | MEDIUM | Plan §Steps, step 6 | 5 files (see §Detail-10) | Stripped unnecessary `import Foundation` from 5 files that did not use any Foundation types or APIs. Plan did not enumerate these. Files: QueryFunctionInfrastructure.swift, QueryFragment.swift, CTE.Builder.swift, CTE.With.swift, CTE.swift. | RESOLVED 2026-03-27 |
| 11 | MEDIUM | Plan §Steps, step 9 | Tests/ | No comprehensive tests copied. All existing tests in the source repo (`StructuredQueriesPostgresTests`) import `StructuredQueriesPostgres` + `InlineSnapshotTesting` — they are L2 tests. Plan step 9 said "Copy tests, adapt imports" but the tests cannot be adapted to L1 without the Postgres layer and snapshot infrastructure. Only 6 smoke tests written as a build verification. | DEFERRED — comprehensive SQL snapshot tests will be adapted in Phase 2 when L2 package is created |
| 12 | MEDIUM | [PRIM-FOUND-001] | PrettyPrinting.swift:1 | `import Foundation` retained in PrettyPrinting.swift despite removing `isTesting`. The `indented()` method uses `String.replacingOccurrences(of:with:)` which is a Foundation API (`NSString` bridging). Plan's option 3 (always-on pretty-printing) was implemented, removing `IssueReporting` and all `#if DEBUG`/`isTesting` branching, but the `replacingOccurrences` call still requires Foundation. | DEFERRED — part of broader Foundation dependency (#1); could be replaced with stdlib string operations |
| 13 | LOW | Plan §Package.swift | Package.swift:19 | Plan listed path-based dependency as `../../swift-primitives/swift-tagged-primitives`. Actual path is `../swift-tagged-primitives` (relative within the swift-primitives superrepo). Plan assumed the package would be at a different relative depth. | RESOLVED 2026-03-27 |
| 14 | LOW | Plan §Steps | Package.swift:35 | `exclude: ["Documentation.docc"]` added to target definition. Copied DocC catalogue from StructuredQueriesCore references the old module name (`StructuredQueriesCore.md`) and old types. Excluded to prevent build/doc-generation issues. Plan did not mention DocC handling. | DEFERRED — DocC should be updated to reference new module name in a follow-up pass |
| 15 | LOW | Plan §Steps | (deleted) | `Symbolic Links/` directory removed. Contained a broken symlink pointing to `../../StructuredQueriesPostgresSupport` (old relative path). Plan did not mention this directory. Package.swift in original had `exclude: ["Symbolic Links/README.md"]`. | RESOLVED 2026-03-27 |
| 16 | LOW | Plan §isTesting | PrettyPrinting.swift:3-28 | Pretty-printing is now **always on** (newlines + indentation unconditionally). Original behavior: pretty-printed only when `isTesting == true` (test environment), flat SQL otherwise. This changes runtime SQL output format in non-test contexts. Query semantics are identical; only whitespace differs. All existing tests expect pretty-printed output so test snapshots will match. | DEFERRED — behavioral change accepted per plan recommendation (option 3); production consumers must tolerate formatted SQL |
| 17 | LOW | Plan §.gitmodules | .gitmodules | `.gitmodules` entry uses tab indentation (matching existing entries). Plan showed space indentation in the template. Trivial formatting difference. | RESOLVED 2026-03-27 |

### Detail Sections

#### §Detail-1: Foundation imports (finding #1)

**`public import Foundation`** (7 files — Foundation types in public API):
- `QueryBinding.swift` — `case date(Date)`, `case uuid(UUID)`, `case decimal(Decimal)`, `case jsonb(Data)`, `case uuidArray([UUID])`, `case dateArray([Date])` in public enum
- `QueryBindable.swift` — `extension Date: QueryBindable`, `extension UUID: QueryBindable`, `extension Decimal: QueryBindable`
- `QueryBindable+Foundation.swift` — `extension Data: QueryBindable`, `extension URL: QueryBindable`
- `QueryDecodable.swift` — `extension Date: QueryDecodable`, `extension UUID: QueryDecodable`, `extension Decimal: QueryDecodable`
- `QueryDecoder.swift` — public methods with `Date`, `UUID`, `Decimal` parameter types
- `QueryRepresentable.swift` — `extension UUID: QueryRepresentable`, `extension Decimal: QueryRepresentable`
- `Internal/Date+ISO8601.swift` — `extension Date` with package/public methods, `DateFormatter`, `Calendar`, `Locale`, `TimeZone`

**`import Foundation`** (5 files — Foundation APIs used internally only):
- `TableAlias.swift` — `String.replacingOccurrences(of:with:)` in fileprivate method
- `PrettyPrinting.swift` — `String.replacingOccurrences(of:with:)` in package method
- `CTE.Clause.swift` — `String.contains(_:)`, `String.trimmingCharacters(in:)` in private methods
- `Insert.swift` — no Foundation API actually used (retained conservatively; candidate for removal)
- `Quoting.swift` (Support target) — `String.replacingOccurrences(of:with:)` in public method

#### §Detail-3: Support module explicit imports (finding #3)

Files that received `import Structured_Queries_Primitives_Support`:
1. `QueryBinding.swift` — `.quoted(.text)` in `debugDescription`
2. `TableAlias.swift` — `.lowerCamelCased()`, `.pluralized()`, `.quoted()` in `AliasName` default impl + `replacingOccurrences` helper
3. `Insert.swift` — `\(quote: ...)` interpolation
4. `Updates.swift` — `\(quote: ...)` interpolation
5. `TableExpression.swift` — `\(quote: ...)` interpolation
6. `TableColumn.swift` — `\(quote: ...)` interpolation
7. `Table.swift` — `\(quote: ...)` interpolation
8. `Views.swift` — `\(quote: ...)` interpolation
9. `Select.swift` — `\(quote: ...)` interpolation
10. `Delete.swift` — `\(quote: ...)` interpolation
11. `Delete+Returning.swift` — `\(quote: ...)` interpolation
12. `Update.swift` — `\(quote: ...)` interpolation
13. `CTE.Clause.swift` — `\(quote: ...)` interpolation (already had Foundation import)
14. `Optional.swift` — `\(quote: ...)` interpolation
15. `Collation.swift` — `\(quote: ...)` interpolation

Plus `QueryFragment.swift` with `public import` (finding #2).

#### §Detail-4: Public Foundation imports (finding #4)

See §Detail-1 "public import Foundation" section. The 7 files are:
`QueryBinding.swift`, `QueryBindable.swift`, `QueryBindable+Foundation.swift`, `QueryDecodable.swift`, `QueryDecoder.swift`, `QueryRepresentable.swift`, `Internal/Date+ISO8601.swift`.

#### §Detail-10: Stripped unnecessary Foundation imports (finding #10)

Files where `import Foundation` was removed (no Foundation types or APIs used):
1. `QueryFunctionInfrastructure.swift`
2. `QueryFragment.swift`
3. `CTE.Builder.swift`
4. `CTE.With.swift`
5. `CTE.swift`

### Summary

17 findings: 1 critical, 6 high, 5 medium, 5 low.

**Systemic pattern**: The plan was written before accounting for the ecosystem's strict Swift settings (`InternalImportsByDefault`, `MemberImportVisibility`, `strictMemorySafety`). These settings forced 3 categories of unplanned changes: (1) `public import` for types in public API, (2) explicit per-file imports for the Support module, (3) method disambiguation for variadic generics. None of these change the external API or architectural decisions.

**Critical follow-up**: The Foundation dependency (#1) is the only architecturally significant deviation. It is structural (QueryBinding enum cases) and cannot be resolved without a type refactor that replaces Foundation types with platform-independent equivalents. This should be tracked as a separate initiative, not a migration clean-up.

**Phase 2 impact**: Findings #5 (Tagged not RawRepresentable) and #8 (reportIssue → assertionFailure) may affect Phase 2 if the Postgres layer relies on the RawRepresentable conformance path or on reportIssue semantics. The `_groupSingleJoin` rename (#9) is internal and has no cross-phase impact.
