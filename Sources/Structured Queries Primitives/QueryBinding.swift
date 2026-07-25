public import Byte_Primitives
import Structured_Queries_Primitives_Support
public import Time_Primitives

/// A type that enumerates the values that can be bound to the parameters of a SQL statement.
public enum QueryBinding: Hashable, Sendable {
    /// A value that should be bound to a statement as bytes.
    case blob([Byte])

    case bool(Bool)

    /// A value that should be bound to a statement as a double.
    case double(Double)

    /// A value that should be bound to a statement as a date.
    case date(Instant)

    /// A value that should be bound to a statement as an integer.
    case int(Int64)

    /// A value that should be bound to a statement as `NULL`.
    case null

    /// A value that should be bound to a statement as a string.
    case text(String)

    /// A value that should be bound to a statement as a unique identifier.
    case uuid(QueryBinding.UUID)

    /// A value that should be bound to a statement as PostgreSQL JSONB.
    case jsonb([Byte])

    /// A value that should be bound to a statement as a decimal, carrying its
    /// exact digits.
    ///
    /// The payload is the value's plain digit string (never exponent notation),
    /// which is what PostgreSQL `numeric` accepts as a literal. Text is not a
    /// fallback here, it is the representation: `numeric` admits ~131 000 digits
    /// where decimal128 admits 34, so digits are *strictly more* precise than a
    /// fixed-width decimal type, and no value has to be rounded to fit.
    ///
    /// This case stays distinct from ``text(_:)`` so the value keeps its numeric
    /// typing — it renders unquoted, as a SQL numeric literal.
    ///
    /// A typed decimal is the eventual destination; see the charter item for
    /// decimal string construction in `swift-decimal-primitives`. Until a decimal
    /// can be built from the wire data it carries, digits are the correct interim
    /// — this is a deliberate choice, not an oversight.
    case decimal(String)

    /// A value that should be bound to a statement as a PostgreSQL native array.
    case boolArray([Bool])
    case stringArray([String])
    case intArray([Int])
    case int16Array([Int16])
    case int32Array([Int32])
    case int64Array([Int64])
    case floatArray([Float])
    case doubleArray([Double])
    case uuidArray([QueryBinding.UUID])
    case dateArray([Instant])

    /// A generic array case for any QueryBindable element type that doesn't have a specific case.
    ///
    /// Elements are converted to their individual QueryBindings.
    case genericArray([QueryBinding])

    /// An error describing why a value cannot be bound to a statement.
    case invalid(QueryBindingError)
}

extension QueryBinding {
    /// Wraps an arbitrary error as an invalid query binding.
    @_disfavoredOverload
    public static func invalid(_ error: any Swift.Error) -> Self {
        .invalid(QueryBindingError(underlyingError: error))
    }
}

/// A type that wraps errors encountered when trying to bind a value to a statement.
public struct QueryBindingError: Swift.Error, Hashable {
    /// The underlying error that caused the binding failure.
    public let underlyingError: any Swift.Error
    /// Creates a `QueryBindingError` wrapping the given underlying error.
    public init(underlyingError: any Swift.Error) {
        self.underlyingError = underlyingError
    }
}

extension QueryBindingError {
    /// Always returns `true`, since `QueryBindingError` values are not meaningfully comparable.
    public static func == (lhs: Self, rhs: Self) -> Bool { true }
    /// No-op hash implementation, since all `QueryBindingError` values are considered equal.
    public func hash(into hasher: inout Hasher) {}
}

extension QueryBinding: CustomDebugStringConvertible {
    /// A human-readable SQL literal representation of this binding's value.
    public var debugDescription: String {
        switch self {
        case .blob(let data):
            return String(decoding: data.map(\.underlying), as: UTF8.self)
                .debugDescription
                .dropLast()
                .dropFirst()
                .quoted(.text)
        case .date(let date):
            return date.sqlTimestampLiteral.quoted(.text)
        case .double(let value):
            return "\(value)"
        case .int(let value):
            return "\(value)"
        case .null:
            return "NULL"
        case .text(let string):
            return string.quoted(.text)
        case .uuid(let uuid):
            return uuid.hyphenatedLowercaseHex.quoted(.text)
        case .jsonb(let data):
            return String(decoding: data.map(\.underlying), as: UTF8.self).quoted(.text)
        case .decimal(let digits):
            // Unquoted: a SQL numeric literal, not a text literal.
            return digits
        case .boolArray(let values):
            return "ARRAY[\(values.map { $0 ? "true" : "false" }.joined(separator: ", "))]"
        case .stringArray(let values):
            return "ARRAY[\(values.map { $0.quoted(.text) }.joined(separator: ", "))]"
        case .intArray(let values):
            return "ARRAY[\(values.map { "\($0)" }.joined(separator: ", "))]"
        case .int16Array(let values):
            return "ARRAY[\(values.map { "\($0)" }.joined(separator: ", "))]"
        case .int32Array(let values):
            return "ARRAY[\(values.map { "\($0)" }.joined(separator: ", "))]"
        case .int64Array(let values):
            return "ARRAY[\(values.map { "\($0)" }.joined(separator: ", "))]"
        case .floatArray(let values):
            return "ARRAY[\(values.map { "\($0)" }.joined(separator: ", "))]"
        case .doubleArray(let values):
            return "ARRAY[\(values.map { "\($0)" }.joined(separator: ", "))]"
        case .uuidArray(let values):
            return
                "ARRAY[\(values.map { $0.hyphenatedLowercaseHex.quoted(.text) }.joined(separator: ", "))]"
        case .dateArray(let values):
            return
                "ARRAY[\(values.map { $0.sqlTimestampLiteral.quoted(.text) }.joined(separator: ", "))]"
        case .genericArray(let bindings):
            return "ARRAY[\(bindings.map { $0.debugDescription }.joined(separator: ", "))]"
        case .invalid(let error):
            // `localizedDescription` is Foundation surface on `any Error`; the
            // Foundation-free equivalent for an arbitrary error is `String(describing:)`.
            return "<invalid: \(String(describing: error.underlyingError))>"
        case .bool(let bool):
            return bool ? "true" : "false"
        }
    }
}
