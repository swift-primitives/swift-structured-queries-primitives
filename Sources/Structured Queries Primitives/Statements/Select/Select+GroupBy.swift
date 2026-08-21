extension Select {

    @_disfavoredOverload
    public func group<C: QueryExpression, each J: Table>(
        by grouping: (From.TableColumns, repeat (each J).TableColumns) -> C
    ) -> Self where Joins == (repeat each J) {
        _group(by: grouping)
    }

    @_disfavoredOverload
    public func group<
        C1: QueryExpression,
        C2: QueryExpression,
        each C3: QueryExpression,
        each J: Table
    >(
        by grouping: (From.TableColumns, repeat (each J).TableColumns) -> (C1, C2, repeat each C3)
    ) -> Self where Joins == (repeat each J) {
        _group(by: grouping)
    }

    public func group<C: QueryExpression>(
        by grouping: (From.TableColumns, Joins.TableColumns) -> C
    ) -> Self where Joins: Table {
        _groupSingleJoin(by: grouping)
    }

    public func group<
        C1: QueryExpression,
        C2: QueryExpression,
        each C3: QueryExpression
    >(
        by grouping: (From.TableColumns, Joins.TableColumns) -> (C1, C2, repeat each C3)
    ) -> Self where Joins: Table {
        _groupSingleJoin(by: grouping)
    }

    private func _group<
        each C: QueryExpression,
        each J: Table
    >(
        by grouping: (From.TableColumns, repeat (each J).TableColumns) -> (repeat each C)
    ) -> Self where Joins == (repeat each J) {
        var select = self
        select.group
            .append(
                contentsOf: Array(repeat each grouping(From.columns, repeat (each J).columns))
            )
        return select
    }

    private func _groupSingleJoin<each C: QueryExpression>(
        by grouping: (From.TableColumns, Joins.TableColumns) -> (repeat each C)
    ) -> Self where Joins: Table {
        var select = self
        select.group
            .append(
                contentsOf: Array(repeat each grouping(From.columns, Joins.columns))
            )
        return select
    }
}
