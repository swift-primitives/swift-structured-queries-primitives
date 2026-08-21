import Structured_Queries_Primitives_Support

@dynamicMemberLookup
public protocol Table: QueryRepresentable, PartialSelectStatement {
    associatedtype QueryValue = Self

    associatedtype From = Never

    associatedtype TableColumns: TableDefinition<Self>

    associatedtype Selection: TableExpression<Self>

    associatedtype DefaultScope: SelectStatement<(), Self, ()>

    static var columns: TableColumns { get }

    static var tableName: String { get }

    static var tableAlias: String? { get }

    static var schemaName: String? { get }

    static var tableFragment: QueryFragment { get }

    static var all: DefaultScope { get }
}

public protocol _Selection: Table {}

extension Table {

    public static var unscoped: Where<Self> {
        Where(scope: .unscoped)
    }

    @_disfavoredOverload
    public static var none: Where<Self> {
        Where(scope: .empty)
    }

    public static var tableAlias: String? {
        nil
    }

    public static var schemaName: String? {
        nil
    }

    public static var tableFragment: QueryFragment {
        QueryFragment(quote: tableName)
    }

    public var query: QueryFragment {
        func open<Root, Value>(_ column: some TableColumnExpression<Root, Value>) -> QueryFragment {

            let value = Value(queryOutput: (self as! Root)[keyPath: column.keyPath])
            return "\(value) AS \(quote: column.name)"
        }
        return "SELECT \(TableColumns.allColumns.map { open($0) }.joined(separator: ", "))"
    }

    public var queryFragment: QueryFragment {
        func open<Root, Value>(_ column: some TableColumnExpression<Root, Value>) -> QueryFragment {

            Value(queryOutput: (self as! Root)[keyPath: column.keyPath]).queryFragment
        }
        return TableColumns.allColumns.map { open($0) }.joined(separator: ", ")
    }

    public static subscript<Member: _TableColumnExpression>(
        dynamicMember keyPath: KeyPath<TableColumns, Member>
    ) -> Member {
        columns[keyPath: keyPath]
    }
}

extension Table where DefaultScope == Where<Self> {

    public static var all: DefaultScope {
        Where()
    }
}
