extension Where {

    public func `where`(
        _ keyPath: KeyPath<From.TableColumns, some QueryExpression<some _OptionalPromotable<Bool?>>>
    ) -> Self {
        var `where` = self
        `where`.predicates.append(From.columns[keyPath: keyPath].queryFragment)
        return `where`
    }

    @_disfavoredOverload
    public func `where`(
        _ predicate: (From.TableColumns) -> some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> Self {
        var `where` = self
        `where`.predicates.append(predicate(From.columns).queryFragment)
        return `where`
    }

    public func `where`(
        @QueryFragmentBuilder<Bool> _ predicate: (From.TableColumns) -> [QueryFragment]
    ) -> Self {
        var `where` = self
        `where`.predicates.append(contentsOf: predicate(From.columns))
        return `where`
    }

    public static func && (lhs: Self, rhs: Self) -> Self {
        lhs.and(rhs)
    }

    public static func || (lhs: Self, rhs: Self) -> Self {
        lhs.or(rhs)
    }

    public static prefix func ! (where: Self) -> Self {
        `where`.not()
    }

    public func and(_ other: Self) -> Self {
        guard !predicates.isEmpty else { return other }
        guard !other.predicates.isEmpty else { return self }
        var `where` = self
        let combined: QueryFragment = """
            (\(`where`.predicates.joined(separator: " AND "))) \
            AND \
            (\(other.predicates.joined(separator: " AND ")))
            """
        `where`.predicates = [combined]
        return `where`
    }

    public func or(_ other: Self) -> Self {
        guard !predicates.isEmpty else { return other }
        guard !other.predicates.isEmpty else { return self }
        var `where` = self
        let combined: QueryFragment = """
            (\(`where`.predicates.joined(separator: " AND "))) \
            OR \
            (\(other.predicates.joined(separator: " AND ")))
            """
        `where`.predicates = [combined]
        return `where`
    }

    public func not() -> Self {
        var `where` = self
        `where`.predicates = [
            "NOT (\(predicates.isEmpty ? "1" : predicates.joined(separator: " AND ")))"
        ]
        return `where`
    }
}
