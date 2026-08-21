import Structured_Queries_Primitives_Support

extension CTE {

    public struct Clause: QueryExpression, Sendable {
        let tableName: QueryFragment
        let select: QueryFragment
        let materialization: MaterializationHint?

        public init(
            tableName: QueryFragment,
            select: QueryFragment,
            materialization: MaterializationHint? = nil
        ) {
            self.tableName = tableName
            self.select = select
            self.materialization = materialization
        }
    }
}

extension CTE.Clause {

    public typealias QueryValue = ()

    public var queryFragment: QueryFragment {
        guard !select.isEmpty else { return "" }

        var fragment: QueryFragment = tableName

        if let materialization {
            switch materialization {
            case .materialized:
                fragment.append(" AS MATERIALIZED")

            case .notMaterialized:
                fragment.append(" AS NOT MATERIALIZED")
            }
        } else {
            fragment.append(" AS")
        }

        fragment.append(" (\(.newline)\(select.indented())\(.newline))")
        return fragment
    }

    var isRecursive: Bool {
        let tableNameString = extractTableName(from: tableName)
        let selectSQL = extractSQL(from: select)

        let hasUnion = selectSQL.contains("UNION ALL") || selectSQL.contains("UNION")
        guard hasUnion else { return false }

        let quotedTableName = "\"\(tableNameString)\""
        return selectSQL.contains("FROM \(quotedTableName)")
            || selectSQL.contains("FROM \(tableNameString)")
    }

    private func extractTableName(from fragment: QueryFragment) -> String {

        fragment.segments
            .compactMap { segment in
                if case .sql(let sql) = segment {
                    return sql.trimmedWhitespaceAndNewlines()
                }
                return nil
            }
            .joined()
    }

    private func extractSQL(from fragment: QueryFragment) -> String {
        fragment.segments
            .compactMap { segment in
                if case .sql(let sql) = segment {
                    return sql
                }
                return nil
            }
            .joined()
    }
}

extension CTE.Clause {

    public enum MaterializationHint: Sendable {

        case materialized

        case notMaterialized
    }
}

extension StringProtocol {

    fileprivate func trimmedWhitespaceAndNewlines() -> String {
        var slice = Substring(self)
        while let first = slice.first, first.isWhitespace { slice = slice.dropFirst() }
        while let last = slice.last, last.isWhitespace { slice = slice.dropLast() }
        return String(slice)
    }
}
