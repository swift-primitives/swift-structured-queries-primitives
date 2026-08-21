extension Where {

    public func join<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), From, (F, repeat each J)> {
        asSelect().join(other, on: constraint)
    }

    public func leftJoin<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C)._Optionalized),
        From,
        (F._Optionalized, repeat (each J)._Optionalized)
    > {
        return asSelect().leftJoin(other, on: constraint)
    }

    public func rightJoin<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), From._Optionalized, (F, repeat each J)> {
        return asSelect().rightJoin(other, on: constraint)
    }

    public func fullJoin<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C)._Optionalized),
        From._Optionalized,
        (F._Optionalized, repeat (each J)._Optionalized)
    > {
        return asSelect().fullJoin(other, on: constraint)
    }

}
