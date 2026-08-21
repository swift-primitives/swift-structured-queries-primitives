extension Select {

    public func rightJoin<
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
        (repeat (each C1)._Optionalized, repeat each C2),
        From._Optionalized,
        (repeat (each J1)._Optionalized, F, repeat each J2)
    >
    where Columns == (repeat each C1), Joins == (repeat each J1) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
            )
        )
        return Select<
            (repeat (each C1)._Optionalized, repeat each C2),
            From._Optionalized,
            (repeat (each J1)._Optionalized, F, repeat each J2)
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
    public func rightJoin<
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
        (repeat (each C1)._Optionalized, repeat each C2),
        From._Optionalized,
        (repeat (each J)._Optionalized, F)
    >
    where Columns == (repeat each C1), Joins == (repeat each J) {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            table: F.self,
            constraint: constraint(
                (From.columns, repeat (each J).columns, F.columns)
            )
        )
        return Select<
            (repeat (each C1)._Optionalized, repeat each C2),
            From._Optionalized,
            (repeat (each J)._Optionalized, F)
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
    public func rightJoin<F: Table, each J: Table>(
        _ other: some SelectStatement<(), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<QueryValue, From._Optionalized, (F, repeat each J)>
    where QueryValue: QueryRepresentable {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns, repeat (each J).columns)
            )
        )
        return Select<QueryValue, From._Optionalized, (F, repeat each J)>(
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
    public func rightJoin<each C: QueryRepresentable, F: Table, each J: Table>(
        _ other: some SelectStatement<(repeat each C), F, (repeat each J)>,
        on constraint: (
            (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(repeat each C), From._Optionalized, (F, repeat each J)>
    where Columns == (), Joins == () {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns, repeat (each J).columns)
            )
        )
        return Select<(repeat each C), From._Optionalized, (F, repeat each J)>(
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
    public func rightJoin<F: Table>(
        _ other: some SelectStatementOf<F>,
        on constraint: (
            (From.TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(), From._Optionalized, F>
    where Columns == (), Joins == () {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            table: F.self,
            constraint: constraint(
                (From.columns, F.columns)
            )
        )
        return Select<(), From._Optionalized, F>(
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
    public func rightJoin<F: Table>(
        _ other: some SelectStatementOf<F>,
        on constraint: (
            (From.TableColumns, Joins.TableColumns, F.TableColumns)
        ) -> some QueryExpression<Bool>
    ) -> Select<(), From._Optionalized, (Joins._Optionalized, F)>
    where Joins: Table {
        let other = other.asSelect()
        let join = _JoinClause(
            operator: .right,
            table: F.self,
            constraint: constraint(
                (From.columns, Joins.columns, F.columns)
            )
        )
        return Select<(), From._Optionalized, (Joins._Optionalized, F)>(
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
