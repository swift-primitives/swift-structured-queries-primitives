/// A `SELECT` statement that selects a set of values.
///
/// Equivalent to a `VALUES` statement in SQL.
///
/// ```swift
/// Values(true, 2.3, "Hello")
/// // SELECT 1, 2.3, 'Hello'
/// // => (Bool, Double, String)
/// ```
///
/// While not particularly useful on its own it can act as a helpful starting point for recursive
/// common table expressions and other subqueries. See <doc:CommonTableExpressions> for more.
public struct Values<QueryValue>: PartialSelectStatement {
    /// The From clause type, unused since this statement selects no table.
    public typealias From = Never

    let values: [any QueryExpression]

    /// Creates a values statement selecting a single query expression.
    public init(_ value: QueryValue) where QueryValue: QueryExpression {
        self.values = [value]
    }

    /// Creates a values statement selecting a tuple of query expressions.
    public init<each Value: QueryExpression>(
        _ values: repeat each Value
    ) where QueryValue == (repeat (each Value).QueryValue) {
        self.values = Array(repeat each values)
    }

    /// The SQL fragment for this statement's SELECT clause listing its values.
    public var query: QueryFragment {
        $_isSelecting.withValue(true) {
            "SELECT \(values.map(\.queryFragment).joined(separator: ", "))"
        }
    }
}
