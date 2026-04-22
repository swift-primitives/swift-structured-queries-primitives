import Structured_Queries_Primitives
import Testing

@Suite
struct SmokeTests {
    @Test func queryFragmentLiteral() {
        let fragment: QueryFragment = "SELECT 1"
        #expect(!fragment.isEmpty)
    }

    @Test func queryFragmentInterpolation() {
        let name = "users"
        let fragment: QueryFragment = "SELECT * FROM \(quote: name)"
        #expect(!fragment.isEmpty)
    }

    @Test func queryBinding() {
        let binding = QueryBinding.text("hello")
        #expect(binding == .text("hello"))
    }

    @Test func queryBindingInt() {
        let value: Int = 42
        #expect(value.queryBinding == .int(42))
    }

    @Test func queryBindingString() {
        let value = "test"
        #expect(value.queryBinding == .text("test"))
    }

    @Test func queryBindingBool() {
        #expect(true.queryBinding == .bool(true))
        #expect(false.queryBinding == .bool(false))
    }
}
