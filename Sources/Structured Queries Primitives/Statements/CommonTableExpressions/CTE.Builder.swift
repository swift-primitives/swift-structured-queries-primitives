extension CTE {
    /// A builder of common table expressions.
    ///
    /// This result builder is used by ``With/init(recursive:_:query:)`` to insert
    /// any number of common table expressions into a `WITH` statement.
    @resultBuilder
    public enum Builder {
        /// Converts a select statement into a common table expression clause.
        public static func buildExpression<CTETable: Table>(
            _ expression: some PartialSelectStatement<CTETable>
        ) -> Clause {
            Clause(
                tableName: "\(CTETable.self)",
                select: expression.query,
                materialization: nil
            )
        }

        /// Builds a block containing a single common table expression clause.
        public static func buildBlock(
            _ component: Clause
        ) -> [Clause] {
            [component]
        }

        /// Builds the initial partial block from the first common table expression clause.
        public static func buildPartialBlock(
            first: Clause
        ) -> [Clause] {
            [first]
        }

        /// Appends the next clause to an accumulated block of common table expressions.
        public static func buildPartialBlock(
            accumulated: [Clause],
            next: Clause
        ) -> [Clause] {
            accumulated + [next]
        }
    }
}
