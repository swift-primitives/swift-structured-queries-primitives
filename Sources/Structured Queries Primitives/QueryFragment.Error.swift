public import Index_Primitives

extension QueryFragment {
    /// An error describing why a query fragment cannot be used where bindings are forbidden.
    public enum Error: Swift.Error, Equatable {
        /// The fragment contains the given number of parameter bindings.
        case bound(Index<QueryBinding>.Count)
    }
}
