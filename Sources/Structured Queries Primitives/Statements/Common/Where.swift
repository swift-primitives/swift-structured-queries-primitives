/// A `WHERE` clause used to apply a filter to a statement.
///
/// See ``Table/where(_:)`` for how to create this type.
@dynamicMemberLookup
public struct Where<From: Table>: Sendable {
    /// Combines two `WHERE` clauses, merging their predicates and removing duplicates.
    public static func + (lhs: Self, rhs: Self) -> Self {
        Where(predicates: (lhs.predicates + rhs.predicates).removingDuplicates())
    }

    var predicates: [QueryFragment] = []
    var scope = Scope.default

    /// Creates a `WHERE` clause from the given predicates and scope.
    public init(
        predicates: [QueryFragment] = [],
        scope: Scope = Scope.default
    ) {
        self.predicates = predicates
        self.scope = scope
    }

    /// Looks up a static `WHERE` clause declared on the table type.
    public static subscript(dynamicMember keyPath: KeyPath<From.Type, Self>) -> Self {
        From.self[keyPath: keyPath]
    }

    /// Combines this clause with a `SELECT` statement looked up by key path.
    public subscript<each C: QueryRepresentable, each J: Table>(
        dynamicMember keyPath: KeyPath<From.Type, Select<(repeat each C), From, (repeat each J)>>
    ) -> Select<(repeat each C), From, (repeat each J)> {
        self + From.self[keyPath: keyPath]
    }

    /// Combines this clause with another `WHERE` clause looked up by key path.
    public subscript(dynamicMember keyPath: KeyPath<From.Type, Self>) -> Self {
        self + From.self[keyPath: keyPath]
    }

    /// Combines this clause with a `WHERE` clause looked up on the draft's primary table.
    public subscript(
        dynamicMember keyPath: KeyPath<From.PrimaryTable.Type, Where<From.PrimaryTable>>
    ) -> Self
    where From: TableDraft {
        self + unsafeBitCast(From.PrimaryTable.self[keyPath: keyPath], to: Self.self)
    }
}

extension Where: SelectStatement {
    /// The query value type for a `WHERE` clause used as a statement.
    public typealias QueryValue = ()

    /// Converts this `WHERE` clause into an equivalent `SELECT` statement.
    public func asSelect() -> SelectOf<From> {
        let select: SelectOf<From>
        switch scope {
        case .default:
            select = Select(clauses: From.all._selectClauses)
        case .empty:
            select = Select(isEmpty: true, where: predicates)
        case .unscoped:
            select = Select()
        }
        return select.and(self)
    }

    /// The select clauses produced by this `WHERE` clause's predicates.
    public var _selectClauses: _SelectClauses {
        _SelectClauses(isEmpty: scope == .empty, where: predicates)
    }

    /// The query fragment for this `WHERE` clause, expressed as a full `SELECT` statement.
    public var query: QueryFragment {
        asSelect().query
    }
}
