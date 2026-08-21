public enum FrameBound: Sendable {

    case unboundedPreceding

    case preceding(Int)

    case currentRow

    case following(Int)

    case unboundedFollowing
}

extension FrameBound {

    internal var queryFragment: QueryFragment {
        switch self {
        case .unboundedPreceding:
            return "UNBOUNDED PRECEDING"

        case .preceding(let offset):
            precondition(offset > 0, "PRECEDING offset must be positive, got \(offset)")
            return "\(raw: String(offset)) PRECEDING"

        case .currentRow:
            return "CURRENT ROW"

        case .following(let offset):
            precondition(offset > 0, "FOLLOWING offset must be positive, got \(offset)")
            return "\(raw: String(offset)) FOLLOWING"

        case .unboundedFollowing:
            return "UNBOUNDED FOLLOWING"
        }
    }
}

public enum FrameBounds: Sendable {

    case between(FrameBound, FrameBound)

    case start(FrameBound)
}

extension FrameBounds {

    internal func queryFragment(frameType: String) -> QueryFragment {
        switch self {
        case .between(let start, let end):
            return "\(raw: frameType) BETWEEN \(start.queryFragment) AND \(end.queryFragment)"

        case .start(let bound):

            return "\(raw: frameType) \(bound.queryFragment)"
        }
    }
}

extension WindowSpec {

    public func rows(between start: FrameBound, and end: FrameBound) -> WindowSpec {
        var copy = self
        copy.frameClause = FrameBounds.between(start, end).queryFragment(frameType: "ROWS")
        return copy
    }

    public func rows(_ bound: FrameBound) -> WindowSpec {
        var copy = self
        copy.frameClause = FrameBounds.start(bound).queryFragment(frameType: "ROWS")
        return copy
    }

    public func range(between start: FrameBound, and end: FrameBound) -> WindowSpec {
        var copy = self
        copy.frameClause = FrameBounds.between(start, end).queryFragment(frameType: "RANGE")
        return copy
    }

    public func range(_ bound: FrameBound) -> WindowSpec {
        var copy = self
        copy.frameClause = FrameBounds.start(bound).queryFragment(frameType: "RANGE")
        return copy
    }

    public func groups(between start: FrameBound, and end: FrameBound) -> WindowSpec {
        var copy = self
        copy.frameClause = FrameBounds.between(start, end).queryFragment(frameType: "GROUPS")
        return copy
    }

    public func groups(_ bound: FrameBound) -> WindowSpec {
        var copy = self
        copy.frameClause = FrameBounds.start(bound).queryFragment(frameType: "GROUPS")
        return copy
    }
}
