import Structured_Queries_Primitives_Support

public protocol TableExpression<QueryValue>: QueryExpression where QueryValue: Table {
    var allColumns: [any QueryExpression] { get }
}

extension TableExpression {

    public var queryFragment: QueryFragment {
        guard _isSelecting else {
            return allColumns.map(\.queryFragment).joined(separator: ", ")
        }
        return zip(allColumns, QueryValue.TableColumns.allColumns)
            .map { "\($0) AS \(quote: $1.name)" }
            .joined(separator: ", ")
    }

    public static var _columnWidth: Int {
        QueryValue._columnWidth
    }

    public var _allColumns: [any QueryExpression] {
        allColumns
    }
}

extension Table {

    public typealias Columns = Selection
}
