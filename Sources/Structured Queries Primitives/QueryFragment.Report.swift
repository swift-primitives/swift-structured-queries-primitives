extension QueryFragment {
    /// A namespace for diagnostics reported while rendering a statement's query fragment.
    public enum Report {}
}

extension QueryFragment.Report {
    /// The handler invoked when a statement is rendered from a structurally invalid
    /// construction, such as an `ON CONFLICT DO NOTHING` clause carrying an update filter.
    ///
    /// When unbound, rendering falls back to `assertionFailure`, preserving the debug-build
    /// trap for consumers that do not observe diagnostics. Test harnesses bind this task
    /// local to observe the diagnostic without trapping:
    ///
    /// ```swift
    /// QueryFragment.Report.$invalid.withValue({ Issue.record("\($0)") }) {
    ///     // render the statement under test
    /// }
    /// ```
    ///
    /// The handler is `@Sendable` as `TaskLocal` requires; it is the surface's sole
    /// `Sendable` obligation.
    @TaskLocal public static var invalid: (@Sendable (String) -> Void)?
}
