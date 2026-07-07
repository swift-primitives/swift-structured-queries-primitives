import Structured_Queries_Primitives_Support

/// An expression of table columns.
///
/// Don't conform to this protocol directly. Instead, use the `@Table` and `@Selection` macros to
/// generate a conformance.
public protocol TableExpression<QueryValue>: QueryExpression where QueryValue: Table {
    var allColumns: [any QueryExpression] { get }
}

extension TableExpression {
    /// The SQL fragment listing this expression's columns, aliased when selecting.
    public var queryFragment: QueryFragment {
        if _isSelecting {
            return zip(allColumns, QueryValue.TableColumns.allColumns)
                .map { "\($0) AS \(quote: $1.name)" }
                .joined(separator: ", ")
        } else {
            return allColumns.map(\.queryFragment).joined(separator: ", ")
        }
    }

    /// The number of columns in this table's expression, forwarded from its query value type.
    public static var _columnWidth: Int {
        QueryValue._columnWidth
    }

    /// This expression's full list of columns, exposed for internal use.
    public var _allColumns: [any QueryExpression] {
        allColumns
    }
}

extension Table {
    /// A convenience alias for a table's column-selection type.
    public typealias Columns = Selection
}
