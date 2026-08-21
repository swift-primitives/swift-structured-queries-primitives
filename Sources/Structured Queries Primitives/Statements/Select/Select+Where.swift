extension Select {

    public func `where`(
        _ keyPath: KeyPath<From.TableColumns, some QueryExpression<some _OptionalPromotable<Bool?>>>
    ) -> Self
    where Joins == () {
        var select = self
        select.where.append(From.columns[keyPath: keyPath].queryFragment)
        return select
    }

    @_disfavoredOverload
    public func `where`<each J: Table>(
        _ predicate: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            some _OptionalPromotable<Bool?>
        >
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.where.append(predicate(From.columns, repeat (each J).columns).queryFragment)
        return select
    }

    public func `where`<each J: Table>(
        @QueryFragmentBuilder<Bool>
        _ predicate: (From.TableColumns, repeat (each J).TableColumns) -> [QueryFragment]
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.where.append(contentsOf: predicate(From.columns, repeat (each J).columns))
        return select
    }

    @_disfavoredOverload
    public func `where`(
        _ predicate: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<
            some _OptionalPromotable<Bool?>
        >
    ) -> Self
    where Joins: Table {
        var select = self
        select.where.append(predicate(From.columns, Joins.columns).queryFragment)
        return select
    }

    public func `where`(
        @QueryFragmentBuilder<Bool>
        _ predicate: (From.TableColumns, Joins.TableColumns) -> [QueryFragment]
    ) -> Self
    where Joins: Table {
        var select = self
        select.where.append(contentsOf: predicate(From.columns, Joins.columns))
        return select
    }

    public func and(_ other: Where<From>) -> Self {
        var select = self
        select.where = (select.where + other.predicates).removingDuplicates()
        return select
    }

    public func or(_ other: Where<From>) -> Self {
        var select = self
        if select.where.isEmpty {
            select.where = other.predicates
        } else {
            let combined: QueryFragment = """
                (\(select.where.joined(separator: " AND ")) \
                OR \
                \(other.predicates.joined(separator: " AND ")))
                """
            select.where = [combined]
        }
        return select
    }
}
