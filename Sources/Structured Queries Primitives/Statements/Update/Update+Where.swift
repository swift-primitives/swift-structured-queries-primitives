extension Update {

    public func `where`(
        _ keyPath: KeyPath<From.TableColumns, some QueryExpression<some _OptionalPromotable<Bool?>>>
    ) -> Self {
        var update = self
        update.where.append(From.columns[keyPath: keyPath].queryFragment)
        return update
    }

    @_disfavoredOverload
    public func `where`(
        _ predicate: (From.TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> Self {
        var update = self
        update.where.append(predicate(From.columns).queryFragment)
        return update
    }

    public func `where`(
        @QueryFragmentBuilder<Bool> _ predicate: (From.TableColumns) -> [QueryFragment]
    ) -> Self {
        var update = self
        update.where.append(contentsOf: predicate(From.columns))
        return update
    }
}
