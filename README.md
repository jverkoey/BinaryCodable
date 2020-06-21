# Binary Codable

Binary Codable provides Swift Codable-like interfaces for converting types to and from binary representations.

Binary Codable is optimized for reading and writing blocks of binary data as a stream of bytes. This makes Binary Codable useful for network protocols, binary file formats, and other forms of tightly-packed binary information.

This is not an official Google product.

- [Features](#features)
- [Known usage in the wild](#known-usage-in-the-wild)
- [Introduction](Docs/)
- [Cookbook](Docs/Usage.md)
  - [Decode a binary file from disk](Docs/Usage.md#decode-a-binary-file-from-disk)
  - [Encode an object as binary data](Docs/Usage.md#encode-an-object-as-binary-data)
  - [Decode an object from a socket](Docs/Usage.md#decode-an-object-from-a-socket)
  - [Decode a null-terminated string](Docs/Usage.md#decode-a-null-terminated-string)
  - [Decode a string with a maximum length](Docs/Usage.md#decode-a-string-with-a-maximum-length)
  - [Encode a null-terminated string](Docs/Usage.md#encode-a-null-terminated-string)
  - [Decode a sequence of bytes](Docs/Usage.md#decode-a-sequence-of-bytes)
  - [Encode a sequence of bytes](Docs/Usage.md#encode-a-sequence-of-bytes)
- [Requirements](#requirements)
- [Supported technologies](#supported-technologies)
- [License](#license)

## Features

- [x] Encode from Swift types to `Data`.
- [x] Decode from `Data` to Swift types.
- [x] Efficiently encode/decode large blocks of arbitrary data.
- [x] Lazy decoding (read bytes from a source only as they're needed).
- [x] Encode and decode fixed-width integer types.
- [x] Encode and decode strings with or without terminators.
- [x] Cap decoding containers to a maximum length.

## Known usage in the wild

- [BinaryCookies](https://github.com/interstateone/BinaryCookies): Read and write Apple's .binarycookies files.
- [MySqlConnector](https://github.com/jverkoey/MySqlConnector): A pure Swift implementation of the MySql client/server protocol.

## Supported technologies

- iOS 13.0+ / macOS 10.15+
- Xcode 11.5+
- Ubuntu 16.04
- Swift 5.2

## License

BinaryCodable is released under the Apache 2.0 license. [See LICENSE](LICENSE) for more details.
