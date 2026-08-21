public protocol QueryExpression<QueryValue> {

    associatedtype QueryValue

    var queryFragment: QueryFragment { get }

    static var _columnWidth: Int { get }

    var _allColumns: [any QueryExpression] { get }
}

extension QueryExpression {

    public static var _columnWidth: Int {
        1
    }

    public var _allColumns: [any QueryExpression] {
        [self]
    }
}
