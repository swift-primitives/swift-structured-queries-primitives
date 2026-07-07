public import Foundation

/// A type representing a value that can be bound to a parameter of a SQL statement.
public protocol QueryBindable: QueryRepresentable, QueryExpression where QueryValue: QueryBindable {
    /// The Swift data type representation of the expression's SQL bindable data type.
    ///
    /// For example, a `TEXT` expression may be represented as a `String` query value.
    associatedtype QueryValue = Self

    /// A value that can be bound to a parameter of a SQL statement.
    var queryBinding: QueryBinding { get }
}

extension QueryBindable {
    /// The query fragment produced by binding this value as a parameter.
    public var queryFragment: QueryFragment { "\(queryBinding)" }
}

// Note: Array<Element: QueryBindable> conformance (including [UInt8] for bytea)
// is in StructuredQueriesPostgres/Types/Array/PostgresArray.swift

extension Bool: QueryBindable {
    /// The query binding representing this Boolean value.
    public var queryBinding: QueryBinding { .bool(self) }
}

extension Double: QueryBindable {
    /// The query binding representing this double-precision floating-point value.
    public var queryBinding: QueryBinding { .double(self) }
}

extension Date: QueryBindable {
    /// The query binding representing this date value.
    public var queryBinding: QueryBinding { .date(self) }
}

extension Float: QueryBindable {
    /// The query binding representing this floating-point value.
    public var queryBinding: QueryBinding { .double(Double(self)) }
}

extension Int: QueryBindable {
    /// The query binding representing this integer value.
    public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension Int8: QueryBindable {
    /// The query binding representing this 8-bit integer value.
    public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension Int16: QueryBindable {
    /// The query binding representing this 16-bit integer value.
    public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension Int32: QueryBindable {
    /// The query binding representing this 32-bit integer value.
    public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension Int64: QueryBindable {
    /// The query binding representing this 64-bit integer value.
    public var queryBinding: QueryBinding { .int(self) }
}

extension String: QueryBindable {
    /// The query binding representing this string value.
    public var queryBinding: QueryBinding { .text(self) }
}

extension UInt8: QueryBindable {
    /// The query binding representing this unsigned 8-bit integer value.
    public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension UInt16: QueryBindable {
    /// The query binding representing this unsigned 16-bit integer value.
    public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension UInt32: QueryBindable {
    /// The query binding representing this unsigned 32-bit integer value.
    public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension UInt64: QueryBindable {
    /// The query binding representing this unsigned 64-bit integer value, or an overflow error.
    public var queryBinding: QueryBinding {
        if self > UInt64(Int64.max) {
            return .invalid(OverflowError())
        } else {
            return .int(Int64(self))
        }
    }
}

extension UUID: QueryBindable {
    /// The query binding representing this UUID value.
    public var queryBinding: QueryBinding { .uuid(self) }
}

extension Decimal: QueryBindable {
    /// The query binding representing this decimal value.
    public var queryBinding: QueryBinding { .decimal(self) }
}

extension DefaultStringInterpolation {
    /// Appends a debug description of the given SQL expression to this string interpolation.
    @_disfavoredOverload
    @available(
        *,
        deprecated,
        message: """
            String interpolation produces a debug description for a SQL expression. \
            Use '+' to concatenate SQL expressions, instead."
            """
    )
    public mutating func appendInterpolation(_ value: some QueryExpression) {
        self.appendInterpolation(value as Any)
    }

    /// Appends a debug description of the given table column to this string interpolation.
    @available(
        *,
        deprecated,
        message: """
            String interpolation produces a debug description for a SQL expression. \
            Use '+' to concatenate SQL expressions, instead."
            """
    )
    public mutating func appendInterpolation<T, V>(_ value: TableColumn<T, V>) {
        self.appendInterpolation(value as Any)
    }
}

extension QueryBindable where Self: LosslessStringConvertible {
    /// The query binding derived from this value's lossless string description.
    public var queryBinding: QueryBinding { description.queryBinding }
}

extension QueryBindable where Self: RawRepresentable, RawValue: QueryBindable {
    /// The query binding derived from this value's raw representable value.
    public var queryBinding: QueryBinding { rawValue.queryBinding }
}
