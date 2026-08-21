extension String {

    static func zeroPadded(_ value: Int, width: Int) -> String {
        let negative = value < 0

        let magnitude = negative ? UInt(bitPattern: -value) : UInt(value)
        var digits = String(magnitude)
        if digits.count < width {
            digits = String(repeating: "0", count: width - digits.count) + digits
        }
        return negative ? "-" + digits : digits
    }
}
