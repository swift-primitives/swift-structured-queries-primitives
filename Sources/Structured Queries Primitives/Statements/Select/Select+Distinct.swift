extension Select {

    public func distinct(_ isDistinct: Bool = true) -> Self {
        var select = self
        select.distinct = isDistinct ? .all : nil
        return select
    }

    public func distinct(
        @QueryFragmentBuilder<()>
        on expressions: (From.TableColumns) -> [QueryFragment]
    ) -> Self where Joins == () {
        var select = self
        select.distinct = .on(expressions(From.columns))
        return select
    }

    public func distinct<each J: Table>(
        @QueryFragmentBuilder<()>
        on expressions: (From.TableColumns, repeat (each J).TableColumns) -> [QueryFragment]
    ) -> Self where Joins == (repeat each J) {
        var select = self
        select.distinct = .on(expressions(From.columns, repeat (each J).columns))
        return select
    }

    public func distinct(
        @QueryFragmentBuilder<()>
        on expressions: (From.TableColumns, Joins.TableColumns) -> [QueryFragment]
    ) -> Self where Joins: Table {
        var select = self
        select.distinct = .on(expressions(From.columns, Joins.columns))
        return select
    }
}
