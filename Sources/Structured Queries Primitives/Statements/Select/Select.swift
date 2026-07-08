import Structured_Queries_Primitives_Support

/// A `SELECT` statement.
///
/// This type of statement is constructed from ``Table/all`` and static aliases to methods on the
/// `Select` type, like `select`, `join`, `group(by:)`, `order(by:)`, and more.
///
/// To learn more, see <doc:SelectStatements>.
@dynamicMemberLookup
public struct Select<Columns, From: Table, Joins>: Sendable {
    // NB: A parameter pack compiler crash forces us to heap-allocate this storage.
    @CopyOnWrite var clauses = _SelectClauses()

    var isEmpty: Bool {
        get { clauses.isEmpty }
        set { clauses.isEmpty = newValue }
        _modify { yield &clauses.isEmpty }
    }
    var distinct: _DistinctClause? {
        get { clauses.distinct }
        set { clauses.distinct = newValue }
        _modify { yield &clauses.distinct }
    }
    var columns: [QueryFragment] {
        get { clauses.columns }
        set { clauses.columns = newValue }
        _modify { yield &clauses.columns }
    }
    var joins: [_JoinClause] {
        get { clauses.joins }
        set { clauses.joins = newValue }
        _modify { yield &clauses.joins }
    }
    var `where`: [QueryFragment] {
        get { clauses.where }
        set { clauses.where = newValue }
        _modify { yield &clauses.where }
    }
    var group: [QueryFragment] {
        get { clauses.group }
        set { clauses.group = newValue }
        _modify { yield &clauses.group }
    }
    var having: [QueryFragment] {
        get { clauses.having }
        set { clauses.having = newValue }
        _modify { yield &clauses.having }
    }
    var order: [QueryFragment] {
        get { clauses.order }
        set { clauses.order = newValue }
        _modify { yield &clauses.order }
    }
    var windows: [(name: String, specification: QueryFragment)] {
        get { clauses.windows }
        set { clauses.windows = newValue }
        _modify { yield &clauses.windows }
    }
    var limit: _LimitClause? {
        get { clauses.limit }
        set { clauses.limit = newValue }
        _modify { yield &clauses.limit }
    }

    init(
        isEmpty: Bool,
        distinct: _DistinctClause?,
        columns: [QueryFragment],
        joins: [_JoinClause],
        where: [QueryFragment],
        group: [QueryFragment],
        having: [QueryFragment],
        order: [QueryFragment],
        windows: [(name: String, specification: QueryFragment)],
        limit: _LimitClause?
    ) {
        self.isEmpty = isEmpty
        self.columns = columns
        self.distinct = distinct
        self.joins = joins
        self.where = `where`
        self.group = group
        self.having = having
        self.order = order
        self.windows = windows
        self.limit = limit
    }

    init(clauses: _SelectClauses) {
        self.clauses = clauses
    }
}

/// The set of clauses that compose a `SELECT` statement.
public struct _SelectClauses: Sendable {
    var isEmpty = false
    var distinct: _DistinctClause?
    var columns: [QueryFragment] = []
    var joins: [_JoinClause] = []
    var `where`: [QueryFragment] = []
    var group: [QueryFragment] = []
    var having: [QueryFragment] = []
    var order: [QueryFragment] = []
    var windows: [(name: String, specification: QueryFragment)] = []
    var limit: _LimitClause?
}

/// The `DISTINCT` clause of a `SELECT` statement.
public enum _DistinctClause: Sendable {
    case all
    case on([QueryFragment])
}

extension Select {
    init(isEmpty: Bool = false, where: [QueryFragment] = []) {
        self.isEmpty = isEmpty
        self.where = `where`
    }

    #if DEBUG
        // NB: This can cause 'EXC_BAD_ACCESS' when 'C2' or 'J2' contain parameters.
        // TODO: Report issue to Swift team.
        /// An unavailable dynamic-member subscript for unsupported column and join counts.
        @available(
            *,
            unavailable,
            message: """
                No overload is available for this many columns/joins. To request more overloads, please file a GitHub issue that describes your use case: https://github.com/coenttb/swift-structured-queries-postgres
                """
        )
        public subscript<
            each C1: QueryRepresentable,
            each C2: QueryRepresentable,
            each J1: Table,
            each J2: Table
        >(
            dynamicMember keyPath: KeyPath<
                From.Type, Select<(repeat each C2), From, (repeat each J2)>
            >
        ) -> Select<(repeat each C1, repeat each C2), From, (repeat each J1, repeat each J2)>
        where Columns == (repeat each C1), Joins == (repeat each J1) {
            self + From.self[keyPath: keyPath]
        }
    #endif

