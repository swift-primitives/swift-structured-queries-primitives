public import Byte_Primitives
public import Time_Primitives

public protocol QueryDecoder {

    mutating func decode(_ columnType: [Byte].Type) throws -> [Byte]?

    mutating func decode(_ columnType: Double.Type) throws -> Double?

    mutating func decode(_ columnType: Int64.Type) throws -> Int64?

    mutating func decode(_ columnType: UInt64.Type) throws -> UInt64?

    mutating func decode(_ columnType: String.Type) throws -> String?

    mutating func decode(_ columnType: Bool.Type) throws -> Bool?

    mutating func decode(_ columnType: Int.Type) throws -> Int?

    mutating func decode(_ columnType: Instant.Type) throws -> Instant?

    mutating func decode(_ columnType: QueryBinding.UUID.Type) throws -> QueryBinding.UUID?

    mutating func decode<T: QueryRepresentable>(_ columnType: T.Type) throws -> T.QueryOutput?
}

extension QueryDecoder {

    @inlinable
    @inline(__always)
    public mutating func decode<T: QueryRepresentable>(
        _ columnType: T.Type
    ) throws -> T.QueryOutput? {
        try T?(decoder: &self)?.queryOutput
    }

    @inlinable
    @inline(__always)
    public mutating func decodeColumns<each T: QueryRepresentable>(
        _ columnTypes: (repeat each T).Type
    ) throws -> (repeat (each T).QueryOutput) {
        try (repeat (each T)(decoder: &self).queryOutput)
    }

    @inlinable
    @inline(__always)
    public mutating func decode<T: QueryRepresentable<T>>(
        _ columnType: T.Type = T.self
    ) throws -> T? {
        try T?(decoder: &self)?.queryOutput
    }

}

public enum QueryDecodingError: Swift.Error {
    case missingRequiredColumn
}
