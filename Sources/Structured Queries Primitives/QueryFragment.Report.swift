extension QueryFragment {

    public enum Report {}
}

extension QueryFragment.Report {

    public struct Handler: Sendable {

        public let run: @Sendable (String) -> Void

        public init(_ run: @escaping @Sendable (String) -> Void) {
            self.run = run
        }
    }

    @TaskLocal public static var invalid: Handler?
}
