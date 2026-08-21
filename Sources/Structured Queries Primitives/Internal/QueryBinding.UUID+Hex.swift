public import Byte_Primitives

extension QueryBinding.UUID {

    var hyphenatedLowercaseHex: String {
        guard bytes.count == 16 else {
            return bytes.map(\.lowercaseHex).joined()
        }

        let groups = [0..<4, 4..<6, 6..<8, 8..<10, 10..<16]
        return
            groups
            .map { range in bytes[range].map(\.lowercaseHex).joined() }
            .joined(separator: "-")
    }
}

extension Byte {

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
