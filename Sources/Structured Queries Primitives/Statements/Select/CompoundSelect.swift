extension PartialSelectStatement {

    public func union(
        all: Bool = false,
        _ other: some PartialSelectStatement<QueryValue>
    ) -> some PartialSelectStatement<QueryValue> {
        CompoundSelect(lhs: self, operator: all ? .unionAll : .union, rhs: other)
    }

    public func intersect<F, J>(
        _ other: some SelectStatement<QueryValue, F, J>
    ) -> some PartialSelectStatement<QueryValue> {
        CompoundSelect(lhs: self, operator: .intersect, rhs: other)
    }

    public func except<F, J>(
        _ other: some SelectStatement<QueryValue, F, J>
    ) -> some PartialSelectStatement<QueryValue> {
        CompoundSelect(lhs: self, operator: .except, rhs: other)
    }
}

private struct CompoundSelect<QueryValue>: PartialSelectStatement {
    typealias From = Never
    typealias Joins = Never

    struct Operator {
        let queryFragment: QueryFragment
    }

    let lhs: QueryFragment
    let `operator`: QueryFragment
    let rhs: QueryFragment

    init(lhs: some PartialSelectStatement, operator: Operator, rhs: some PartialSelectStatement) {
        self.lhs = lhs.query
        self.operator = `operator`.queryFragment
        self.rhs = rhs.query
    }

    var query: QueryFragment {
        guard !lhs.isEmpty else { return rhs }
        guard !rhs.isEmpty else { return lhs }
        return "\(lhs)\(.newlineOrSpace)\(`operator`.indented())\(.newlineOrSpace)\(rhs)"
    }
}

extension CompoundSelect.Operator {
    fileprivate static var except: Self { Self(queryFragment: "EXCEPT") }
    fileprivate static var intersect: Self { Self(queryFragment: "INTERSECT") }
    fileprivate static var union: Self { Self(queryFragment: "UNION") }
    fileprivate static var unionAll: Self { Self(queryFragment: "UNION ALL") }
}
