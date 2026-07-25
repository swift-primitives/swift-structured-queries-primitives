public import Byte_Primitives

extension QueryBinding {
    /// A UUID represented as its 16 raw bytes, in RFC 4122 byte order.
    ///
    /// The core stays Foundation-free, so a UUID is carried as bytes rather than
    /// as `Foundation.UUID`. It is a distinct type rather than a bare `[Byte]` so
    /// a UUID cannot be confused with an arbitrary blob — 16 bytes and a UUID are
    /// not interchangeable.
    ///
    /// A `Tagged` wrapper cannot serve here: this package already declares blanket
    /// conditional conformances for `Tagged` that forward to `Underlying`
    /// (`Traits/Tagged.swift`), so a tagged UUID would bind as ``QueryBinding/blob(_:)``
    /// rather than ``QueryBinding/uuid(_:)``, and a specialized conformance is
    /// rejected — Swift permits only one conformance per type, whatever the
    /// conditional bounds.
    ///
    /// Consumers who want `Foundation.UUID` opt into the
    /// `Structured Queries Primitives Foundation Integration` product, which
    /// bridges onto this representation.
    public struct UUID: Hashable, Sendable {
        /// The 16 bytes backing this identifier.
        public var bytes: [Byte]

        /// Creates a UUID from its raw bytes.
        ///
        /// The count is not enforced: a malformed width is rendered ungrouped by
        /// the debug description rather than trapping, because a binding must not
        /// be the thing that crashes a query.
        public init(bytes: [Byte]) {
            self.bytes = bytes
        }
    }
}
