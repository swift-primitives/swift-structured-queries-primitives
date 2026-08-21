extension QueryExpression where QueryValue: QueryBindable {

    public func asc(nulls nullOrdering: NullOrdering? = nil) -> some QueryExpression {
        OrderingTerm(base: self, direction: .asc, nullOrdering: nullOrdering)
    }

    public func desc(nulls nullOrdering: NullOrdering? = nil) -> some QueryExpression {
        OrderingTerm(base: self, direction: .desc, nullOrdering: nullOrdering)
    }
}

public struct NullOrdering: RawRepresentable, Sendable {

    public let rawValue: QueryFragment

    public init(rawValue: QueryFragment) {
        self.rawValue = rawValue
    }
}

extension NullOrdering {

    public static let first = Self(rawValue: "FIRST")

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
