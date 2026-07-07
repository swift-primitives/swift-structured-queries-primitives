import Structured_Queries_Primitives_Support

/// A collating sequence name.
///
/// Values of this type are supplied to ``QueryExpression/collate(_:)`` to describe how a string
/// should be compared in a query.
public struct Collation: QueryExpression, Sendable {
    /// The query value type for this expression, which never produces a result.
    public typealias QueryValue = Never

    /// Initializes a collating sequence name from a query fragment.
    ///
    /// ```swift
    /// extension Collation {
    ///   static let fr_FR = Self(rawValue: "fr_FR")
    /// }
    ///
    /// Reminder.order { $0.title.collate(.fr_FR)  }
    /// // SELECT … FROM "reminders"
    /// // ORDER BY "reminders"."title" COLLATE "fr_FR"
    /// ```
    ///
    /// - Parameter rawValue: A query fragment of the sequence name.
    public init(rawValue: String) {
        self.queryFragment = "\(quote: rawValue)"
    }

    /// The quoted SQL fragment naming this collating sequence.
    public let queryFragment: QueryFragment
}
