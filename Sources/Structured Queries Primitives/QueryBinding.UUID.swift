public import Byte_Primitives

extension QueryBinding {

    public struct UUID: Hashable, Sendable {

        public var bytes: [Byte]

        public init(bytes: [Byte]) {
            self.bytes = bytes
        }
    }
}
