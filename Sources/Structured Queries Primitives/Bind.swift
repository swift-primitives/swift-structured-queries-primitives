/// A query expression of a statement binding.
///
/// It is not common to interact with this type directly. A value of this type is returned from the
/// `#bind` macro.
public struct BindQueryExpression<QueryValue: QueryBindable>: QueryExpression {
    /// The underlying query value being bound.
    public let base: QueryValue

    /// Creates a binding expression from the given raw query output value.
    public init(
        _ queryOutput: QueryValue.QueryOutput,
        as queryValueType: QueryValue.Type = QueryValue.self
    ) {
        self.base = QueryValue(queryOutput: queryOutput)
    }

    /// The query fragment produced by the underlying bound value.
    public var queryFragment: QueryFragment {
        base.queryFragment
    }
}
