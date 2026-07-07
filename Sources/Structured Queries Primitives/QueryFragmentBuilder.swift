/// A builder of query fragments.
///
/// This result builder is used by various query building methods, like ``Select/order(by:)`` and
/// ``Select/where(_:)-5pthx``, to conditionally introduce query fragments to a query.
@resultBuilder
public enum QueryFragmentBuilder<Clause> {
    /// Builds a query fragment block from the given component.
    public static func buildBlock(_ component: [QueryFragment]) -> [QueryFragment] {
        component
    }

    /// Builds a query fragment block from the first branch of a conditional.
    public static func buildEither(first component: [QueryFragment]) -> [QueryFragment] {
        component
    }

    /// Builds a query fragment block from the second branch of a conditional.
    public static func buildEither(second component: [QueryFragment]) -> [QueryFragment] {
        component
    }

    // swiftlint:disable:next discouraged_optional_collection
    /// Builds a query fragment block from an optional component.
    public static func buildOptional(_ component: [QueryFragment]?) -> [QueryFragment] {
        component ?? []
    }
}

extension QueryFragmentBuilder<Bool> {
    /// Builds a query fragment block from an array of components joined with AND.
    public static func buildArray(_ components: [[QueryFragment]]) -> [QueryFragment] {
        components.map { $0.joined(separator: " AND ") }
    }

    /// Builds a query fragment from a Boolean expression.
    public static func buildExpression(
        _ expression: some QueryExpression<Bool>
    ) -> [QueryFragment] {
        [expression.queryFragment]
    }

    /// Builds a query fragment from an optional Boolean expression.
    public static func buildExpression(
        _ expression: some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> [QueryFragment] {
        [expression.queryFragment]
    }
}

extension QueryFragmentBuilder<()> {
    /// Builds query fragments from a tuple of expressions.
    public static func buildExpression<each C: QueryExpression>(
        _ expression: (repeat each C)
    ) -> [QueryFragment] {
        Array(repeat each expression)
    }
}

extension QueryFragmentBuilder<any Statement> {
    /// Builds a query fragment from the given statement.
    public static func buildExpression(
        _ expression: some Statement
    ) -> [QueryFragment] {
        [expression.query]
    }

    /// Builds a query fragment block by concatenating the given components.
    public static func buildBlock(
        _ first: [QueryFragment],
        _ rest: [QueryFragment]...
    ) -> [QueryFragment] {
        first + rest.flatMap(\.self)
    }
}
