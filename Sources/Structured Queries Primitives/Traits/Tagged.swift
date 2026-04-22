public import Identity_Primitives

extension Tagged: _OptionalPromotable where Tag: ~Copyable, RawValue: _OptionalPromotable {}

extension Tagged: QueryBindable where Tag: ~Copyable, RawValue: QueryBindable {
    public var queryBinding: QueryBinding {
        rawValue.queryBinding
    }
}

extension Tagged: QueryDecodable where Tag: ~Copyable, RawValue: QueryDecodable {
    public init(decoder: inout some QueryDecoder) throws {
        self.init(__unchecked: (), try RawValue(decoder: &decoder))
    }
}

extension Tagged: QueryExpression where Tag: ~Copyable, RawValue: QueryExpression {
    public var queryFragment: QueryFragment {
        rawValue.queryFragment
    }
}

extension Tagged: QueryRepresentable where Tag: ~Copyable, RawValue: QueryRepresentable {
    public typealias QueryOutput = Tagged<Tag, RawValue.QueryOutput>

    public var queryOutput: QueryOutput {
        QueryOutput(__unchecked: (), self.rawValue.queryOutput)
    }

    public init(queryOutput: QueryOutput) {
        self.init(__unchecked: (), RawValue(queryOutput: queryOutput.rawValue))
    }
}
