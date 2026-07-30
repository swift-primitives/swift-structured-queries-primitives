extension QueryFragment {
    /// A namespace for diagnostics reported while rendering a statement's query fragment.
    public enum Report {}
}

extension QueryFragment.Report {
    /// A nominal wrapper around the diagnostic handler.
    ///
    /// The wrapper exists solely to keep the task local's value type non-function. On Swift
    /// 6.3.3, a `@TaskLocal` whose value type is itself a function type (optional or not)
    /// crashes `swift_task_localValuePush` with a null value-witness-table dereference: the
    /// specializer requests the value type's metadata through the concrete-only instantiation
    /// entry point using a lowered, still-dependent mangled name, instantiation returns null,
    /// and the runtime dereferences `null - 8`. Wrapping the function in a nominal type (this
    /// struct, or an equivalent `final class`) gives the task local a nominal value type and
    /// avoids the crash; a `typealias` does not help, because the structural type is
    /// unchanged. See swift-institute/Issues#84 for the full diagnosis and reproducer.
    ///
    /// Retire this wrapper once the ecosystem's compiler floor reaches Swift 6.4, where the
    /// underlying defect is fixed upstream and the task local can hold the function type
    /// directly again.
    public struct Handler: Sendable {
        public let run: @Sendable (String) -> Void

        public init(_ run: @escaping @Sendable (String) -> Void) {
            self.run = run
        }
    }

    /// The handler invoked when a statement is rendered from a structurally invalid
    /// construction, such as an `ON CONFLICT DO NOTHING` clause carrying an update filter.
    ///
    /// When unbound, rendering falls back to `assertionFailure`, preserving the debug-build
    /// trap for consumers that do not observe diagnostics. Test harnesses bind this task
    /// local to observe the diagnostic without trapping:
    ///
    /// ```swift
    /// QueryFragment.Report.$invalid.withValue(.init { Issue.record("\($0)") }) {
    ///     // render the statement under test
    /// }
    /// ```
    @TaskLocal public static var invalid: Handler?
}
