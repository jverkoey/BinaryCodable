# BinaryCodable Usage

## Comparison of Swift 4 Codable interfaces

| Swift Codable | Binary Codable   |
|:--------------|:-----------------|
| Codable       | BinaryCodable    |
| Encodable     | BinaryEncodable  |
| Decodable     | BinaryDecodable  |

## Simple Decoding example

In this example we'll decode a hypothetical network packet into a Swift type. The hypothetical network packet will consist of a length followed by `length` bytes of arbitrary data.

```swift
struct Packet: BinaryDecodable {
  let data: Data

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)
    let payloadLength = try container.decode(UInt32.self)
    self.data = try container.decode(length: Int(payloadLength))
  }
}

let packetData: [UInt8] = [1, 0, 0, 0, 127]
let decoder = BinaryDataDecoder()

let packet = try decoder.decode(Packet.self, from: packetData)

print(packet.data)
# [127]
```

## Simple Encoding example

In this example we'll decode the same hypothetical network packet from a Swift type into Data.

```swift
struct Packet: BinaryEncodable {
  let data: Data

  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()
    try container.encode(UInt32(data.count))
    try container.encode(sequence: data)
  }
}

let packet = Packet(data: Data([127]))
let encoder = BinaryDataEncoder()

let packetData = try encoder.encode(packet)

print(packetData)
# [1, 0, 0, 0, 127]
```