    /// Creates a new select statement from this one by appending the given result column to its
    /// selection.
    ///
    /// - Parameter selection: A key path to a column to select.
    /// - Returns: A new select statement that selects the given column.
    public func select<each C1: QueryRepresentable, C2: QueryExpression>(
        _ selection: KeyPath<From.TableColumns, C2>
    ) -> Select<(repeat each C1, C2.QueryValue), From, ()>
    where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == () {
        select { $0[keyPath: selection] }
    }

    // NB: This overload is required for CTEs with join clauses to avoid a compiler bug.
    /// Creates a new select statement from this one by selecting the given result column.
    ///
    /// - Parameter selection: A closure that selects a result column from this select's tables.
    /// - Returns: A new select statement that selects the given column.
    @_disfavoredOverload
    public func select<C: QueryExpression, each J: Table>(
        _ selection: ((From.TableColumns, repeat (each J).TableColumns)) -> C
    ) -> Select<C.QueryValue, From, (repeat each J)>
    where Columns == (), C.QueryValue: QueryRepresentable, Joins == (repeat each J) {
        _select(selection)
    }

    /// Creates a new select statement from this one by selecting the given result column.
    ///
    /// - Parameter selection: A closure that selects a result column from this select's tables.
    /// - Returns: A new select statement that selects the given column.
    @_disfavoredOverload
    public func select<C: QueryExpression, each J: Table>(
        _ selection: (From.TableColumns, repeat (each J).TableColumns) -> C
    ) -> Select<C.QueryValue, From, (repeat each J)>
    where Columns == (), C.QueryValue: QueryRepresentable, Joins == (repeat each J) {
        _select(selection)
    }

    /// Creates a new select statement from this one by appending the given result column to its
    /// selection.
    ///
    /// - Parameter selection: A closure that selects a result column from this select's table.
    /// - Returns: A new select statement that selects the given column.
    public func select<each C1: QueryRepresentable, C2: QueryExpression>(
        _ selection: (From.TableColumns) -> C2
    ) -> Select<(repeat each C1, C2.QueryValue), From, ()>
    where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == () {
        _select(selection)
    }

    /// Creates a new select statement from this one by appending the given result column to its
    /// selection.
    ///
    /// - Parameter selection: A closure that selects a result column from this select's tables.
    /// - Returns: A new select statement that selects the given column.
    public func select<each C1: QueryRepresentable, C2: QueryExpression, each J: Table>(
        _ selection: ((From.TableColumns, repeat (each J).TableColumns)) -> C2
    ) -> Select<(repeat each C1, C2.QueryValue), From, (repeat each J)>
    where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == (repeat each J) {
        _select(selection)
    }

    /// Creates a new select statement from this one by appending the given result column to its
    /// selection.
    ///
    /// - Parameter selection: A closure that selects a result column from this select's tables.
    /// - Returns: A new select statement that selects the given column.
    @_disfavoredOverload
    public func select<each C1: QueryRepresentable, C2: QueryExpression, each J: Table>(
        _ selection: (From.TableColumns, repeat (each J).TableColumns) -> C2
    ) -> Select<(repeat each C1, C2.QueryValue), From, (repeat each J)>
    where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == (repeat each J) {
        _select(selection)
    }

    /// Creates a new select statement from this one by appending the given result columns to its
    /// selection.
    ///
    /// - Parameter selection: A closure that selects columns from this select's tables.
    /// - Returns: A new select statement that selects the given columns.
    public func select<
        each C1: QueryRepresentable,
        C2: QueryExpression,
        C3: QueryExpression,
        each C4: QueryExpression,
        each J: Table
    >(
        _ selection: ((From.TableColumns, repeat (each J).TableColumns)) -> (C2, C3, repeat each C4)
    ) -> Select<
        (repeat each C1, C2.QueryValue, C3.QueryValue, repeat (each C4).QueryValue),
        From,
        (repeat each J)
    >
    where
        Columns == (repeat each C1),
        C2.QueryValue: QueryRepresentable,
        C3.QueryValue: QueryRepresentable,
        repeat (each C4).QueryValue: QueryRepresentable,
        Joins == (repeat each J)
    {
        _select(selection)
    }

