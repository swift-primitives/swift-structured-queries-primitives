extension Where {

    public func select<C: QueryExpression>(
        _ selection: KeyPath<From.TableColumns, C>
    ) -> Select<C.QueryValue, From, ()>
    where C.QueryValue: QueryRepresentable {
        asSelect().select(selection)
    }

    public func select<C: QueryExpression>(
        _ selection: (From.TableColumns) -> C
    ) -> Select<C.QueryValue, From, ()>
    where C.QueryValue: QueryRepresentable {
        asSelect().select(selection)
    }

    public func select<C1: QueryExpression, C2: QueryExpression, each C3: QueryExpression>(
        _ selection: (From.TableColumns) -> (C1, C2, repeat each C3)
    ) -> Select<(C1.QueryValue, C2.QueryValue, repeat (each C3).QueryValue), From, ()>
    where
        C1.QueryValue: QueryRepresentable,
        C2.QueryValue: QueryRepresentable,
        repeat (each C3).QueryValue: QueryRepresentable
    {
        asSelect().select(selection)
    }

    public func distinct(_ isDistinct: Bool = true) -> SelectOf<From> {
        asSelect().distinct(isDistinct)
    }

    public func distinct(
        @QueryFragmentBuilder<()>
        on expressions: (From.TableColumns) -> [QueryFragment]
    ) -> SelectOf<From> {
        asSelect().distinct(on: expressions)
    }
}
