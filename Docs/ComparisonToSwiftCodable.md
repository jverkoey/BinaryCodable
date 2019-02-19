# Comparison to Swift Codable

Binary Codable is similar to Swift [Codable](https://developer.apple.com/documentation/foundation/archives_and_serialization) in that both define an encodable and decodable type that concrete types are expected to implement and both provide encoders and decoders.

Binary Codable is distinct from Swift Codable in the assumptions it makes about how external representations are structured. Swift Codable assumes that external representations have a pre-determined structure (JSON, PropertyList, etc...). Binary Codable, on the other hand, views external representations purely as binary data. This distinction is reflected in the difference of the APIs provided by the BinaryEncoder and BinaryCoder types.

## Interface comparison

Swift Codable and Binary Codable's related types are outlined below.

| Swift Codable | Binary Codable    |
|:--------------|:------------------|
| `Codable`     | `BinaryCodable`   |
| `Encodable`   | `BinaryEncodable` |
| `Decodable`   | `BinaryDecodable` |

| Swift Codable Encoder          | Binary Codable Encoder              |
|:-------------------------------|:------------------------------------|
| `KeyedEncodingContainer`       | No equivalent                       |
| `UnkeyedEncodingContainer`     | `SequentialBinaryEncodingContainer` |
| `SingleValueEncodingContainer` | No equivalent                       |

| Swift Codable Encoding Container | Binary Codable Encoding Container                                         |
|:---------------------------------|:--------------------------------------------------------------------------|
| `encode(_ value: Int8)`          | `encode<T>(_ value: T) where T: FixedWidthInteger`                        |
| `encode(_ value: Int16)`         | `encode<T>(_ value: T) where T: FixedWidthInteger`                        |
| `encode(_ value: Int32)`         | `encode<T>(_ value: T) where T: FixedWidthInteger`                        |
| `encode(_ value: Int64)`         | `encode<T>(_ value: T) where T: FixedWidthInteger`                        |
| `encode(_ value: UInt8)`         | `encode<T>(_ value: T) where T: FixedWidthInteger`                        |
| `encode(_ value: UInt16)`        | `encode<T>(_ value: T) where T: FixedWidthInteger`                        |
| `encode(_ value: UInt32)`        | `encode<T>(_ value: T) where T: FixedWidthInteger`                        |
| `encode(_ value: UInt64)`        | `encode<T>(_ value: T) where T: FixedWidthInteger`                        |
| `encode<T>(_ value: T)`          | `encode<T>(_ value: T)`                                                   |
| `encode(_ value: String)`        | `encode(_ value: String, encoding: String.Encoding, terminator: UInt8?)`  |
| No equivalent                    | `encode<S>(sequence: S) throws where S: Sequence, S.Element == UInt8`     |

| Swift Codable Decoder          | Binary Codable Decoder              |
|:-------------------------------|:------------------------------------|
| `KeyedDecodingContainer`       | No equivalent                       |
| `UnkeyedDecodingContainer`     | `SequentialBinaryDecodingContainer` |
| `SingleValueDecodingContainer` | No equivalent                       |

| Swift Codable Decoding Container                | Binary Codable Decoding Container                                       |
|:------------------------------------------------|:------------------------------------------------------------------------|
| `decode(_ type: Int8.Type) -> Int8`             | `decode<T>(_ type: T.Type) -> T where T: FixedWidthInteger`             |
| `decode(_ type: Int16.Type) -> Int16`           | `decode<T>(_ type: T.Type) -> T where T: FixedWidthInteger`             |
| `decode(_ type: Int32.Type) -> Int32`           | `decode<T>(_ type: T.Type) -> T where T: FixedWidthInteger`             |
| `decode(_ type: Int64.Type) -> Int64`           | `decode<T>(_ type: T.Type) -> T where T: FixedWidthInteger`             |
| `decode(_ type: UInt8.Type) -> UInt8`           | `decode<T>(_ type: T.Type) -> T where T: FixedWidthInteger`             |
| `decode(_ type: UInt16.Type) -> UInt16`         | `decode<T>(_ type: T.Type) -> T where T: FixedWidthInteger`             |
| `decode(_ type: UInt32.Type) -> UInt32`         | `decode<T>(_ type: T.Type) -> T where T: FixedWidthInteger`             |
| `decode(_ type: UInt64.Type) -> UInt64`         | `decode<T>(_ type: T.Type) -> T where T: FixedWidthInteger`             |
| `decode<T>(_ type: T.Type) where T : Decodable` | `decode<T>(_ type: T.Type) -> T where T: BinaryDecodable`               |
| `decode(_ type: String.Type) -> String`         | `decodeString(encoding: String.Encoding, terminator: UInt8?) -> String` |
| No equivalent                                   | `decode(length: Int) -> Data`                                           |
| No equivalent                                   | `peek(length: Int) -> Data`                                             |
