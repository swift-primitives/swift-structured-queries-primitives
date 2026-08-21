extension Table {

    public static func select<ResultColumn: QueryExpression>(
        _ selection: KeyPath<TableColumns, ResultColumn>
    ) -> Select<ResultColumn.QueryValue, Self, ()>
    where ResultColumn.QueryValue: QueryRepresentable {
        Where().select(selection)
    }

    public static func select<ResultColumn: QueryExpression>(
        _ selection: (TableColumns) -> ResultColumn
    ) -> Select<ResultColumn.QueryValue, Self, ()>
    where ResultColumn.QueryValue: QueryRepresentable {
        Where().select(selection)
    }

    public static func select<
        C1: QueryExpression,
        C2: QueryExpression,
        each C3: QueryExpression
    >(
        _ selection: (TableColumns) -> (C1, C2, repeat each C3)
    ) -> Select<(C1.QueryValue, C2.QueryValue, repeat (each C3).QueryValue), Self, ()>
    where
        C1.QueryValue: QueryRepresentable,
        C2.QueryValue: QueryRepresentable,
        repeat (each C3).QueryValue: QueryRepresentable
    {
        Where().select(selection)
    }

    public static func distinct(_ isDistinct: Bool = true) -> SelectOf<Self> {
        Where().distinct(isDistinct)
    }

    public static func distinct(
        @QueryFragmentBuilder<()>
        on expressions: (TableColumns) -> [QueryFragment]
    ) -> SelectOf<Self> {
        Where().distinct(on: expressions)
    }

    public static func join<
        each C: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), Self, (F, repeat each J)> {
        Where().join(other, on: constraint)
    }

    @_documentation(visibility: private)
    public static func join<each C: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C), F, ()>,
        on constraint: (
            (TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), Self, F> {
        Where().join(other, on: constraint)
    }

    public static func leftJoin<
        each C: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C)._Optionalized),
        Self,
        (F._Optionalized, repeat (each J)._Optionalized)
    > {
        Where().leftJoin(other, on: constraint)
    }

    @_documentation(visibility: private)
    public static func leftJoin<each C: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C), F, ()>,
        on constraint: (
            (TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat (each C)._Optionalized), Self, F._Optionalized> {
        Where().leftJoin(other, on: constraint)
    }

    public static func rightJoin<
        each C: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), Self._Optionalized, (F, repeat each J)> {
        Where<Self>().rightJoin(other, on: constraint)
    }

    @_documentation(visibility: private)
    public static func rightJoin<each C: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C), F, ()>,
        on constraint: (
            (TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), Self._Optionalized, F> {
        Where<Self>().rightJoin(other, on: constraint)
    }

    public static func fullJoin<
        each C: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C)._Optionalized),
        Self._Optionalized,
        (F._Optionalized, repeat (each J)._Optionalized)
    > {
        Where<Self>().fullJoin(other, on: constraint)
    }

    @_documentation(visibility: private)
    public static func fullJoin<each C: QueryRepresentable, F: Table>(
        _ other: some SelectStatement<(repeat each C), F, ()>,
        on constraint: (
            (TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat (each C)._Optionalized), Self._Optionalized, F._Optionalized> {
        Where<Self>().fullJoin(other, on: constraint)
    }

    public static func group<C: QueryExpression>(
        by grouping: (TableColumns) -> C
    ) -> SelectOf<Self> {
        Where().group(by: grouping)
    }

    public static func group<
        C1: QueryExpression,
        C2: QueryExpression,
        each C3: QueryExpression
    >(
        by grouping: (TableColumns) -> (C1, C2, repeat each C3)
    ) -> SelectOf<Self> {
        Where().group(by: grouping)
    }

    public static func having(
        _ predicate: (TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> SelectOf<Self> {
        Where().having(predicate)
    }

    public static func order(
        by ordering: KeyPath<TableColumns, some QueryExpression>
    ) -> SelectOf<Self> {
        Where().order(by: ordering)
    }

    public static func order(
        @QueryFragmentBuilder<()>
        by ordering: (TableColumns) -> [QueryFragment]
    ) -> SelectOf<Self> {
        Where().order(by: ordering)
    }

    public static func limit(
        _ maxLength: (TableColumns) -> some QueryExpression<Int>,
        offset: ((TableColumns) -> some QueryExpression<Int>)? = nil
    ) -> SelectOf<Self> {
        Where().limit(maxLength, offset: offset)
    }

    public static func limit(_ maxLength: Int, offset: Int? = nil) -> SelectOf<Self> {
        Where().limit(maxLength, offset: offset)
    }

}
