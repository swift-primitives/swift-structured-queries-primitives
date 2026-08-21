extension Select {

    public func order(by ordering: KeyPath<From.TableColumns, some QueryExpression>) -> Self {
        var select = self
        select.order.append(From.columns[keyPath: ordering].queryFragment)
        return select
    }

    public func order<each J: Table>(
        @QueryFragmentBuilder<()>
        by ordering: (From.TableColumns, repeat (each J).TableColumns) -> [QueryFragment]
    ) -> Self
    where Joins == (repeat each J) {
        var select = self
        select.order.append(contentsOf: ordering(From.columns, repeat (each J).columns))
        return select
    }

    public func order(
        @QueryFragmentBuilder<()>
        by ordering: (From.TableColumns, Joins.TableColumns) -> [QueryFragment]
    ) -> Self
    where Joins: Table {
        var select = self
        select.order.append(contentsOf: ordering(From.columns, Joins.columns))
        return select
    }
}
