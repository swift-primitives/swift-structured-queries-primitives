extension String {
    /// Returns `value` in base 10, left-padded with zeros to at least `width` digits.
    ///
    /// Foundation-free replacement for the padding a format string would do.
    /// Negative values keep the sign ahead of the padding (`-0042`), which is
    /// what a year before 1 CE requires.
    static func zeroPadded(_ value: Int, width: Int) -> String {
        let negative = value < 0
        // Build the magnitude via UInt to keep Int.min from overflowing on negation.
        let magnitude = negative ? UInt(bitPattern: -value) : UInt(value)
        var digits = String(magnitude)
        if digits.count < width {
            digits = String(repeating: "0", count: width - digits.count) + digits
        }
        return negative ? "-" + digits : digits
    }
}
