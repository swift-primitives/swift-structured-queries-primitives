public struct Values<QueryValue>: PartialSelectStatement {

    public typealias From = Never

    let values: [any QueryExpression]

    public init(_ value: QueryValue) where QueryValue: QueryExpression {
        self.values = [value]
    }

    public init<each Value: QueryExpression>(
        _ values: repeat each Value
    ) where QueryValue == (repeat (each Value).QueryValue) {
        self.values = Array(repeat each values)
    }

    public var query: QueryFragment {
        $_isSelecting.withValue(true) {
            "SELECT \(values.map(\.queryFragment).joined(separator: ", "))"
        }
    }
}
