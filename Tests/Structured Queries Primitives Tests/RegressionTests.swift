import Structured_Queries_Primitives
import Synchronization
import Testing

// MARK: - Fixtures
//
// Hand-rolled `Table` conformances: the `@Table` macro lives above L1, so test
// fixtures conform manually.

struct Row: Table {
    var count: Int
    var title: String

    struct TableColumns: TableDefinition {
        typealias QueryValue = Row
        let count = TableColumn<Row, Int>("count", keyPath: \Row.count)
        let title = TableColumn<Row, String>("title", keyPath: \Row.title)
        static var allColumns: [any TableColumnExpression] {
            [Row.columns.count, Row.columns.title]
        }
        static var writableColumns: [any WritableTableColumnExpression] {
            [Row.columns.count, Row.columns.title]
        }
    }

    struct Selection: TableExpression {
        typealias QueryValue = Row
        let allColumns: [any QueryExpression]
    }

    typealias DefaultScope = Where<Row>

    static var columns: TableColumns { TableColumns() }
    static let tableName = "rows"

    init(count: Int, title: String) {
        self.count = count
        self.title = title
    }

    init(decoder: inout some QueryDecoder) throws {
        self.count = try Int(decoder: &decoder)
        self.title = try String(decoder: &decoder)
    }
}

struct Tag: Table {
    var rowID: Int

    struct TableColumns: TableDefinition {
        typealias QueryValue = Tag
        let rowID = TableColumn<Tag, Int>("rowID", keyPath: \Tag.rowID)
        static var allColumns: [any TableColumnExpression] {
            [Tag.columns.rowID]
        }
        static var writableColumns: [any WritableTableColumnExpression] {
            [Tag.columns.rowID]
        }
    }

    struct Selection: TableExpression {
        typealias QueryValue = Tag
        let allColumns: [any QueryExpression]
    }

    typealias DefaultScope = Where<Tag>

    static var columns: TableColumns { TableColumns() }
    static let tableName = "tags"

    init(rowID: Int) {
        self.rowID = rowID
    }

    init(decoder: inout some QueryDecoder) throws {
        self.rowID = try Int(decoder: &decoder)
    }
}

// MARK: - Updates subscript resolution (G-1)

@Suite
struct UpdatesSubscriptTests {
    @Test func `Primary subscript vends a typed expression and records sets`() {
        let statement = Row.update {
            $0.count = SQLQueryExpression("\($0.count) + 1", as: Int.self)
        }
        let sql = statement.query.debugDescription
        #expect(sql.contains("SET"))
        #expect(sql.contains(#""count""#))
    }

    @Test func `Plain value assignment records through the disfavored setters`() {
        let statement = Row.update {
            $0.count = 5
            $0.title = "renamed"
        }
        let sql = statement.query.debugDescription
        #expect(sql.contains("SET"))
        #expect(sql.contains(#""count""#))
        #expect(sql.contains(#""title""#))
    }
}

// MARK: - group(by:) overload resolution (G-2)

@Suite
struct GroupByResolutionTests {
    @Test func `Single-join selects resolve group(by:)`() {
        let base = Row.group(by: \.count)
            .join(Tag.all) { SQLQueryExpression("\($0.count) = \($1.rowID)", as: Bool.self) }
        let single = base.group { row, _ in row.count }
        #expect(single.query.debugDescription.contains("GROUP BY"))
        let tuple = base.group { row, tag in (row.count, tag.rowID) }
        #expect(tuple.query.debugDescription.contains("GROUP BY"))
    }

    @Test func `No-join and multi-join selects still resolve group(by:)`() {
        let noJoin = Row.group(by: \.count).group { $0.title }
        #expect(noJoin.query.debugDescription.contains("GROUP BY"))
        let multi = Row.group(by: \.count)
            .join(Tag.all) { SQLQueryExpression("\($0.count) = \($1.rowID)", as: Bool.self) }
            .join(Tag.all) { _, _, _ in SQLQueryExpression("1 = 1", as: Bool.self) }
        let grouped = multi.group { row, first, second in (row.count, first.rowID, second.rowID) }
        #expect(grouped.query.debugDescription.contains("GROUP BY"))
    }
}

// MARK: - Invalid-update-filter reporting (G-3)

@Suite
struct ReportTests {
    /// `Sendable` wrapper capturing the reported diagnostic across the handler boundary.
    final class Capture: Sendable {
        let message = Mutex<String?>(nil)
    }

    @Test func `Invalid update filter reports through the bound handler instead of trapping`() {
        let capture = Capture()
        QueryFragment.Report.$invalid.withValue({ message in
            capture.message.withLock { $0 = message }
        }) {
            _ = Row.insert {
                Row(count: 1, title: "a")
            } where: { _ in
                SQLQueryExpression(#""title" = 'x'"#, as: Bool.self)
            }
            .query
        }
        let message = capture.message.withLock { $0 }
        #expect(message?.contains("invalid update 'where'") == true)
    }
}
