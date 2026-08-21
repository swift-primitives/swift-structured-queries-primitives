extension Select {

    public func map<each C1: QueryRepresentable, each C2: QueryExpression>(
        _ transform: (repeat SQLQueryExpression<each C1>) -> (repeat each C2)
    ) -> Select<(repeat (each C2).QueryValue), From, Joins>
    where
        QueryValue == (repeat each C1),
        repeat (each C2).QueryValue: QueryRepresentable
    {
        var iterator = columns.makeIterator()
        func next<Element>() -> SQLQueryExpression<Element> {

            SQLQueryExpression(iterator.next()!)
        }
        return Select<(repeat (each C2).QueryValue), From, Joins>(
            isEmpty: isEmpty,
            distinct: distinct,
            columns: Array(repeat each transform(repeat { _ in next() }((each C1).self))),
            joins: joins,
            where: `where`,
            group: group,
            having: having,
            order: order,
            windows: windows,
            limit: limit
        )
    }

    public var unscoped: Where<From> {
        From.unscoped
    }

    public var all: Self {
        self
    }

    public var none: Self {
        var select = self
        select.isEmpty = true
        return select
    }
}
