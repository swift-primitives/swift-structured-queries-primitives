extension QueryFragment {
    /// A newline separator inserted between query clauses.
    @inlinable
    @inline(__always)
    public static var newlineOrSpace: Self {
        "\n"
    }

    /// A newline character appended within a query fragment.
    @inlinable
    @inline(__always)
    public static var newline: Self {
        "\n"
    }

    /// Returns a copy of this fragment indented by two spaces on every line.
    public func indented() -> Self {
        var query = self
        query.segments.insert(.sql("  "), at: 0)
        for index in query.segments.indices {
            switch query.segments[index] {
            case .sql(let sql):
                query.segments[index] = .sql(sql.replacing("\n", with: "\n  "))
            case .binding:
                continue
            }
        }
        return query
    }
}
