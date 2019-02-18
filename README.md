# Binary Codable

Binary Codable provides Swift Codable-like interfaces for converting types into and from binary representations.

Binary Codable is optimized for reading and writing blocks of binary data as a stream of bytes. This makes Binary Codable useful for network protocols, binary file formats, and other forms of tightly-packed binary information.

This is not an official Google product.

## Features

- [x] Encode from Swift types to `Data`.
- [x] Decode from `Data` to Swift types.
- [x] Efficiently encode/decode large blocks of arbitrary data.
- [x] Lazy decoding (read bytes from a source only as they're needed).
- [x] Encode and decode fixed-width integer types.
- [x] Encode and decode strings with or without terminators.
- [x] Cap decoding containers to a maximum length.

## Requirements

- Swift 4.2.2+

## Supported technologies

- iOS 12.0+ / macOS 10.12+
- Xcode 10.1+
- Ubuntu 16.04

## License

BinaryCodable is released under the Apache 2.0 license. [See LICENSE](LICENSE) for more details.
