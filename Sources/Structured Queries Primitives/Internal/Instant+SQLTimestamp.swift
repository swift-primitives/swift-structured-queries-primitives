public import Time_Primitives

extension Instant {
    /// This instant rendered as a SQL timestamp literal, `yyyy-MM-dd HH:mm:ss.SSS` in UTC.
    ///
    /// Composed from `Time`'s typed calendar components rather than formatted by
    /// Foundation or by an RFC 3339 serializer: the calendar arithmetic already
    /// lives in `Time.init(_:)`, and `swift-rfc-3339` — which owns RFC 3339
    /// formatting — sits above the primitives layer, so an L1 target may not
    /// import it ([ARCH-LAYER-001]).
    ///
    /// The shape matches what this package emitted through Foundation before the
    /// Foundation drain, so generated SQL is unchanged. Note this is a debug
    /// literal: a bound value reaches the database as a typed value through the
    /// driver, so the millisecond width here does not cap wire precision.
    var sqlTimestampLiteral: String {
        let time = Time(self)
        let date =
            "\(String.zeroPadded(time.year.rawValue, width: 4))"
            + "-\(String.zeroPadded(time.month.rawValue, width: 2))"
            + "-\(String.zeroPadded(time.day.rawValue, width: 2))"
        let clock =
            "\(String.zeroPadded(time.hour.value, width: 2))"
            + ":\(String.zeroPadded(time.minute.value, width: 2))"
            + ":\(String.zeroPadded(time.second.value, width: 2))"
            + ".\(String.zeroPadded(time.millisecond.value, width: 3))"
        return "\(date) \(clock)"
    }
}
