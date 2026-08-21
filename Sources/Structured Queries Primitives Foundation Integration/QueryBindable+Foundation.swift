public import Byte_Primitives
public import Foundation
public import Structured_Queries_Primitives
public import Time_Primitives

extension Data: QueryBindable {

    public var queryBinding: QueryBinding {
        .blob(map(Byte.init))
    }

    public init(decoder: inout some QueryDecoder) throws {

        guard let bytes = try decoder.decode([Byte].self)
        else { throw QueryDecodingError.missingRequiredColumn }
        self.init(bytes.map(\.underlying))
    }
}

extension URL: QueryBindable {

    public var queryBinding: QueryBinding {
        .text(absoluteString)
    }

    public init(decoder: inout some QueryDecoder) throws {
        guard let url = Self(string: try String(decoder: &decoder)) else {
            throw InvalidURL()
        }
        self = url
    }
}

extension Foundation.Date: QueryBindable {

    public var queryBinding: QueryBinding {
        .date(instant)
    }

    public init(decoder: inout some QueryDecoder) throws {
        guard let instant = try decoder.decode(Instant.self)
        else { throw QueryDecodingError.missingRequiredColumn }
        self = Foundation.Date(instant)
    }
}

extension Foundation.UUID: QueryBindable {

    public var queryBinding: QueryBinding {
        .uuid(QueryBinding.UUID(self))
    }

    public init(decoder: inout some QueryDecoder) throws {
        guard let identifier = try decoder.decode(QueryBinding.UUID.self)
        else { throw QueryDecodingError.missingRequiredColumn }
        guard let value = Self(identifier) else { throw InvalidUUID() }
        self = value
    }
}

extension Foundation.Decimal: QueryBindable {

    public var queryBinding: QueryBinding {
        .decimal(description)
    }

    public init(decoder: inout some QueryDecoder) throws {
        let digits = try String(decoder: &decoder)
        guard let value = Self(string: digits) else { throw InvalidDecimal() }
        self = value
    }
}

extension QueryBinding.UUID {

    public init(_ uuid: Foundation.UUID) {
        let u = uuid.uuid
        self.init(
            bytes: [
                u.0, u.1, u.2, u.3, u.4, u.5, u.6, u.7,
                u.8, u.9, u.10, u.11, u.12, u.13, u.14, u.15,
            ].map(Byte.init)
        )
    }
}

extension Foundation.UUID {

    public init?(_ identifier: QueryBinding.UUID) {
        let b = identifier.bytes.map(\.underlying)
        guard b.count == 16 else { return nil }
        self.init(
            uuid: (
                b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
                b[8], b[9], b[10], b[11], b[12], b[13], b[14], b[15]
            )
        )
    }
}

extension Foundation.Date {

    public var instant: Instant {
        let seconds = timeIntervalSince1970
        let whole = seconds.rounded(.down)
        let nanos = Int32(((seconds - whole) * 1_000_000_000).rounded())

        return Instant(
            _unchecked: (),
            secondsSinceUnixEpoch: Int64(whole),
            nanosecondFraction: min(nanos, 999_999_999)
        )
    }

    public init(_ instant: Instant) {
        self.init(
            timeIntervalSince1970: Double(instant.secondsSinceUnixEpoch)
                + Double(instant.nanosecondFraction) / 1_000_000_000
        )
    }
}

private struct InvalidURL: Swift.Error {}
private struct InvalidUUID: Swift.Error {}
private struct InvalidDecimal: Swift.Error {}
