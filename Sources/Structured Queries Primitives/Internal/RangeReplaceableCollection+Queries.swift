extension RangeReplaceableCollection {
    /// Creates a collection of query fragments from the given query expressions.
    public init<each Q: QueryExpression>(_ elements: repeat each Q)
    where Element == QueryFragment {
        self.init()
        for element in repeat each elements {
            append(element.queryFragment)
        }
    }

    /// Creates a collection of type-erased query expressions from the given expressions.
    public init<each Q: QueryExpression>(_ elements: repeat each Q)
    where Element == any QueryExpression {
        self.init()
        for element in repeat each elements {
            append(element)
        }
    }

    /// Returns a copy of this collection with duplicate elements removed.
    public func removingDuplicates() -> Self where Element: Hashable {
        var set: Set<Element> = []
        return filter { set.insert($0).inserted }
    }
}
