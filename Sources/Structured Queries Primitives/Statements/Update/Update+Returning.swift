extension Update {

    public func returning<each QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
    ) -> Update<From, (repeat each QueryValue)> {
        var returning: [QueryFragment] = []
        for resultColumn in repeat each selection(From.columns) {
            returning.append(resultColumn.queryFragment)
        }
        return Update<From, (repeat each QueryValue)>(
            isEmpty: false,
            updates: updates,
            where: `where`,
            returning: returning
        )
    }

    public func returning<QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> TableColumn<From, QueryValue>
    ) -> Update<From, QueryValue> {
        let column = selection(From.columns)
        return Update<From, QueryValue>(
            isEmpty: isEmpty,
            updates: updates,
            where: `where`,
            returning: [column.queryFragment]
        )
    }

    @_documentation(visibility: private)
    @_disfavoredOverload
    public func returning(
        _ selection: (From.TableColumns) -> From.TableColumns
    ) -> Update<From, From> {
        var returning: [QueryFragment] = []
        for resultColumn in From.TableColumns.allColumns {
            returning.append(resultColumn.queryFragment)
        }
        return Update<From, From>(
            isEmpty: isEmpty,
            updates: updates,
            where: `where`,
            returning: returning
        )
    }
}
