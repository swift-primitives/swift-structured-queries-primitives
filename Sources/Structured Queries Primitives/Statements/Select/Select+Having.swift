extension Select {

    @_disfavoredOverload
    public func having<each J: Table>(
        _ predicate: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            some _OptionalPromotable<Bool?>
        >
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.having.append(predicate(From.columns, repeat (each J).columns).queryFragment)
        return select
    }

    public func having<each J: Table>(
        @QueryFragmentBuilder<Bool>
        _ predicate: (From.TableColumns, repeat (each J).TableColumns) -> [QueryFragment]
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.having.append(contentsOf: predicate(From.columns, repeat (each J).columns))
        return select
    }

    @_disfavoredOverload
    public func having(
        _ predicate: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<
            some _OptionalPromotable<Bool?>
        >
    ) -> Self
    where Joins: Table {
        var select = self
        select.having.append(predicate(From.columns, Joins.columns).queryFragment)
        return select
    }

    public func having(
        @QueryFragmentBuilder<Bool>
        _ predicate: (From.TableColumns, Joins.TableColumns) -> [QueryFragment]
    ) -> Self
    where Joins: Table {
        var select = self
        select.having.append(contentsOf: predicate(From.columns, Joins.columns))
        return select
    }

    public func orHaving(_ predicates: [QueryFragment]) -> Self {
        var select = self
        if select.having.isEmpty {
            select.having = predicates
        } else {
            let combined: QueryFragment = """
                (\(select.having.joined(separator: " AND ")) \
                OR \
                \(predicates.joined(separator: " AND ")))
                """
            select.having = [combined]
        }
        return select
    }
}
