public import Structured_Queries_Primitives_Support

public struct QueryFragment: Hashable, Sendable {

    public internal(set) var segments: [Segment] = []

    fileprivate init(segments: [Segment]) {
        self.segments = segments
    }

    init(_ string: String = "") {
        self.init(segments: [.sql(string)])
    }
}

extension QueryFragment {

    public enum Segment: Hashable, Sendable {

        case sql(String)

        case binding(QueryBinding)
    }

    public var isEmpty: Bool {
        segments.allSatisfy {
            switch $0 {
            case .sql(let sql):
                sql.isEmpty

            case .binding:
                false
            }
        }
    }

    public mutating func append(_ other: Self) {
        segments.append(contentsOf: other.segments)
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs.append(rhs)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        var query = lhs
        query += rhs
        return query
    }

    public func prepare(
        _ template: (_ offset: Int) -> String
    ) -> (sql: String, bindings: [QueryBinding]) {
        var sql = ""
        var bindings: [QueryBinding] = []
        var offset = 1
        for segment in segments {
            switch segment {
            case .sql(let fragment):
                sql.append(fragment)

            case .binding(let binding):
                defer { offset += 1 }
                sql.append(template(offset))
                bindings.append(binding)
            }
        }
        return (sql, bindings)
    }
}

extension QueryFragment: CustomDebugStringConvertible {

    public var debugDescription: String {
        segments.reduce(into: "") { debugDescription, segment in
            switch segment {
            case .sql(let sql):
                debugDescription.append(sql)

            case .binding(let binding):
                debugDescription.append(binding.debugDescription)
            }
        }
    }
}

extension [QueryFragment] {

    public func joined(separator: QueryFragment = "") -> QueryFragment {
        guard var joined = first else { return QueryFragment() }
        for fragment in dropFirst() {
            joined.append(separator)
            joined.append(fragment)
        }
        return joined
    }
}

extension QueryFragment: ExpressibleByStringInterpolation {

    public init(stringInterpolation: StringInterpolation) {
        self.init(segments: stringInterpolation.segments)
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(
        quote sql: String,
        delimiter: QuoteDelimiter = .identifier
    ) {
        self.init(sql.quoted(delimiter))
    }

    public struct StringInterpolation: StringInterpolationProtocol {
        fileprivate var segments: [Segment] = []

        public init(literalCapacity: Int, interpolationCount: Int) {
            segments.reserveCapacity(interpolationCount)
        }
    }
}

extension QueryFragment.StringInterpolation {

    public mutating func appendLiteral(_ literal: String) {
        guard !literal.isEmpty else { return }
        segments.append(.sql(literal))
    }

    public mutating func appendInterpolation(
        quote sql: String,
        delimiter: QuoteDelimiter = .identifier
    ) {
        segments.append(.sql(sql.quoted(delimiter)))
    }

    public mutating func appendInterpolation(raw sql: String) {
        appendLiteral(sql)
    }

    public mutating func appendInterpolation(raw sql: some LosslessStringConvertible) {
        appendLiteral(sql.description)
    }

    public mutating func appendInterpolation(_ binding: QueryBinding) {
        segments.append(.binding(binding))
    }

    public mutating func appendInterpolation<QueryValue: QueryBindable>(
        _ queryOutput: QueryValue.QueryOutput,
        as representableType: QueryValue.Type
    ) {
        appendInterpolation(QueryValue(queryOutput: queryOutput))
    }

    public mutating func appendInterpolation(_ fragment: QueryFragment) {
        segments.append(contentsOf: fragment.segments)
    }

    public mutating func appendInterpolation(bind expression: some QueryExpression) {
        appendInterpolation(expression.queryFragment)
    }

    public mutating func appendInterpolation(_ expression: some QueryExpression) {
        appendInterpolation(expression.queryFragment)
    }

    public mutating func appendInterpolation(_ statement: some PartialSelectStatement) {
        appendInterpolation(statement.query)
    }

    public mutating func appendInterpolation<T: Table>(_ table: T.Type) {
        if let schemaName = table.schemaName {
            appendInterpolation(quote: schemaName)
            appendLiteral(".")
        }

        let aliasOrTableName = table.tableAlias ?? table.tableName
        if let shouldQuote = (T.self as? any _TableAliasQuoteInfo.Type)?.shouldQuoteAlias,
            !shouldQuote
        {

            appendLiteral(aliasOrTableName)
        } else {

            appendInterpolation(quote: aliasOrTableName)
        }
    }

    @available(
        *,
        deprecated,
        renamed: "appendInterpolation(bind:)",
        message: """
            String interpolation produces a bind for a string value; did you mean to make this explicit? To append raw SQL, use "\\(raw: sqlString)".
            """
    )
    public mutating func appendInterpolation(_ expression: String) {
        appendInterpolation(bind: expression)
    }
}
