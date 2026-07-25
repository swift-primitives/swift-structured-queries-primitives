public import Byte_Primitives

extension QueryBinding.UUID {
    /// This UUID rendered as lower-case hex in RFC 4122's 8-4-4-4-12 grouping.
    ///
    /// Matches what `Foundation.UUID.uuidString.lowercased()` produced before the
    /// Foundation drain, so generated SQL is unchanged. A payload that is not
    /// exactly 16 bytes is rendered ungrouped rather than trapping: this feeds a
    /// debug description, which must never be the thing that crashes.
    var hyphenatedLowercaseHex: String {
        guard bytes.count == 16 else {
            return bytes.map(\.lowercaseHex).joined()
        }
        // RFC 4122 field widths, in bytes: time-low, time-mid, time-high-and-version,
        // clock-seq (2), node (6).
        let groups = [0..<4, 4..<6, 6..<8, 8..<10, 10..<16]
        return
            groups
            .map { range in bytes[range].map(\.lowercaseHex).joined() }
            .joined(separator: "-")
    }
}

extension Byte {
    /// This byte as exactly two lower-case hex digits.
    var lowercaseHex: String {
        let digits = "0123456789abcdef"
        let high = digits[
            digits.index(digits.startIndex, offsetBy: Int(underlying >> 4))
        ]
        let low = digits[
            digits.index(digits.startIndex, offsetBy: Int(underlying & 0x0F))
        ]
        return "\(high)\(low)"
    }
}
