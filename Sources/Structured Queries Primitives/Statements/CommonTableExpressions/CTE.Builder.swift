extension CTE {

    @resultBuilder
    public enum Builder {

        public static func buildExpression<CTETable: Table>(
            _ expression: some PartialSelectStatement<CTETable>
        ) -> Clause {
            Clause(
                tableName: "\(CTETable.self)",
                select: expression.query,
                materialization: nil
            )
        }

        public static func buildBlock(
            _ component: Clause
        ) -> [Clause] {
            [component]
        }

        public static func buildPartialBlock(
            first: Clause
        ) -> [Clause] {
            [first]
        }

        public static func buildPartialBlock(
            accumulated: [Clause],
            next: Clause
        ) -> [Clause] {
            accumulated + [next]
        }
    }
}
