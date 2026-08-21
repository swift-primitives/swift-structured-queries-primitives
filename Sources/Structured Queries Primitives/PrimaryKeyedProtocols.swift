public protocol PrimaryKeyedTable<PrimaryKey>: Table
where TableColumns: PrimaryKeyedTableDefinition<PrimaryKey> {

    associatedtype PrimaryKey: QueryRepresentable & QueryExpression
    where PrimaryKey.QueryValue == PrimaryKey

    associatedtype Draft: TableDraft where Draft.PrimaryTable == Self
}

public protocol TableDraft: Table {

    associatedtype PrimaryTable: PrimaryKeyedTable where PrimaryTable.Draft == Self

    typealias PrimaryKey = PrimaryTable.PrimaryKey

    init(_ primaryTable: PrimaryTable)
}

extension TableDraft {

    public static subscript(
        dynamicMember keyPath: KeyPath<PrimaryTable.Type, some Statement<PrimaryTable>>
    ) -> some Statement<Self> {
        let statement = project(PrimaryTable.self, through: keyPath)
        return SQLQueryExpression(statement.query, as: Self.self)
    }

    public static subscript(
        dynamicMember keyPath: KeyPath<PrimaryTable.Type, some SelectStatementOf<PrimaryTable>>
    ) -> SelectOf<Self> {
        let statement = project(PrimaryTable.self, through: keyPath)
        return unsafeBitCast(statement.asSelect(), to: SelectOf<Self>.self)
    }

    public static var all: SelectOf<Self> {
        unsafeBitCast(PrimaryTable.all.asSelect(), to: SelectOf<Self>.self)
    }
}

package func project<Root, Value>(
    _ root: Root,
    through keyPath: KeyPath<Root, Value>
) -> Value {
    root[keyPath: keyPath]
}

public protocol PrimaryKeyedTableDefinition<PrimaryKey>: TableDefinition
where QueryValue: PrimaryKeyedTable {

    associatedtype PrimaryKey: QueryRepresentable & QueryExpression
    where PrimaryKey.QueryValue == PrimaryKey

    associatedtype PrimaryColumn: _TableColumnExpression<QueryValue, PrimaryKey>

    var primaryKey: PrimaryColumn { get }
}

extension TableDefinition where QueryValue: TableDraft {

    public subscript<Member>(
        dynamicMember keyPath: KeyPath<QueryValue.PrimaryTable.TableColumns, Member>
    ) -> Member {
        QueryValue.PrimaryTable.columns[keyPath: keyPath]
    }
}
