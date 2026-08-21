public enum QuoteDelimiter: String {
    case identifier = "\""
    case text = "'"
}

extension StringProtocol {

    public func quoted(_ delimiter: QuoteDelimiter = .identifier) -> String {

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
