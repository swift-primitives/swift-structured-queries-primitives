/// A builder of insert statement values.
///
/// This result builder is used by ``Table/insert(or:_:values:onConflict:where:doUpdate:where:)`` to
/// insert any number of rows into a table.
@resultBuilder
public enum InsertValuesBuilder<Value> {
    /// Builds the value rows for an array of table values being inserted.
    public static func buildExpression(_ expression: [Value]) -> [[QueryFragment]]
    where Value: Table {
        var valueFragments: [[QueryFragment]] = []
        for value in expression {
            var valueFragment: [QueryFragment] = []
            for column in Value.TableColumns.writableColumns {
                func open<Root, Member>(
                    _ column: some WritableTableColumnExpression<Root, Member>
                ) -> QueryFragment {
                    Member(queryOutput: (value as! Root)[keyPath: column.keyPath]).queryFragment
                }
                valueFragment.append(open(column))
            }
            valueFragments.append(valueFragment)
        }
        return valueFragments
    }

    /// Builds the value rows for an array of primary-keyed table draft values being inserted.
    @_disfavoredOverload
    public static func buildExpression(_ expression: [Value.Draft]) -> [[QueryFragment]]
    where Value: PrimaryKeyedTable {
        var valueFragments: [[QueryFragment]] = []
        for value in expression {
            var valueFragment: [QueryFragment] = []
            for column in Value.Draft.TableColumns.writableColumns {
                func open<Root, Member>(
                    _ column: some WritableTableColumnExpression<Root, Member>
                ) -> QueryFragment {
                    Member(queryOutput: (value as! Root)[keyPath: column.keyPath]).queryFragment
                }
                valueFragment.append(open(column))
            }
            valueFragments.append(valueFragment)
        }
        return valueFragments
    }

    /// Builds a single value row from an array of query expressions.
    @_disfavoredOverload
    public static func buildExpression<V: QueryExpression>(
        _ expression: [V]
    ) -> [[QueryFragment]]
    where
        Value == V.QueryValue,
        V.QueryValue: QueryRepresentable & QueryBindable
    {
        [expression.map(\.queryFragment)]
    }

    /// Builds a single value row from an array of raw query output values.
    @_disfavoredOverload
    public static func buildExpression(
        _ expression: [Value.QueryOutput]
    ) -> [[QueryFragment]]
    where Value: QueryRepresentable & QueryBindable {
        [expression.map { Value(queryOutput: $0).queryFragment }]
    }

    /// Builds the value row for a single table value being inserted.
    public static func buildExpression(_ expression: Value) -> [[QueryFragment]]
    where Value: Table {
        buildExpression([expression])
    }

    /// Builds the value row for a single primary-keyed table draft value being inserted.
    public static func buildExpression(_ expression: Value.Draft) -> [[QueryFragment]]
    where Value: PrimaryKeyedTable {
        buildExpression([expression])
    }

    /// Builds the value row for a single query expression being inserted.
    @_disfavoredOverload
    public static func buildExpression<V: QueryExpression>(
        _ expression: V
    ) -> [[QueryFragment]]
    where
        Value == V.QueryValue,
        V.QueryValue: QueryRepresentable & QueryBindable
    {
        buildExpression([expression])
    }

    /// Builds the value row for a single raw query output value being inserted.
    public static func buildExpression(
        _ expression: Value.QueryOutput
    ) -> [[QueryFragment]]
    where Value: QueryRepresentable & QueryBindable {
        buildExpression([expression])
    }

    /// Builds the value row for a tuple of query expressions being inserted.
    @_disfavoredOverload
    public static func buildExpression<each V: QueryExpression>(
        _ expression: (repeat each V)
    ) -> [[QueryFragment]]
    where
        Value == (repeat (each V).QueryValue),
        repeat (each V).QueryValue: QueryRepresentable & QueryBindable
    {
        var valueFragment: [QueryFragment] = []
        for column in repeat each expression {
            valueFragment.append(column.queryFragment)
        }
        return [valueFragment]
    }

    /// Builds the value row for a tuple of raw query output values being inserted.
    public static func buildExpression<each V: QueryRepresentable & QueryBindable>(
        _ expression: (repeat (each V).QueryOutput)
    ) -> [[QueryFragment]]
    where Value == (repeat each V) {
        var valueFragment: [QueryFragment] = []
        for (columnType, column) in repeat ((each V).self, each expression) {
            valueFragment.append(columnType.init(queryOutput: column).queryFragment)
        }
        return [valueFragment]
    }

    /// Builds the value row for a table's selection of all columns.
    public static func buildExpression(
        _ expression: Value.Selection
    ) -> [[QueryFragment]]
    where Value: Table {
        [expression.allColumns.map(\.queryFragment)]
    }

    /// Flattens an array of value row arrays into a single array of value rows.
    public static func buildArray(_ components: [[[QueryFragment]]]) -> [[QueryFragment]] {
        components.flatMap(\.self)
    }

    /// Returns the value rows produced by a single result-builder block.
    public static func buildBlock(_ components: [[QueryFragment]]) -> [[QueryFragment]] {
        components
    }

    /// Returns the value rows produced by the first branch of a conditional block.
    public static func buildEither(first component: [[QueryFragment]]) -> [[QueryFragment]] {
        component
    }

    /// Returns the value rows produced by the second branch of a conditional block.
    public static func buildEither(second component: [[QueryFragment]]) -> [[QueryFragment]] {
        component
    }

    /// Returns the value rows produced by an availability-limited block.
    public static func buildLimitedAvailability(_ component: [[QueryFragment]]) -> [[QueryFragment]] {
        component
    }

    /// Returns the value rows produced by an optional block, or an empty array if `nil`.
    public static func buildOptional(_ component: [[QueryFragment]]?) -> [[QueryFragment]] {
        component ?? []
    }

    /// Returns the value rows produced by the first partial block.
    public static func buildPartialBlock(first: [[QueryFragment]]) -> [[QueryFragment]] {
        first
    }

    /// Appends the next partial block's value rows to the accumulated rows.
    public static func buildPartialBlock(
        accumulated: [[QueryFragment]],
        next: [[QueryFragment]]
    ) -> [[QueryFragment]] {
        accumulated + next
    }
}

/// An alias name representing the `excluded` row in an upsert conflict clause.
public struct _ExcludedName: AliasName {
}

extension _ExcludedName {
    /// The alias name string, `excluded`.
    public static var aliasName: String { "excluded" }
}