    /// Creates a new select statement from this one by appending the given result columns to its
    /// selection.
    ///
    /// - Parameter selection: A closure that selects columns from this select's tables.
    /// - Returns: A new select statement that selects the given columns.
    @_disfavoredOverload
    public func select<
        each C1: QueryRepresentable,
        C2: QueryExpression,
        C3: QueryExpression,
        each C4: QueryExpression,
        each J: Table
    >(
        _ selection: (From.TableColumns, repeat (each J).TableColumns) -> (C2, C3, repeat each C4)
    ) -> Select<
        (repeat each C1, C2.QueryValue, C3.QueryValue, repeat (each C4).QueryValue),
        From,
        (repeat each J)
    >
    where
        Columns == (repeat each C1),
        C2.QueryValue: QueryRepresentable,
        C3.QueryValue: QueryRepresentable,
        repeat (each C4).QueryValue: QueryRepresentable,
        Joins == (repeat each J)
    {
        _select(selection)
    }

    private func _select<
        each C1: QueryRepresentable,
        each C2: QueryExpression,
        each J: Table
    >(
        _ selection: ((From.TableColumns, repeat (each J).TableColumns)) -> (repeat each C2)
    ) -> Select<(repeat each C1, repeat (each C2).QueryValue), From, (repeat each J)>
    where
        Columns == (repeat each C1),
        repeat (each C2).QueryValue: QueryRepresentable,
        Joins == (repeat each J)
    {
        Select<(repeat each C1, repeat (each C2).QueryValue), From, (repeat each J)>(
            isEmpty: isEmpty,
            distinct: distinct,
            columns: columns
                + $_isSelecting.withValue(true) {
                    Array(repeat each selection((From.columns, repeat (each J).columns)))
                },
            joins: joins,
            where: `where`,
            group: group,
            having: having,
            order: order,
            windows: windows,
            limit: limit
        )
    }
}

/// Combines two select statements of the same table type together.
///
/// This operator combines two select statements of the same table type together by combining
/// each of their clauses together.
///
/// - Parameters:
///   - lhs: A select statement.
///   - rhs: Another select statement of the same table type.
/// - Returns: A new select statement combining the clauses of each select statement.
public func + <
    each C1: QueryRepresentable,
    each C2: QueryRepresentable,
    From: Table,
    each J1: Table,
    each J2: Table
>(
    lhs: some SelectStatement<(repeat each C1), From, (repeat each J1)>,
    rhs: some SelectStatement<(repeat each C2), From, (repeat each J2)>
) -> Select<
    (repeat each C1, repeat each C2), From, (repeat each J1, repeat each J2)
> {
    let lhs = lhs.asSelect()
    let rhs = rhs.asSelect()
    return Select<
        (repeat each C1, repeat each C2), From, (repeat each J1, repeat each J2)
    >(
        isEmpty: lhs.isEmpty || rhs.isEmpty,
        distinct: rhs.distinct ?? lhs.distinct,
        columns: lhs.columns + rhs.columns,
        joins: lhs.joins + rhs.joins,
        where: (lhs.where + rhs.where).removingDuplicates(),
        group: (lhs.group + rhs.group).removingDuplicates(),
        having: (lhs.having + rhs.having).removingDuplicates(),
        order: (lhs.order + rhs.order).removingDuplicates(),
        windows: {
            var seen = Set<String>()
            return (lhs.windows + rhs.windows).filter { seen.insert($0.name).inserted }
        }(),
        limit: rhs.limit ?? lhs.limit
    )
}

extension Select: SelectStatement {
    /// The query value type of a select statement, equal to its selected columns.
    public typealias QueryValue = Columns

    /// The underlying clauses that compose this select statement.
    public var _selectClauses: _SelectClauses {
        clauses
    }

