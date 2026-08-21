import Structured_Queries_Primitives_Support

public struct Collation: QueryExpression, Sendable {

    public init(rawValue: String) {
        self.queryFragment = "\(quote: rawValue)"
    }

    public let queryFragment: QueryFragment
}

extension Collation {

    public typealias QueryValue = Never
}
