public struct QueryFunction<QueryValue>: QueryExpression {
    let name: QueryFragment
    let arguments: [QueryFragment]

    public init<each Argument: QueryExpression>(
        _ name: QueryFragment,
        _ arguments: repeat each Argument
    ) {
        self.name = name
        self.arguments = Array(repeat each arguments)
    }

    public var queryFragment: QueryFragment {
        "\(name)(\(arguments.joined(separator: ", ")))"
    }
}
