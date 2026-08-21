import Structured_Queries_Primitives_Support

extension Table {

    public static func createTemporaryView<Selection: PartialSelectStatement>(
        orReplace: Bool = false,
        as select: Selection
    ) -> TemporaryView<Self, Selection>
    where Selection.QueryValue == Columns.QueryValue {
        TemporaryView(orReplace: orReplace, select: select)
    }
}

public struct TemporaryView<View: Table, Selection: PartialSelectStatement>: Statement
where Selection.QueryValue == View {

    public typealias QueryValue = ()

    public typealias From = Never

    fileprivate let orReplace: Bool
    fileprivate let select: Selection

    public func drop(ifExists: Bool = false) -> some Statement<()> {
        var query: QueryFragment = "DROP VIEW"
        if ifExists {
            query.append(" IF EXISTS")
        }
        query.append(" ")
        if let schemaName = View.schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append(View.tableFragment)
        return SQLQueryExpression(query)
    }

    public var query: QueryFragment {
        var query: QueryFragment = "CREATE"
        if orReplace {
            query.append(" OR REPLACE")
        }
        query.append(" TEMP VIEW")
        query.append(.newlineOrSpace)
        if let schemaName = View.schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append(View.tableFragment)
        let columnNames: [QueryFragment] = View.TableColumns.allColumns
            .map { "\(quote: $0.name)" }
        query.append("\(.newlineOrSpace)(\(columnNames.joined(separator: ", ")))")
        query.append("\(.newlineOrSpace)AS")
        query.append("\(.newlineOrSpace)\(select)")
        return query
    }
}
