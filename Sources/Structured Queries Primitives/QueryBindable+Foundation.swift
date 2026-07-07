public import Foundation

extension Data: QueryBindable {
    /// This value's binding, encoded as a blob.
    public var queryBinding: QueryBinding {
        .blob([UInt8](self))
    }

    /// Creates a value by decoding blob bytes from the given decoder.
    public init(decoder: inout some QueryDecoder) throws {
        // Decode as blob/bytea
        guard let bytes = try decoder.decode([UInt8].self)
        else { throw QueryDecodingError.missingRequiredColumn }
        self.init(bytes)
    }
}

extension URL: QueryBindable {
    /// This value's binding, encoded as its absolute string.
    public var queryBinding: QueryBinding {
        .text(absoluteString)
    }

    /// Creates a value by decoding an absolute URL string from the given decoder.
    public init(decoder: inout some QueryDecoder) throws {
        guard let url = Self(string: try String(decoder: &decoder)) else {
            throw InvalidURL()
        }
        self = url
    }
}

private struct InvalidURL: Swift.Error {}
