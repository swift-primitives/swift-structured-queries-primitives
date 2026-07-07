import Structured_Queries_Primitives_Support

/// The underlying requirements shared by all table column expressions.
public protocol _TableColumnExpression<Root, Value>: QueryExpression where Value == QueryValue {
    associatedtype Root: Table
    associatedtype Value: QueryRepresentable

    var _names: [String] { get }

    /// The table model key path associated with this table column.
    var keyPath: KeyPath<Root, Value.QueryOutput> { get }
}

/// A type representing a table column.
///
/// This protocol provides type erasure over a table's columns. You should not conform to this
/// protocol directly.
public protocol TableColumnExpression<Root, Value>: _TableColumnExpression
where Value: QueryBindable {
    /// The name of the table column.
    var name: String { get }

    /// The default value of the table column.
    var defaultValue: Value.QueryOutput? { get }

    func _aliased<Name: AliasName>(
        _ alias: Name.Type
    ) -> any TableColumnExpression<TableAlias<Root, Name>, Value>
}

extension TableColumnExpression {
    /// The column's name wrapped in a single-element array, satisfying the `_names` requirement.
    public var _names: [String] { [name] }
}

/// A type representing a _writable_ table column, _i.e._ not a generated column.
public protocol WritableTableColumnExpression<Root, Value>: TableColumnExpression {
    func _aliased<Name: AliasName>(
        _ alias: Name.Type
    ) -> any WritableTableColumnExpression<TableAlias<Root, Name>, Value>
}

extension WritableTableColumnExpression {
    /// Returns this writable column aliased and erased to a read-only table column expression.
    public func _aliased<Name: AliasName>(
        _ alias: Name.Type
    ) -> any TableColumnExpression<TableAlias<Root, Name>, Value> {
        _aliased(alias)
    }
}

/// A type representing a table column.
///
/// Don't create instances of this value directly. Instead, use the `@Table` and `@Column` macros to
/// generate values of this type.
public struct TableColumn<Root: Table, Value: QueryRepresentable & QueryBindable>:
    WritableTableColumnExpression
{
    /// The query value type produced by this table column.
    public typealias QueryValue = Value

    /// The name of the table column.
    public let name: String

    /// The default value of the table column.
    public let defaultValue: Value.QueryOutput?

    /// The table model key path associated with this table column.
    public let keyPath: KeyPath<Root, Value.QueryOutput>

    /// Creates a table column with the given name, key path, and optional default value.
    public init(
        _ name: String,
        keyPath: KeyPath<Root, Value.QueryOutput>,
        default defaultValue: Value.QueryOutput? = nil
    ) {
        self.name = name
        self.defaultValue = defaultValue
        self.keyPath = keyPath
    }

    /// Creates a table column with the given name, key path, and optional default value.
    public init(
        _ name: String,
        keyPath: KeyPath<Root, Value>,
        default defaultValue: Value? = nil
    ) where Value == Value.QueryOutput {
        self.name = name
        self.defaultValue = defaultValue
        self.keyPath = keyPath
    }

    /// Decodes this table column's value from the given query decoder.
    public func decode(_ decoder: inout some QueryDecoder) throws -> Value.QueryOutput {
        try Value(decoder: &decoder).queryOutput
    }

    /// The SQL fragment referencing this column, qualified by its table.
    public var queryFragment: QueryFragment {
        "\(Root.self).\(quote: name)"
    }

    /// Returns this column aliased to the given table alias name.
    public func _aliased<Name>(
        _ alias: Name.Type
    ) -> any WritableTableColumnExpression<TableAlias<Root, Name>, Value> {
        TableColumn<TableAlias<Root, Name>, Value>(
            name,
            keyPath: \.[member: \Value.self, column: keyPath]
        )
    }

    /// This column wrapped in a single-element array of all columns.
    public var _allColumns: [any TableColumnExpression] { [self] }

    /// This column wrapped in a single-element array of writable columns.
    public var _writableColumns: [any WritableTableColumnExpression] { [self] }
}

/// A namespace of factory methods for constructing table columns and column groups.
public enum _TableColumn<Root: Table, Value: QueryRepresentable> {
    /// Creates a table column for the given name, key path, and default value.
    public static func `for`(
        _ name: String,
        keyPath: KeyPath<Root, Value.QueryOutput>,
        default defaultValue: Value.QueryOutput? = nil
    ) -> TableColumn<Root, Value>
    where Value: QueryBindable {
        TableColumn(name, keyPath: keyPath, default: defaultValue)
    }

    /// Creates a table column for the given name, key path, and default value.
    public static func `for`(
        _ name: String,
        keyPath: KeyPath<Root, Value>,
        default defaultValue: Value? = nil
    ) -> TableColumn<Root, Value>
    where Value: QueryBindable, Value == Value.QueryOutput {
        TableColumn(name, keyPath: keyPath, default: defaultValue)
    }

    /// Creates a column group for the given key path to a nested table value.
    public static func `for`(
        _: String,
        keyPath: KeyPath<Root, Value>,
        default _: Value? = nil
    ) -> ColumnGroup<Root, Value>
    where Value: Table, Value == Value.QueryOutput {
        ColumnGroup(keyPath: keyPath)
    }
}

/// A type that describes how a table column is generated (_e.g._, generated columns).
///
/// You provide a value of this type to a `@Column` macro to differentiate between generated columns
/// that are physically stored in the database table and those that are "virtual".
///
/// ```swift
/// @Column(generated: .stored)
/// ```
public enum GeneratedColumnStorage {
    case virtual, stored
}

/// A type representing a generated column.
///
/// Don't create instances of this value directly. Instead, use the `@Table` and `@Column` macros to
/// generate values of this type.
public struct GeneratedColumn<Root: Table, Value: QueryRepresentable & QueryBindable>:
    TableColumnExpression
{
    /// The query value type produced by this generated column.
    public typealias QueryValue = Value

    /// The name of the generated column.
    public let name: String

    /// The default value of the generated column.
    public let defaultValue: Value.QueryOutput?

    /// The table model key path associated with this generated column.
    public let keyPath: KeyPath<Root, Value.QueryOutput>

    /// Creates a generated column with the given name, key path, and optional default value.
    public init(
        _ name: String,
        keyPath: KeyPath<Root, Value.QueryOutput>,
        default defaultValue: Value.QueryOutput? = nil
    ) {
        self.name = name
        self.defaultValue = defaultValue
        self.keyPath = keyPath
    }

    /// Creates a generated column with the given name, key path, and optional default value.
    public init(
        _ name: String,
        keyPath: KeyPath<Root, Value.QueryOutput>,
        default defaultValue: Value? = nil
    ) where Value == Value.QueryOutput {
        self.name = name
        self.defaultValue = defaultValue
        self.keyPath = keyPath
    }

    /// Decodes this generated column's value from the given query decoder.
    public func decode(_ decoder: inout some QueryDecoder) throws -> Value.QueryOutput {
        try Value(decoder: &decoder).queryOutput
    }

    /// The SQL fragment referencing this generated column, qualified by its table.
    public var queryFragment: QueryFragment {
        "\(Root.self).\(quote: name)"
    }

    /// Returns this generated column aliased to the given table alias name.
    public func _aliased<Name>(
        _ alias: Name.Type
    ) -> any TableColumnExpression<TableAlias<Root, Name>, Value> {
        TableColumn<TableAlias<Root, Name>, Value>(
            name,
            keyPath: \.[member: \Value.self, column: keyPath]
        )
    }

    /// This generated column wrapped in a single-element array of all columns.
    public var _allColumns: [any TableColumnExpression] { [self] }
}
