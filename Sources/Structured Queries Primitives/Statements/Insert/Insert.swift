import Structured_Queries_Primitives_Support

private func isNullBinding(_ fragment: QueryFragment) -> Bool {

    if fragment.segments.isEmpty {
        return true
    }

    for segment in fragment.segments {

        if case .binding(.null) = segment {
            return true
        }
    }

    return false
}

public enum InsertValues: Sendable {
    case `default`
    case values([[QueryFragment]])
    case select(QueryFragment)
}

public struct Insert<Into: Table, Returning>: Sendable {
    var columnNames: [String]
    var conflictTargetColumnNames: [String]
    var conflictTargetFilter: [QueryFragment]
    var values: InsertValues
    var updates: Updates<Into>?
    var updateFilter: [QueryFragment]
    var returning: [QueryFragment]

    public func returning<each QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
    ) -> Insert<Into, (repeat each QueryValue)> {
        var returning: [QueryFragment] = []
        for resultColumn in repeat each selection(From.columns) {
            returning.append("\(quote: resultColumn.name)")
        }
        return Insert<Into, (repeat each QueryValue)>(
            columnNames: columnNames,
            conflictTargetColumnNames: conflictTargetColumnNames,
            conflictTargetFilter: conflictTargetFilter,
            values: values,
            updates: updates,
            updateFilter: updateFilter,
            returning: returning
        )
    }

    public func returning<QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> TableColumn<From, QueryValue>
    ) -> Insert<Into, QueryValue> {
        let column = selection(From.columns)
        return Insert<Into, QueryValue>(
            columnNames: columnNames,
            conflictTargetColumnNames: conflictTargetColumnNames,
            conflictTargetFilter: conflictTargetFilter,
            values: values,
            updates: updates,
            updateFilter: updateFilter,
            returning: [column.queryFragment]
        )
    }

    @_documentation(visibility: private)
    @_disfavoredOverload
    public func returning(
        _ selection: (Into.TableColumns) -> Into.TableColumns
    ) -> Insert<Into, Into> {
        var returning: [QueryFragment] = []
        for resultColumn in From.TableColumns.allColumns {
            returning.append("\(quote: resultColumn.name)")
        }
        return Insert<Into, Into>(
            columnNames: columnNames,
            conflictTargetColumnNames: conflictTargetColumnNames,
            conflictTargetFilter: conflictTargetFilter,
            values: values,
            updates: updates,
            updateFilter: updateFilter,
            returning: returning
        )
    }
}

extension Insert: Statement {

    public typealias QueryValue = Returning

    public typealias From = Into

    public var query: QueryFragment {
        var query: QueryFragment = "INSERT"
        query.append(" INTO ")
        if let schemaName = Into.schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append("\(quote: Into.tableName)")
        if let tableAlias = Into.tableAlias {
            query.append(" AS \(quote: tableAlias)")
        }
        if !columnNames.isEmpty {
            query.append(
                "\(.newlineOrSpace)(\(columnNames.map { "\(quote: $0)" }.joined(separator: ", ")))"
            )
        }
        switch values {
        case .default:
            query.append("\(.newlineOrSpace)DEFAULT VALUES")

        case .select(let select):
            query.append("\(.newlineOrSpace)\(select)")

        case .values(let values):
            guard !values.isEmpty else { return "" }
            query.append("\(.newlineOrSpace)VALUES\(.newlineOrSpace)")
            let values: [QueryFragment] = values.map {
                var value: QueryFragment = "("
                value.append($0.joined(separator: ", "))
                value.append(")")
                return value
            }
            query.append(values.joined(separator: ", "))
        }

        var hasInvalidWhere = false
        if let updates {
            query.append("\(.newlineOrSpace)ON CONFLICT ")
            if !conflictTargetColumnNames.isEmpty {
                query.append("(")
                query.append(
                    conflictTargetColumnNames.map { "\(quote: $0)" }.joined(separator: ", ")
                )
                query.append(")\(.newlineOrSpace)")
                if !conflictTargetFilter.isEmpty {
                    query.append(
                        "WHERE \(conflictTargetFilter.joined(separator: " AND "))\(.newlineOrSpace)"
                    )
                }
            }
            query.append("DO ")
            if updates.isEmpty {
                query.append("NOTHING")
                hasInvalidWhere = !updateFilter.isEmpty
            } else {
                query.append("UPDATE \(bind: updates)")
                if !updateFilter.isEmpty {
                    query.append(
                        "\(.newlineOrSpace)WHERE \(updateFilter.joined(separator: " AND "))"
                    )
                }
            }
        } else {
            hasInvalidWhere = !updateFilter.isEmpty
        }
        if !returning.isEmpty {
            query.append("\(.newlineOrSpace)RETURNING \(returning.joined(separator: ", "))")
        }
        if hasInvalidWhere {
            let message = """
                Insert statement has invalid update 'where': \(updateFilter.joined(separator: " AND "))

                \(query)
                """
            if let report = QueryFragment.Report.invalid {
                report.run(message)
            } else {
                assertionFailure(message)
            }
        }
        return query
    }
}

public typealias InsertOf<Into: Table> = Insert<Into, ()>
