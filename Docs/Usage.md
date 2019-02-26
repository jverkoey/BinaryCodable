# Usage

This document provides a variety of cookbook examples demonstrating usage of the Binary Codable library.

## Decode a binary file from disk

```swift
import BinaryCodable

struct <#DecodableObject#>: BinaryDecodable {

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: <#maxLengthOrNil#>)

    <#decoding logic#>
  }
}

let fileUrl = URL(fileURLWithPath: <#path#>)
let data = try Data(contentsOf: fileUrl)
let decoder = BinaryDataDecoder()

let <#decodedObject#> = try decoder.decode(<#BinaryDecodableType#>.self, from: data)
```

## Encode an object as binary data

```swift
import BinaryCodable

struct <#EncodableObject#>: BinaryEncodable {

  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()

    <#encoding logic#>
  }
}

let object = <#EncodableObject#>
let encoder = BinaryDataEncoder()

let data = try encoder.encode(object)
```

## Decode an object from a socket

```swift
import BinaryCodable
import Socket // E.g. from https://github.com/IBM-Swift/BlueSocket.git

let socket = try Socket.create()
try socket.connect(to: host, port: port)
guard socket.isConnected else {
  return nil
}
var buffer = Data(capacity: socket.readBufferSize)
var bufferedData = BufferedData(reader: AnyBufferedDataSource(read: { length in
  if buffer.count == 0 {
    _ = try socket.read(into: &buffer)
  }
  let pulledData = buffer.prefix(length)
  buffer = buffer.dropFirst(length)
  return pulledData
}, isAtEnd: {
  do {
    return try buffer.isEmpty && !socket.isReadableOrWritable(waitForever: false, timeout: 0).readable
  } catch {
    return true
  }
}))

let decoder = BinaryDataDecoder()
let data = try decoder.decode(<#BinaryDecodableType#>.self, from: bufferedData)
```

## Decode a null-terminated string

```swift
import BinaryCodable

struct <#DecodableObject#>: BinaryDecodable {

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: <#maxLengthOrNil#>)

    let string = try container.decodeString(encoding: .utf8, terminator: 0)
  }
}
```

## Decode a string with a maximum length

```swift
import BinaryCodable

struct <#DecodableObject#>: BinaryDecodable {

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: <#maxLengthOrNil#>)

    var stringContainer = container.nestedContainer(maxLength: <#length#>)
    let string = try stringContainer.decodeString(encoding: .utf8, terminator: nil)
  }
}
```

## Encode a null-terminated string

```swift
import BinaryCodable

struct <#EncodableObject#>: BinaryEncodable {

  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()

    try container.encode("String", encoding: .utf8, terminator: 0)
  }
}
```

## Decode a sequence of bytes

```swift
import BinaryCodable

struct <#DecodableObject#>: BinaryDecodable {

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)

    let data = try container.decode(length: <#T##Int#>)
  }
}
```

## Encode a sequence of bytes

```swift
import BinaryCodable

struct <#EncodableObject#>: BinaryEncodable {

  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()

    try container.encode(sequence: <#T##Sequence#>)
  }
}
```
