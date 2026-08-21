import Structured_Queries_Primitives_Support

public struct Delete<From: Table, Returning>: Sendable {
    var isEmpty: Bool
    var `where`: [QueryFragment] = []
    var returning: [QueryFragment] = []
}

public typealias DeleteOf<From: Table> = Delete<From, ()>

extension Delete: Statement {

    public typealias QueryValue = Returning

    public var query: QueryFragment {
        guard !isEmpty else { return "" }
        var query: QueryFragment = "DELETE FROM "
        if let schemaName = From.schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append("\(quote: From.tableName)")
        if let tableAlias = From.tableAlias {
            query.append(" AS \(quote: tableAlias)")
        }
        if !`where`.isEmpty {
            query.append("\(.newlineOrSpace)WHERE \(`where`.joined(separator: " AND "))")
        }
        if !returning.isEmpty {
            query.append("\(.newlineOrSpace)RETURNING \(returning.joined(separator: ", "))")
        }
        return query
    }
}
