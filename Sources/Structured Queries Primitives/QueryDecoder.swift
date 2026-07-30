public import Byte_Primitives
public import Time_Primitives

// swiftlint:disable typed_throws_required
// reason: `QueryDecoder` is implemented by heterogeneous, out-of-repo backend drivers (SQLite,
// Postgres, ...), each surfacing its own decode-failure error domain; an untyped `throws` here
// mirrors the same protocol-requirement shape as `Decodable.init(from:) throws`. [API-ERR-006]
// exception (rule-exemptions protocol-requirement shape).
/// A type that can decode values from a database connection into in-memory representations.
public protocol QueryDecoder {
    // swiftlint:disable:next discouraged_optional_collection
    /// Decodes a single value of the given type from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode(_ columnType: [Byte].Type) throws -> [Byte]?

    /// Decodes a single value of the given type from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode(_ columnType: Double.Type) throws -> Double?

    /// Decodes a single value of the given type from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode(_ columnType: Int64.Type) throws -> Int64?

    /// Decodes a single value of the given type from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode(_ columnType: UInt64.Type) throws -> UInt64?

    /// Decodes a single value of the given type from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode(_ columnType: String.Type) throws -> String?

    /// Decodes a single value of the given type from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode(_ columnType: Bool.Type) throws -> Bool?

    /// Decodes a single value of the given type from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode(_ columnType: Int.Type) throws -> Int?

    /// Decodes a single value of the given type from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode(_ columnType: Instant.Type) throws -> Instant?

    /// Decodes a single value of the given type from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode(_ columnType: QueryBinding.UUID.Type) throws -> QueryBinding.UUID?

    /// Decodes a single value of the given type starting from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    mutating func decode<T: QueryRepresentable>(_ columnType: T.Type) throws -> T.QueryOutput?
}
// swiftlint:enable typed_throws_required

extension QueryDecoder {
    // swiftlint:disable typed_throws_required
    // reason: these forward to `QueryDecodable.init(decoder:) throws`, itself untyped for the
    // same heterogeneous-backend reason as the `QueryDecoder` requirement above.
    // [API-ERR-006] exception (rule-exemptions protocol-requirement shape).

    /// Decodes a single value of the given type starting from the current column.
    ///
    /// - Parameter columnType: The type to decode as.
    /// - Returns: A value of the requested type, or `nil` if the column is `NULL`.
    /// - Throws: Any error the underlying database driver reports while decoding the column.
    @inlinable
    @inline(__always)
    public mutating func decode<T: QueryRepresentable>(
        _ columnType: T.Type
    ) throws -> T.QueryOutput? {
        try T?(decoder: &self)?.queryOutput
    }

    /// Decodes a single tuple of the given type starting from the current column.
    ///
    /// - Parameter columnTypes: The types to decode as.
    /// - Returns: A tuple of the requested types.
    /// - Throws: Any error the underlying database driver reports while decoding the columns.
    @inlinable
    @inline(__always)
    public mutating func decodeColumns<each T: QueryRepresentable>(
        _ columnTypes: (repeat each T).Type
    ) throws -> (repeat (each T).QueryOutput) {
        try (repeat (each T)(decoder: &self).queryOutput)
    }

    /// Decodes a single self-representing value starting from the current column.
    @inlinable
    @inline(__always)
    public mutating func decode<T: QueryRepresentable<T>>(
        _ columnType: T.Type = T.self
    ) throws -> T? {
        try T?(decoder: &self)?.queryOutput
    }
    // swiftlint:enable typed_throws_required
}

/// The errors that can occur when decoding a query result column.
public enum QueryDecodingError: Swift.Error {
    case missingRequiredColumn
}
