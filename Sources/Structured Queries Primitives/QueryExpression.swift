/// A type that represents a full or partial SQL query.
public protocol QueryExpression<QueryValue> {
    /// The Swift data type representation of the expression's SQL data type.
    ///
    /// For example, a `TEXT` expression may be represented as a `String` query value.
    ///
    /// This type is used to introduce type-safety at the query builder level.
    associatedtype QueryValue

    /// The query fragment associated with this expression.
    var queryFragment: QueryFragment { get }

    static var _columnWidth: Int { get }

    var _allColumns: [any QueryExpression] { get }
}

extension QueryExpression {
    /// The default column width of one, used when not overridden.
    public static var _columnWidth: Int {
        1
    }

    /// The default column list, containing only this expression.
    public var _allColumns: [any QueryExpression] {
        [self]
    }
}
