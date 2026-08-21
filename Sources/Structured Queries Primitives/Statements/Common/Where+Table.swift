extension Table {

    public static func `where`(
        _ keyPath: KeyPath<TableColumns, some QueryExpression<some _OptionalPromotable<Bool?>>>
    ) -> Where<Self> {
        Where(predicates: [columns[keyPath: keyPath].queryFragment])
    }

    @_disfavoredOverload
    public static func `where`(
        _ predicate: (TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> Where<Self> {
        Where(predicates: [predicate(columns).queryFragment])
    }

    public static func `where`(
        @QueryFragmentBuilder<Bool> _ predicate: (TableColumns) -> [QueryFragment]
    ) -> Where<Self> {
        Where(predicates: predicate(columns))
    }
}
