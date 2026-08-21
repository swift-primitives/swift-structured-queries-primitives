public struct WindowSpec: Sendable {

    public var partitions: [QueryFragment] = []

    public var orderings: [QueryFragment] = []

    public var frameClause: QueryFragment?

    public init() {}

    public init(
        partitions: [QueryFragment] = [],
        orderings: [QueryFragment] = [],
        frameClause: QueryFragment? = nil
    ) {
        self.partitions = partitions
        self.orderings = orderings
        self.frameClause = frameClause
    }
}

extension WindowSpec {

    public func partition(by expression: some QueryExpression) -> WindowSpec {
        var copy = self
        copy.partitions.append(expression.queryFragment)
        return copy
    }

    public func partition(
        @QueryFragmentBuilder<()>
        by expressions: () -> [QueryFragment]
    ) -> WindowSpec {
        var copy = self
        copy.partitions.append(contentsOf: expressions())
        return copy
    }

    public func order(
        by expression: some QueryExpression
    ) -> WindowSpec {
        var copy = self
        copy.orderings.append(expression.queryFragment)
        return copy
    }

    public func order(
        @QueryFragmentBuilder<()>
        by orderings: () -> [QueryFragment]
    ) -> WindowSpec {
        var copy = self
        copy.orderings.append(contentsOf: orderings())
        return copy
    }

    public func generateSpecificationFragment() -> QueryFragment {
        var fragment: QueryFragment = ""

        if !partitions.isEmpty {
            fragment.append("PARTITION BY ")
            fragment.append(partitions.joined(separator: ", "))
            if !orderings.isEmpty || frameClause != nil {
                fragment.append(" ")
            }
        }

        if !orderings.isEmpty {
            fragment.append("ORDER BY ")
            fragment.append(orderings.joined(separator: ", "))
            if frameClause != nil {
                fragment.append(" ")
            }
        }

        if let frameClause {
            fragment.append(frameClause)
        }

        return fragment
    }

    public func generateOverClause() -> QueryFragment {
        var fragment: QueryFragment = "OVER ("

        if !partitions.isEmpty {
            fragment.append("PARTITION BY ")
            fragment.append(partitions.joined(separator: ", "))
            if !orderings.isEmpty {
                fragment.append(" ")
            }
        }

        if !orderings.isEmpty {
            fragment.append("ORDER BY ")
            fragment.append(orderings.joined(separator: ", "))
        }

        if let frameClause {
            if !partitions.isEmpty || !orderings.isEmpty {
                fragment.append(" ")
            }
            fragment.append(frameClause)
        }

        fragment.append(")")
        return fragment
    }
}

public enum OrderDirection: Sendable {
    case asc
    case desc
}
