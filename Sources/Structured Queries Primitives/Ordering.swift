extension QueryExpression where QueryValue: QueryBindable {
    /// This expression with an ascending ordering term.
    ///
    /// - Parameter nullOrdering: `NULL`-specific ordering.
    /// - Returns: An ascending ordering of this expression.
    public func asc(nulls nullOrdering: NullOrdering? = nil) -> some QueryExpression {
        OrderingTerm(base: self, direction: .asc, nullOrdering: nullOrdering)
    }

    /// This expression with an descending ordering term.
    ///
    /// - Parameter nullOrdering: `NULL`-specific ordering.
    /// - Returns: A descending ordering of this expression.
    public func desc(nulls nullOrdering: NullOrdering? = nil) -> some QueryExpression {
        OrderingTerm(base: self, direction: .desc, nullOrdering: nullOrdering)
    }
}

/// `NULL`-specific ordering for an ordering term.
public struct NullOrdering: RawRepresentable, Sendable {
    /// The raw SQL keyword for this null ordering.
    public let rawValue: QueryFragment

    /// Creates a null ordering from the given raw SQL keyword.
    public init(rawValue: QueryFragment) {
        self.rawValue = rawValue
    }
}

extension NullOrdering {
    /// A null ordering of `NULLS FIRST`.
    public static let first = Self(rawValue: "FIRST")

    /// A null ordering of `NULLS LAST`.
    public static let last = Self(rawValue: "LAST")
}

private struct OrderingTerm: QueryExpression {
    let base: QueryFragment
    let direction: Direction
    let nullOrdering: NullOrdering?

    init(base: some QueryExpression, direction: Direction, nullOrdering: NullOrdering?) {
        self.base = base.queryFragment
        self.direction = direction
        self.nullOrdering = nullOrdering
    }
}

extension OrderingTerm {
    typealias QueryValue = Never

    struct Direction {
        let queryFragment: QueryFragment
    }

    var queryFragment: QueryFragment {
        var query: QueryFragment = "\(base) \(direction.queryFragment)"
        if let nullOrdering {
            query.append(" NULLS \(nullOrdering.rawValue)")
        }
        return query
    }
}

extension OrderingTerm.Direction {
    fileprivate static let asc = Self(queryFragment: "ASC")
    fileprivate static let desc = Self(queryFragment: "DESC")
}
