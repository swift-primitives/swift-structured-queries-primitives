/// A delimiter used to quote SQL identifiers or text literals.
public enum QuoteDelimiter: String {
    case identifier = "\""
    case text = "'"
}

extension StringProtocol {
    /// Returns this string quoted with the given delimiter, escaping embedded delimiters.
    public func quoted(_ delimiter: QuoteDelimiter = .identifier) -> String {
        // Foundation-free escape: wrap in the delimiter, doubling any embedded delimiter.
        let mark = Character(delimiter.rawValue)
        var result = String(mark)
        for character in self {
            result.append(character)
            if character == mark { result.append(mark) }
        }
        result.append(mark)
        return result
    }
}
