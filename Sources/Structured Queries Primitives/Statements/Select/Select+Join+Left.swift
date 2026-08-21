extension Select {

    public func leftJoin<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J1: Table,
        each J2: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, (repeat each J2)>,
        on constraint: (
            (
                From.TableColumns, repeat (each J1).TableColumns, F.TableColumns,
                repeat (each J2).TableColumns
            )
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat each C1, repeat (each C2)._Optionalized),
        From,
        (repeat each J1, F._Optionalized, repeat (each J2)._Optionalized)
    >
    where Columns == (repeat each C1), Joins == (repeat each J1) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
            )
        )
        return Select<
            (repeat each C1, repeat (each C2)._Optionalized),
            From,
            (repeat each J1, F._Optionalized, repeat (each J2)._Optionalized)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: other.distinct ?? distinct,
            columns: columns + other.columns,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            windows: windows + other.windows,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func leftJoin<
        each C1: QueryRepresentable,
        each C2: QueryRepresentable,
        F: Table,
        each J: Table
    >(
        _ other: some SelectStatement<(repeat each C2), F, ()>,
        on constraint: (
            (From.TableColumns, repeat (each J).TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat each C1, repeat (each C2)._Optionalized),
        From,
        (repeat each J, F._Optionalized)
    >
    where Columns == (repeat each C1), Joins == (repeat each J) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J).columns, F.columns)
            )
        )
        return Select<
            (repeat each C1, repeat (each C2)._Optionalized),
            From,
            (repeat each J, F._Optionalized)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: other.distinct ?? distinct,
            columns: columns + other.columns,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            windows: windows + other.windows,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func leftJoin<F: Table, each J: Table>(
        _ other: some SelectStatement<(), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<QueryValue, From, (F._Optionalized, repeat (each J)._Optionalized)>
    where QueryValue: QueryRepresentable {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns, repeat (each J).columns)
            )
        )
        return Select<QueryValue, From, (F._Optionalized, repeat (each J)._Optionalized)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: other.distinct ?? distinct,
            columns: columns + other.columns,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            windows: windows + other.windows,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func leftJoin<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<
        (repeat (each C)._Optionalized), From, (F._Optionalized, repeat (each J)._Optionalized)
    >
    where Columns == (), Joins == () {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns, repeat (each J).columns)
            )
        )
        return Select<
            (repeat (each C)._Optionalized), From, (F._Optionalized, repeat (each J)._Optionalized)
        >(
            isEmpty: isEmpty || other.isEmpty,
            distinct: other.distinct ?? distinct,
            columns: columns + other.columns,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            windows: windows + other.windows,
            limit: other.limit ?? limit
        )
    }

    @_documentation(visibility: private)
    public func leftJoin<F: Table>(
        _ other: some SelectStatementOf<F>,
        on constraint: (
            (From.TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(), From, F._Optionalized>
    where Columns == (), Joins == () {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns)
            )
        )
        return Select<(), From, F._Optionalized>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: other.distinct ?? distinct,
            columns: columns + other.columns,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            windows: windows + other.windows,
            limit: other.limit ?? limit
        )
    }

    @_disfavoredOverload
    @_documentation(visibility: private)
    public func leftJoin<F: Table>(
        _ other: some SelectStatementOf<F>,
        on constraint: (
            (From.TableColumns, Joins.TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(), From, (Joins, F._Optionalized)>
    where Joins: Table {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .left,
            table: F.self,
            constraint: constraint(
                (From.columns, Joins.columns, F.columns)
            )
        )
        return Select<(), From, (Joins, F._Optionalized)>(
            isEmpty: isEmpty || other.isEmpty,
            distinct: other.distinct ?? distinct,
            columns: columns + other.columns,
            joins: joins + [join] + other.joins,
            where: `where` + other.where,
            group: group + other.group,
            having: having + other.having,
            order: order + other.order,
            windows: windows + other.windows,
            limit: other.limit ?? limit
        )
    }
}
