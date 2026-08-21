extension Select {

    public func limit<each J: Table>(
        _ maxLength: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<Int>,
        offset: ((From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<Int>)? =
            nil
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.limit = _LimitClause(
            maxLength: maxLength(From.columns, repeat (each J).columns).queryFragment,
            offset: offset?(From.columns, repeat (each J).columns).queryFragment
                ?? select.limit?.offset
        )
        return select
    }

    public func limit(
        _ maxLength: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<Int>,
        offset: ((From.TableColumns, Joins.TableColumns) -> some QueryExpression<Int>)? = nil
    ) -> Self
    where Joins: Table {
        var select = self
        select.limit = _LimitClause(
            maxLength: maxLength(From.columns, Joins.columns).queryFragment,
            offset: offset?(From.columns, Joins.columns).queryFragment ?? select.limit?.offset
        )
        return select
    }

    public func limit<each J: Table>(_ maxLength: Int, offset: Int? = nil) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.limit = _LimitClause(
            maxLength: maxLength.queryFragment,
            offset: offset?.queryFragment ?? select.limit?.offset
        )
        return select
    }
}
