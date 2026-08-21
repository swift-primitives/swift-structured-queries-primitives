public import Time_Primitives

extension Instant {

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
