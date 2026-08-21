public import Byte_Primitives
import Structured_Queries_Primitives_Support
public import Time_Primitives

public enum QueryBinding: Hashable, Sendable {

    case blob([Byte])

    case bool(Bool)

    case double(Double)

    case date(Instant)

    case int(Int64)

    case null

    case text(String)

    case uuid(QueryBinding.UUID)

    case jsonb([Byte])

    case decimal(String)

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

    case genericArray([QueryBinding])

    case invalid(QueryBindingError)
}

extension QueryBinding {

    @_disfavoredOverload
    public static func invalid(_ error: any Swift.Error) -> Self {
        .invalid(QueryBindingError(underlyingError: error))
    }
}

public struct QueryBindingError: Swift.Error, Hashable {

    public let underlyingError: any Swift.Error

    public init(underlyingError: any Swift.Error) {
        self.underlyingError = underlyingError
    }
}

extension QueryBindingError {

    public static func == (lhs: Self, rhs: Self) -> Bool { true }

    public func hash(into hasher: inout Hasher) {}
}

extension QueryBinding: CustomDebugStringConvertible {

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

            return "<invalid: \(String(describing: error.underlyingError))>"

        case .bool(let bool):
            return bool ? "true" : "false"
        }
    }
}
