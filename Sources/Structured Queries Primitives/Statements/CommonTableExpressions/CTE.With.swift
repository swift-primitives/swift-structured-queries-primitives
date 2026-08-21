extension CTE {

    public struct With<Base: Statement>: Statement, Sendable {

        public typealias QueryValue = Base.QueryValue

        public typealias From = Never

        var ctes: [Clause]
        var statement: QueryFragment
        let recursive: Bool?

        @_disfavoredOverload
        public init(
            recursive: Bool? = nil,
            @Builder _ ctes: () -> [Clause],
            query statement: () -> Base
        ) {
            self.recursive = recursive
            self.ctes = ctes()
            self.statement = statement().query
        }

        public init<S: SelectStatement, each J: Table>(
            recursive: Bool? = nil,
            @Builder _ ctes: () -> [Clause],
            query statement: () -> S
        )
        where
            S.QueryValue == (),
            S.Joins == (repeat each J),
            Base == Select<(S.From, repeat each J), S.From, (repeat each J)>
        {
            self.recursive = recursive
            self.ctes = ctes()
            self.statement = statement().query
        }

        @_disfavoredOverload
        public init<S: SelectStatement>(
            recursive: Bool? = nil,
            @Builder _ ctes: () -> [Clause],
            query statement: () -> S
        )
        where
            S.QueryValue == (),
            S.Joins == (),
            Base == Select<S.From, S.From, ()>
        {
            self.recursive = recursive
            self.ctes = ctes()
            self.statement = statement().query
        }

        public var query: QueryFragment {
            guard !statement.isEmpty else { return "" }
            let cteFragments = ctes.compactMap(\.queryFragment.presence)
            guard !cteFragments.isEmpty else { return "" }

            var query: QueryFragment = "WITH"

            if isRecursive {
                query.append(" RECURSIVE")
            }

            query.append(" \(cteFragments.joined(separator: ", "))\(.newlineOrSpace)\(statement)")
            return query
        }

        private var isRecursive: Bool {

            if let recursive {
                return recursive
            }

            return ctes.contains { cte in
                cte.isRecursive
            }
        }
    }
}

extension CTE.With: PartialSelectStatement where Base: PartialSelectStatement {}

extension QueryFragment {
    fileprivate var presence: Self? { isEmpty ? nil : self }
}
