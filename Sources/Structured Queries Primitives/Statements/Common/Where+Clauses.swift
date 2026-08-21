extension Where {

    public func group<C: QueryExpression>(
        by grouping: (From.TableColumns) -> C
    ) -> Select<(), From, ()> {
        asSelect().group(by: grouping)
    }

    public func group<C1: QueryExpression, C2: QueryExpression, each C3: QueryExpression>(
        by grouping: (From.TableColumns) -> (C1, C2, repeat each C3)
    ) -> SelectOf<From> {
        asSelect().group(by: grouping)
    }

    public func having(
        _ predicate: (From.TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> SelectOf<From> {
        asSelect().having(predicate)
    }

    public func order(
        by ordering: KeyPath<From.TableColumns, some QueryExpression>
    ) -> SelectOf<From> {
        asSelect().order(by: ordering)
    }

    public func order(
        @QueryFragmentBuilder<()>
        by ordering: (From.TableColumns) -> [QueryFragment]
    ) -> SelectOf<From> {
        asSelect().order(by: ordering)
    }

    public func limit(
        _ maxLength: (From.TableColumns) -> some QueryExpression<Int>,
        offset: ((From.TableColumns) -> some QueryExpression<Int>)? = nil
    ) -> SelectOf<From> {
        asSelect().limit(maxLength, offset: offset)
    }

    public func limit(_ maxLength: Int, offset: Int? = nil) -> SelectOf<From> {
        asSelect().limit(maxLength, offset: offset)
    }
}
