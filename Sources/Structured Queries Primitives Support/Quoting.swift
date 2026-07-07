import Foundation

/// A delimiter used to quote SQL identifiers or text literals.
public enum QuoteDelimiter: String {
    case identifier = "\""
    case text = "'"
}

extension StringProtocol {
    /// Returns this string quoted with the given delimiter, escaping embedded delimiters.
    public func quoted(_ delimiter: QuoteDelimiter = .identifier) -> String {
        let delimiter = delimiter.rawValue
        return delimiter + replacingOccurrences(of: delimiter, with: delimiter + delimiter)
            + delimiter
    }
}
