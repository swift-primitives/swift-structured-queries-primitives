extension QueryFragment {
    @inlinable
    @inline(__always)
    public static var newlineOrSpace: Self {
        "\n"
    }

    @inlinable
    @inline(__always)
    public static var newline: Self {
        "\n"
    }

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
