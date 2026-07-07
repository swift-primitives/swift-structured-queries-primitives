public import Tagged_Primitives

extension Tagged: _OptionalPromotable where Tag: ~Copyable & ~Escapable, Underlying: _OptionalPromotable {}

extension Tagged: QueryBindable where Tag: ~Copyable & ~Escapable, Underlying: QueryBindable {
    /// The query binding for this tagged value, forwarded from the underlying value.
    public var queryBinding: QueryBinding {
        underlying.queryBinding
    }
}

extension Tagged: QueryDecodable where Tag: ~Copyable & ~Escapable, Underlying: QueryDecodable {
    /// Decodes a tagged value by decoding its underlying value.
    public init(decoder: inout some QueryDecoder) throws {
        self.init(_unchecked: try Underlying(decoder: &decoder))
    }
}

extension Tagged: QueryExpression where Tag: ~Copyable & ~Escapable, Underlying: QueryExpression {
    /// The query fragment for this tagged value, forwarded from the underlying value.
    public var queryFragment: QueryFragment {
        underlying.queryFragment
    }
}

extension Tagged: QueryRepresentable where Tag: ~Copyable & ~Escapable, Underlying: QueryRepresentable {
    /// The query output type, preserving the tag around the underlying output type.
    public typealias QueryOutput = Tagged<Tag, Underlying.QueryOutput>

    /// The query output for this tagged value, wrapping the underlying output.
    public var queryOutput: QueryOutput {
        QueryOutput(_unchecked: self.underlying.queryOutput)
    }

    /// Creates a tagged value by wrapping the underlying value's query output.
    public init(queryOutput: QueryOutput) {
        self.init(_unchecked: Underlying(queryOutput: queryOutput.underlying))
    }
}
