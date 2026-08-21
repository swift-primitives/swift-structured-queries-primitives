public protocol Statement<QueryValue>: QueryExpression {

    associatedtype From: Table

    associatedtype Joins = ()

    var query: QueryFragment { get }
}

extension Statement {

    public var queryFragment: QueryFragment {
        "(\(.newline)\(query.indented())\(.newline))"
    }
}
