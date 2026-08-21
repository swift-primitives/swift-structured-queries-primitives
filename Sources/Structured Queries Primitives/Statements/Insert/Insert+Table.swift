extension Table {

    public typealias Excluded = TableAlias<Self, _ExcludedName>.TableColumns

    public static func insert(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> [[QueryFragment]],
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        _insert(
            columnNames: TableColumns.writableColumns.map(\.name),
            values: .values(values()),
            onConflict: { _ -> ()? in nil },
            where: [],
            doUpdate: updates,
            where: updateFilter(Self.columns)
        )
    }

    public static func insert(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> [[QueryFragment]],
        onConflictDoUpdate updates: ((inout Updates<Self>) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflictDoUpdate: updates.map { updates in { row, _ in updates(&row) } },
            where: updateFilter
        )
    }

    public static func insert<T1, each T2>(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> [[QueryFragment]],
        onConflict conflictTargets: (TableColumns) -> (
            TableColumn<Self, T1>, repeat TableColumn<Self, each T2>
        ),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        withoutActuallyEscaping(updates) { updates in
            _insert(
                columnNames: TableColumns.writableColumns.map(\.name),
                values: .values(values()),
                onConflict: conflictTargets,
                where: targetFilter(Self.columns),
                doUpdate: updates,
                where: updateFilter(Self.columns)
            )
        }
    }

    public static func insert<T1, each T2>(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> [[QueryFragment]],
        onConflict conflictTargets: (TableColumns) -> (
            TableColumn<Self, T1>, repeat TableColumn<Self, each T2>
        ),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>) -> Void,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: { row, _ in updates(&row) },
            where: updateFilter
        )
    }

    public static func insert<V1: _TableColumnExpression, each V2: _TableColumnExpression>(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        @InsertValuesBuilder<(V1.Value, repeat (each V2).Value)>
        values: () -> [[QueryFragment]],
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        _insert(
            columns,
            values: values,
            onConflict: { _ -> ()? in nil },
            where: [],
            doUpdate: updates,
            where: updateFilter(Self.columns)
        )
    }

    public static func insert<V1: _TableColumnExpression, each V2: _TableColumnExpression>(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        @InsertValuesBuilder<(V1.Value, repeat (each V2).Value)>
        values: () -> [[QueryFragment]],
        onConflictDoUpdate updates: ((inout Updates<Self>) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflictDoUpdate: updates.map { updates in { row, _ in updates(&row) } },
            where: updateFilter
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        @InsertValuesBuilder<(V1.Value, repeat (each V2).Value)>
        values: () -> [[QueryFragment]],
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        withoutActuallyEscaping(updates) { updates in
            _insert(
                columns,
                values: values,
                onConflict: conflictTargets,
                where: targetFilter(Self.columns),
                doUpdate: updates,
                where: updateFilter(Self.columns)
            )
        }
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        @InsertValuesBuilder<(V1.Value, repeat (each V2).Value)>
        values: () -> [[QueryFragment]],
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>) -> Void,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: { row, _ in updates(&row) },
            where: updateFilter
        )
    }

    private static func _insert<
        each Value: _TableColumnExpression,
        each ConflictTarget: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (repeat each Value),
        @InsertValuesBuilder<(repeat (each Value).Value)>
        values: () -> [[QueryFragment]],
        onConflict conflictTargets: (TableColumns) -> (repeat each ConflictTarget)?,
        where targetFilter: [QueryFragment] = [],
        doUpdate updates: ((inout Updates<Self>, Excluded) -> Void)?,
        where updateFilter: [QueryFragment] = []
    ) -> InsertOf<Self> {
        var columnNames: [String] = []
        for column in repeat each columns(Self.columns) {
            columnNames.append(contentsOf: column._names)
        }
        return _insert(
            columnNames: columnNames,
            values: .values(values()),
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: updates,
            where: updateFilter
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        select selection: () -> some PartialSelectStatement<(V1.Value, repeat (each V2).Value)>,
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        _insert(
            columns,
            select: selection,
            onConflict: { _ -> ()? in nil },
            where: [],
            doUpdate: updates,
            where: updateFilter(Self.columns)
        )
    }

    public static func insert<V1: _TableColumnExpression>(
        _ columns: (TableColumns) -> V1,
        select selection: () -> some PartialSelectStatement<V1.Value>,
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        _insert(
            columns,
            select: selection,
            onConflict: { _ -> ()? in nil },
            where: [],
            doUpdate: updates,
            where: updateFilter(Self.columns)
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        select selection: () -> some PartialSelectStatement<(V1.Value, repeat (each V2).Value)>,
        onConflictDoUpdate updates: ((inout Updates<Self>) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            select: selection,
            onConflictDoUpdate: updates.map { updates in { row, _ in updates(&row) } },
            where: updateFilter
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        select selection: () -> some PartialSelectStatement<(V1.Value, repeat (each V2).Value)>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        withoutActuallyEscaping(updates) { updates in
            _insert(
                columns,
                select: selection,
                onConflict: conflictTargets,
                where: targetFilter(Self.columns),
                doUpdate: updates,
                where: updateFilter(Self.columns)
            )
        }
    }

    public static func insert<
        V1: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> V1,
        select selection: () -> some PartialSelectStatement<V1.Value>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        withoutActuallyEscaping(updates) { updates in
            _insert(
                columns,
                select: selection,
                onConflict: conflictTargets,
                where: targetFilter(Self.columns),
                doUpdate: updates,
                where: updateFilter(Self.columns)
            )
        }
    }

    public static func insert<
        V1: _TableColumnExpression,
        each V2: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (V1, repeat each V2),
        select selection: () -> some PartialSelectStatement<(V1.Value, repeat (each V2).Value)>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>) -> Void,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            select: selection,
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: { row, _ in updates(&row) },
            where: updateFilter
        )
    }

    public static func insert<
        V1: _TableColumnExpression,
        T1: _TableColumnExpression,
        each T2: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> V1,
        select selection: () -> some PartialSelectStatement<V1.Value>,
        onConflict conflictTargets: (TableColumns) -> (T1, repeat each T2),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>) -> Void,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            select: selection,
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: { row, _ in updates(&row) },
            where: updateFilter
        )
    }

    private static func _insert<
        each Value: _TableColumnExpression,
        each ConflictTarget: _TableColumnExpression
    >(
        _ columns: (TableColumns) -> (repeat each Value),
        select selection: () -> some PartialSelectStatement<(repeat (each Value).Value)>,
        onConflict conflictTargets: (TableColumns) -> (repeat each ConflictTarget)?,
        where targetFilter: [QueryFragment] = [],
        doUpdate updates: ((inout Updates<Self>, Excluded) -> Void)?,
        where updateFilter: [QueryFragment] = []
    ) -> InsertOf<Self> {
        var columnNames: [String] = []
        for column in repeat each columns(Self.columns) {
            columnNames.append(contentsOf: column._names)
        }
        return _insert(
            columnNames: columnNames,
            values: .select(selection().query),
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: updates,
            where: updateFilter
        )
    }

    public static func insert() -> InsertOf<Self> {
        _insert(
            columnNames: [],
            values: .default,
            onConflict: { _ -> ()? in nil },
            where: [],
            doUpdate: nil,
            where: []
        )
    }

    public static func _insert<each ConflictTarget: _TableColumnExpression>(
        columnNames: [String],
        values: InsertValues,
        onConflict conflictTargets: (TableColumns) -> (repeat each ConflictTarget)?,
        where targetFilter: [QueryFragment] = [],
        doUpdate updates: ((inout Updates<Self>, Excluded) -> Void)?,
        where updateFilter: [QueryFragment] = []
    ) -> InsertOf<Self> {
        var conflictTargetColumnNames: [String] = []
        if let conflictTargets = conflictTargets(Self.columns) {
            for column in repeat each conflictTargets {
                conflictTargetColumnNames.append(contentsOf: column._names)
            }
        }
        return Insert(
            columnNames: columnNames,
            conflictTargetColumnNames: conflictTargetColumnNames,
            conflictTargetFilter: targetFilter,
            values: values,
            updates: updates.map { updates in Updates { updates(&$0, Excluded.QueryValue.columns) }
            },
            updateFilter: updateFilter,
            returning: []
        )
    }
}
