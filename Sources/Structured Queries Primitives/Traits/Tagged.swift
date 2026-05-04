public import Tagged_Primitives

extension Tagged: _OptionalPromotable where Tag: ~Copyable, Underlying: _OptionalPromotable {}

extension Tagged: QueryBindable where Tag: ~Copyable, Underlying: QueryBindable {
    public var queryBinding: QueryBinding {
        underlying.queryBinding
    }
}

extension Tagged: QueryDecodable where Tag: ~Copyable, Underlying: QueryDecodable {
    public init(decoder: inout some QueryDecoder) throws {
        self.init(_unchecked: try Underlying(decoder: &decoder))
    }
}

extension Tagged: QueryExpression where Tag: ~Copyable, Underlying: QueryExpression {
    public var queryFragment: QueryFragment {
        underlying.queryFragment
    }
}

extension Tagged: QueryRepresentable where Tag: ~Copyable, Underlying: QueryRepresentable {
    public typealias QueryOutput = Tagged<Tag, Underlying.QueryOutput>

    public var queryOutput: QueryOutput {
        QueryOutput(_unchecked: self.underlying.queryOutput)
    }

    public init(queryOutput: QueryOutput) {
        self.init(_unchecked: Underlying(queryOutput: queryOutput.underlying))
    }
}
