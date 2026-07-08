extension Never: Table {
    /// The column definition type used when `Never` conforms to `Table`, always empty.
    public struct TableColumns: TableDefinition {
    }

    /// The selection type used when `Never` participates in a query, always empty.
    public struct Selection: TableExpression {
    }

    /// The empty column definition set for `Never`, satisfying `Table` conformance.
    public static var columns: TableColumns {
        TableColumns()
    }

    /// The table name used to satisfy `Table` conformance for the uninhabited `Never` type.
    public static let tableName = "nevers"

    /// Unreachable initializer; decoding a `Never` value always throws.
    public init(decoder: inout some QueryDecoder) throws {
        throw NotDecodable()
    }

    private struct NotDecodable: Swift.Error {}
}

extension Never.TableColumns {
    /// The query value type of these table columns, which is `Never` itself.
    public typealias QueryValue = Never

    /// An empty column list, since `Never` has no columns.
    public static var allColumns: [any TableColumnExpression] { [] }

    /// An empty column list, since `Never` has no writable columns.
    public static var writableColumns: [any WritableTableColumnExpression] { [] }
}

extension Never.Selection {
    /// The query value type of this selection, which is `Never` itself.
    public typealias QueryValue = Never

    /// An empty column list, since `Never` has no values to select.
    public var allColumns: [any QueryExpression] { [] }
}
