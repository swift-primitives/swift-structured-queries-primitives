import Structured_Queries_Primitives
import Testing

@Suite
struct SmokeTests {
    @Test func `Query Fragment Literal`() {
        let fragment: QueryFragment = "SELECT 1"
        #expect(!fragment.isEmpty)
    }

    @Test func `Query Fragment Interpolation`() {
        let name = "users"
        let fragment: QueryFragment = "SELECT * FROM \(quote: name)"
        #expect(!fragment.isEmpty)
    }

    @Test func `Query Binding`() {
        let binding = QueryBinding.text("hello")
        #expect(binding == .text("hello"))
    }

    @Test func `Query Binding Int`() {
        let value: Int = 42
        #expect(value.queryBinding == .int(42))
    }

    @Test func `Query Binding String`() {
        let value = "test"
        #expect(value.queryBinding == .text("test"))
    }

    @Test func `Query Binding Bool`() {
        #expect(true.queryBinding == .bool(true))
        #expect(false.queryBinding == .bool(false))
    }
}
