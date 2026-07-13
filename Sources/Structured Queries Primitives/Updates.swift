import Structured_Queries_Primitives_Support

/// A collection of updates used in an update clause.
///
/// A mutable value of this type is passed to the `updates` closure of `Table.update`, as well as
/// the `doUpdate` closure of `Table.insert`.
///
/// To learn more, see <doc:UpdateStatements>.
@dynamicMemberLookup
public struct Updates<Base: Table>: Sendable {
    private var updates: [(String, QueryFragment)] = []

    init(_ body: (inout Self) -> Void) {
        body(&self)
    }

    var isEmpty: Bool {
        updates.isEmpty
    }

    /// Assigns the given value to the given column.
    public mutating func set(
        _ column: some TableColumnExpression,
        _ value: QueryFragment
    ) {
        updates.append((column.name, value))
    }

    /// Accesses a column as a typed SQL expression, recording assignments on set.
    ///
    /// The primary subscript returns concrete ``SQLQueryExpression`` so that compound-assign
    /// sugar (`$0.count += 1`) and mutating members (`toggle()`, `negate()`) resolve to it
    /// deterministically, above the disfavored overloads below.
    public subscript<Value>(
        dynamicMember keyPath: KeyPath<Base.TableColumns, TableColumn<Base, Value>>
    ) -> SQLQueryExpression<Value> {
        get { SQLQueryExpression(Base.columns[keyPath: keyPath]) }
        set { updates.append((Base.columns[keyPath: keyPath].name, newValue.queryFragment)) }
    }

    /// A disfavored overload whose setter accepts any erased expression
    /// (_e.g._, `$0.count = -$0.count`).
    ///
    /// For plain-value assignment of an expression-conforming output (`$0.count = 5`,
    /// `$0.title = "Test"`) this setter ties at equal tier with the write-only
    /// `QueryOutput` subscript below. The tie is deliberate and benign: both setters
    /// append a byte-identical fragment, so resolution order is unobservable.
    @_disfavoredOverload
    public subscript<Value>(
        dynamicMember keyPath: KeyPath<Base.TableColumns, TableColumn<Base, Value>>
    ) -> any QueryExpression<Value> {
        get { Base.columns[keyPath: keyPath] }
        set { updates.append((Base.columns[keyPath: keyPath].name, newValue.queryFragment)) }
    }

    /// A write-only subscript that assigns a column's decoded output value.
    @_disfavoredOverload
    public subscript<Value: QueryExpression>(
        dynamicMember keyPath: KeyPath<
            Base.TableColumns,
            some WritableTableColumnExpression<Base, Value>
        >
    ) -> Value.QueryOutput {
        @available(*, unavailable)
        get { fatalError() }
        set {
            updates.append(
                (Base.columns[keyPath: keyPath].name, Value(queryOutput: newValue).queryFragment)
            )
        }
    }

    /// Accesses nested updates for a column group, merging assignments on set.
    public subscript<Value: QueryExpression>(
        dynamicMember keyPath: KeyPath<Base.TableColumns, ColumnGroup<Base, Value>>
    ) -> Updates<Value> {
        get { Updates<Value> { _ in } }
        set { updates.append(contentsOf: newValue.updates) }
    }

    /// A write-only subscript that assigns every writable column in a column group.
    @_disfavoredOverload
    public subscript<Value: QueryExpression>(
        dynamicMember keyPath: KeyPath<Base.TableColumns, ColumnGroup<Base, Value>>
    ) -> Value.QueryOutput {
        @available(*, unavailable)
        get { fatalError() }
        set {
            func open<Root, V>(
                _ column: some WritableTableColumnExpression<Root, V>
            ) -> QueryFragment {
                Value(queryOutput: newValue)[keyPath: column.keyPath as! KeyPath<Value, V>]
                    .queryFragment
            }
            updates.append(
                contentsOf: Value.TableColumns.writableColumns.map { column in
                    (column.name, open(column))
                }
            )
        }
    }
}

extension Updates: QueryExpression {
    /// The query value type for this expression, which never produces a result.
    public typealias QueryValue = Never

    /// The SET clause fragment listing all recorded column assignments.
    public var queryFragment: QueryFragment {
        "SET \(updates.map { "\(quote: $0) = \($1)" }.joined(separator: ", "))"
    }
}
