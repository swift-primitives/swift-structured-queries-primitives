import Structured_Queries_Primitives_Support

public struct Update<From: Table, Returning>: Sendable {
    var isEmpty: Bool
    var updates: Updates<From>
    var `where`: [QueryFragment] = []
    var returning: [QueryFragment] = []
}

public typealias UpdateOf<Base: Table> = Update<Base, ()>

extension Update: Statement {

    public typealias QueryValue = Returning

    public var query: QueryFragment {
        guard !isEmpty, !updates.isEmpty
        else { return "" }

        var query: QueryFragment = "UPDATE "
        if let schemaName = From.schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append("\(quote: From.tableName)")
        if let tableAlias = From.tableAlias {
            query.append(" AS \(quote: tableAlias)")
        }
        query.append("\(.newlineOrSpace)\(updates)")
        if !`where`.isEmpty {
            query.append("\(.newlineOrSpace)WHERE \(`where`.joined(separator: " AND "))")
        }
        if !returning.isEmpty {
            query.append("\(.newlineOrSpace)RETURNING \(returning.joined(separator: ", "))")
        }
        return query
    }
}
