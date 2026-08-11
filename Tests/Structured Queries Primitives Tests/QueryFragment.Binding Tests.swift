import Index_Primitives
import Structured_Queries_Primitives
import Testing

extension QueryFragment {
    @Suite struct Binding {
        struct Selection: PartialSelectStatement {
            typealias QueryValue = Row
            typealias From = Never

            let query: QueryFragment
        }

        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension QueryFragment.Binding.Unit {
    @Test func `zero bindings succeeds`() throws(QueryFragment.Error) {
        let fragment: QueryFragment = "SELECT 1"
        #expect(try fragment.unbound() == fragment)
        _ = try Row.createTemporaryView(as: QueryFragment.Binding.Selection(query: fragment))
            .validated()
    }
}

extension QueryFragment.Binding.`Edge Case` {
    @Test func `one binding reports the exact typed count without SQL or data`() {
        let fragment: QueryFragment = "SELECT \(QueryBinding.text("private"))"

        #expect(throws: QueryFragment.Error.bound(Index<QueryBinding>.Count(1))) {
            try Row.createTemporaryView(as: QueryFragment.Binding.Selection(query: fragment))
                .validated()
        }
    }

    @Test func `many bindings report the exact typed count without SQL or data`() {
        let fragment: QueryFragment =
            "SELECT \(QueryBinding.text("private")), \(QueryBinding.int(42)), \(QueryBinding.bool(true))"

        #expect(throws: QueryFragment.Error.bound(Index<QueryBinding>.Count(3))) {
            try Row.createTemporaryView(as: QueryFragment.Binding.Selection(query: fragment))
                .validated()
        }
    }
}
