public struct SQLQueryExpression<QueryValue>: Sendable, Statement {

    public typealias From = Never

    public let queryFragment: QueryFragment

    public var query: QueryFragment { queryFragment }

    public init(
        _ queryFragment: QueryFragment,
        as queryValueType: QueryValue.Type = QueryValue.self
    ) {
        self.queryFragment = queryFragment
    }

    public init(_ queryFragment: QueryFragment) where QueryValue == () {
        self.queryFragment = queryFragment
    }

    @_disfavoredOverload
    public init(_ expression: some QueryExpression<QueryValue>) {
        self.queryFragment = expression.queryFragment
    }

    public init(_ statement: some Statement<QueryValue>) {
        self.queryFragment = statement.query
    }
}
