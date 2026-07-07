/// The strategy for applying a table's default `all` scope when building a statement.
public enum Scope: Sendable {
    case unscoped
    case `default`
    case empty
}
