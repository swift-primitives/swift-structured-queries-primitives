import Structured_Queries_Primitives_Support

extension Delete {

    public func returning<each QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
    ) -> Delete<From, (repeat each QueryValue)> {
        var returning: [QueryFragment] = []
        for resultColumn in repeat each selection(From.columns) {
            returning.append("\(quote: resultColumn.name)")
        }
        return Delete<From, (repeat each QueryValue)>(
            isEmpty: isEmpty,
            where: `where`,
            returning: Array(repeat each selection(From.columns))
        )
    }

    public func returning<QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> TableColumn<From, QueryValue>
    ) -> Delete<From, QueryValue> {
        let column = selection(From.columns)
        return Delete<From, QueryValue>(
            isEmpty: isEmpty,
            where: `where`,
            returning: [column.queryFragment]
        )
    }

    @_documentation(visibility: private)
    @_disfavoredOverload
    public func returning(
        _ selection: (From.TableColumns) -> From.TableColumns
    ) -> Delete<From, From> {
        var returning: [QueryFragment] = []
        for resultColumn in From.TableColumns.allColumns {
            returning.append("\(quote: resultColumn.name)")
        }
        return Delete<From, From>(
            isEmpty: isEmpty,
            where: `where`,
            returning: returning
        )
    }
}