    /// The complete `SELECT` query fragment assembled from this statement's clauses.
    public var query: QueryFragment {
        guard !isEmpty else { return "" }
        var query: QueryFragment = "SELECT"
        let columns =
            columns.isEmpty
            ? [From.columns.queryFragment] + joins.map { $0.tableColumns }
            : columns
        if let distinct {
            switch distinct {
            case .all:
                query.append(" DISTINCT")
            case .on(let expressions):
                query.append(" DISTINCT ON (\(expressions.joined(separator: ", ")))")
            }
        }
        query.append(" \(columns.joined(separator: ", "))")
        query.append("\(.newlineOrSpace)FROM ")
        if let schemaName = From.schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append("\(quote: From.tableName)")
        if let tableAlias = From.tableAlias {
            query.append(" AS \(quote: tableAlias)")
        }
        for join in joins {
            query.append("\(.newlineOrSpace)\(join)")
        }
        if !`where`.isEmpty {
            query.append("\(.newlineOrSpace)WHERE \(`where`.joined(separator: " AND "))")
        }
        if !group.isEmpty {
            query.append("\(.newlineOrSpace)GROUP BY \(group.joined(separator: ", "))")
        }
        if !having.isEmpty {
            query.append("\(.newlineOrSpace)HAVING \(having.joined(separator: " AND "))")
        }
        if !windows.isEmpty {
            query.append("\(.newlineOrSpace)WINDOW ")
            let windowClauses = windows.map { (name, spec) in
                let fragment: QueryFragment = "\(raw: name) AS (\(spec))"
                return fragment
            }
            query.append(windowClauses.joined(separator: ", "))
        }
        if !order.isEmpty {
            query.append("\(.newlineOrSpace)ORDER BY \(order.joined(separator: ", "))")
        }
        if let limit {
            query.append("\(.newlineOrSpace)\(limit)")
        }
        return query
    }
}

/// A select statement over the given table and joins with no columns selected yet.
public typealias SelectOf<From: Table, each Join: Table> =
    Select<(), From, (repeat each Join)>

/// A single `JOIN` clause within a `SELECT` statement.
public struct _JoinClause: QueryExpression, Sendable {
    let constraint: QueryFragment
    let `operator`: QueryFragment?
    let schemaName: String?
    let tableAlias: String?
    let tableColumns: QueryFragment
    let tableName: String

    init(
        operator: Operator?,
        table: any Table.Type,
        constraint: some QueryExpression<Bool>
    ) {
        self.constraint = constraint.queryFragment
        self.operator = `operator`?.queryFragment
        schemaName = table.schemaName
        tableAlias = table.tableAlias
        tableColumns = table.columns.queryFragment
        tableName = table.tableName
    }
}

extension _JoinClause {
    /// The query value type of a join clause, which produces no value.
    public typealias QueryValue = Never

    struct Operator {
        let queryFragment: QueryFragment
    }

    /// The SQL fragment representing this join clause.
    public var queryFragment: QueryFragment {
        var query: QueryFragment = ""
        if let `operator` {
            query.append("\(`operator`) ")
        }
        query.append("JOIN ")
        if let schemaName {
            query.append("\(quote: schemaName).")
        }
        query.append("\(quote: tableName) ")
        if let tableAlias = tableAlias {
            query.append("AS \(quote: tableAlias) ")
        }
        query.append("ON \(constraint)")
        return query
    }
}

extension _JoinClause.Operator {
    static let full = Self(queryFragment: "FULL OUTER")
    static let inner = Self(queryFragment: "INNER")
    static let left = Self(queryFragment: "LEFT OUTER")
    static let right = Self(queryFragment: "RIGHT OUTER")
}

/// A `LIMIT` clause within a `SELECT` statement, optionally including an `OFFSET`.
public struct _LimitClause: QueryExpression, Sendable {
    let maxLength: QueryFragment
    let offset: QueryFragment?
}

extension _LimitClause {
    /// The query value type of a limit clause, which produces no value.
    public typealias QueryValue = Never

    /// The SQL fragment representing this limit clause.
    public var queryFragment: QueryFragment {
        var query: QueryFragment = "LIMIT \(maxLength)"
        if let offset {
            query.append(" OFFSET \(offset)")
        }
        return query
    }
}

@propertyWrapper
private struct CopyOnWrite<Value> {
    final class Storage {
        var value: Value
        init(value: Value) {
            self.value = value
        }
    }
    var storage: Storage
    init(wrappedValue: Value) {
        self.storage = Storage(value: wrappedValue)
    }
    var wrappedValue: Value {
        get { storage.value }
        set {
            if isKnownUniquelyReferenced(&storage) {
                storage.value = newValue
            } else {
                storage = Storage(value: newValue)
            }
        }
    }
}

extension CopyOnWrite: Sendable where Value: Sendable {}

// WHY: Category D — structural Sendable workaround (SP-6/SP-7).
// WHY: CoW storage class. No synchronization; CoW discipline via
// WHY: isKnownUniquelyReferenced at the call site.
// WHEN TO REMOVE: When compiler gains structural inference through class storage.
// TRACKING: unsafe-audit-findings.md Category D SP-6.
extension CopyOnWrite.Storage: @unchecked Sendable where Value: Sendable {}

/// A task-local flag indicating whether column expressions are being evaluated for selection.
@TaskLocal public var _isSelecting = false
