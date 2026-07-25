public import Byte_Primitives
public import Foundation
public import Structured_Queries_Primitives
public import Time_Primitives

// Opt-in Foundation interop. The core is Foundation-free and binds primitive
// types ([Byte], Instant, QueryBinding.UUID, exact decimal digits); these
// conformances let Foundation's value types bridge onto that representation for
// consumers who want them ([PRIM-FOUND-001]).
//
// This target is a leaf: no core target depends on it, so Foundation never
// enters the core's dependency closure.

extension Data: QueryBindable {
    /// This value's binding, encoded as a blob.
    public var queryBinding: QueryBinding {
        .blob(map(Byte.init))
    }

    /// Creates a value by decoding blob bytes from the given decoder.
    public init(decoder: inout some QueryDecoder) throws {
        // Decode as blob/bytea
        guard let bytes = try decoder.decode([Byte].self)
        else { throw QueryDecodingError.missingRequiredColumn }
        self.init(bytes.map(\.underlying))
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

extension Foundation.Date: QueryBindable {
    /// This date's binding, converted to the core's Foundation-free instant.
    ///
    /// `Instant` carries nanosecond resolution, so no precision is lost relative
    /// to `Date`'s double-based seconds.
    public var queryBinding: QueryBinding {
        .date(instant)
    }

    /// Creates a date by decoding an instant from the given decoder.
    public init(decoder: inout some QueryDecoder) throws {
        guard let instant = try decoder.decode(Instant.self)
        else { throw QueryDecodingError.missingRequiredColumn }
        self = Foundation.Date(instant)
    }
}

extension Foundation.UUID: QueryBindable {
    /// This UUID's binding, carried as its 16 raw bytes.
    public var queryBinding: QueryBinding {
        .uuid(QueryBinding.UUID(self))
    }

    /// Creates a UUID by decoding its 16 raw bytes from the given decoder.
    public init(decoder: inout some QueryDecoder) throws {
        guard let identifier = try decoder.decode(QueryBinding.UUID.self)
        else { throw QueryDecodingError.missingRequiredColumn }
        guard let value = Self(identifier) else { throw InvalidUUID() }
        self = value
    }
}

extension Foundation.Decimal: QueryBindable {
    /// This decimal's binding, carried as its exact digits.
    ///
    /// `Decimal.description` is the value's exact decimal expansion, so nothing is
    /// rounded on the way to the database — and PostgreSQL `numeric` accepts far
    /// more digits than any fixed-width decimal type could hold.
    public var queryBinding: QueryBinding {
        .decimal(description)
    }

    /// Creates a decimal by decoding its digits from the given decoder.
    public init(decoder: inout some QueryDecoder) throws {
        let digits = try String(decoder: &decoder)
        guard let value = Self(string: digits) else { throw InvalidDecimal() }
        self = value
    }
}

// MARK: - QueryBinding.UUID <-> Foundation.UUID

extension QueryBinding.UUID {
    /// Creates the core's byte-based UUID from a `Foundation.UUID`.
    ///
    /// Element-level conversion, distinct from the whole-value `queryBinding`
    /// above: array bindings such as ``QueryBinding/uuidArray(_:)`` need to map
    /// each element, and without this every consumer would re-spell the 16-byte
    /// expansion — duplicating a byte order that must not drift.
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
    /// Creates a `Foundation.UUID` from the core's byte-based UUID.
    ///
    /// Returns `nil` when the payload is not exactly 16 bytes.
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

// MARK: - Instant <-> Foundation.Date

extension Foundation.Date {
    /// This date as a Foundation-free instant.
    public var instant: Instant {
        let seconds = timeIntervalSince1970
        let whole = seconds.rounded(.down)
        let nanos = Int32(((seconds - whole) * 1_000_000_000).rounded())
        // The fraction is in [0, 1), so nanos is in [0, 1_000_000_000]; clamp the
        // rounding-up edge rather than throwing out of a bridging accessor.
        return Instant(
            _unchecked: (),
            secondsSinceUnixEpoch: Int64(whole),
            nanosecondFraction: min(nanos, 999_999_999)
        )
    }

    /// Creates a date from a Foundation-free instant.
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
