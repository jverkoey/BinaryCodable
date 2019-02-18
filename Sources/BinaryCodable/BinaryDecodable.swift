// Copyright 2019-present the MySqlConnector authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

// Note: the types described below are based off - but distinct from - Swift's Codable family of APIs.

/**
 A type that can decode itself from an external binary representation.
 */
public protocol BinaryDecodable {

  /**
   Creates a new instance by decoding from the given binary decoder.

   - parameter decoder: The binary decoder to decode the type from.
   - throws: if reading from the binary decoder fails, or if the data read is corrupted or otherwise invalid.
   */
  init(from decoder: BinaryDecoder) throws
}

/**
 A type that can decode values from a binary format into in-memory representations.
 */
public protocol BinaryDecoder {
  /**
   Any contextual information set by the user for encoding.
   */
  var userInfo: [BinaryCodingUserInfoKey: Any] { get }

  /**
   Returns the data stored in this decoder as represented in a container with an optional maximum length.

   - parameter maxLength: The maximum number of bytes that this container is allowed to decode up to. If nil, then
   this container is able to read an infinite number of bytes.
   - returns: A container view into this decoder.
   */
  func container(maxLength: Int?) -> BinaryDecodingContainer
}

/**
 An error that occurs during the binary decoding of a value.
 */
public enum BinaryDecodingError: Error {

  /**
   The context in which the error occurred.
   */
  public struct Context {

    /**
     A description of what went wrong, for debugging purposes.
     */
    public let debugDescription: String

    /**
     Creates a new context with the given description of what went wrong.

     - parameter debugDescription: A description of what went wrong, for debugging purposes.
     */
    public init(debugDescription: String) {
      self.debugDescription = debugDescription
    }
  }

  /**
   An indication that the data is corrupted or otherwise invalid.

   As an associated value, this case contains the context for debugging.
   */
  case dataCorrupted(Context)
}

/**
 A type that provides a view into a decoder's storage and is used to hold the encoded properties of a decodable type
 sequentially.
 */
public protocol BinaryDecodingContainer {

  /**
   A Boolean value indicating whether there are no more elements left to be decoded in the container.
   */
  var isAtEnd: Bool { get }

  /**
   Decodes a String value using the given encoding up until a given delimiter is encountered.

   - parameter encoding: The string encoding to use when creating the string representation from the binary data.
   - parameter terminator: Typically 0. The string will stop being decoded once the terminator is encountered.
   - returns: The decoded String value.
   */
  mutating func decodeString(encoding: String.Encoding, terminator: UInt8) throws -> String

  /**
   Decodes a String value using the given encoding up until the end of the available data.

   - parameter encoding: The string encoding to use when creating the string representation from the binary data.
   - returns: The decoded String value.
   */
  mutating func decodeString(encoding: String.Encoding) throws -> String

  /**
   Decodes a value of the given type.

   - parameter type: The type of value to decode.
   - returns: A value of the requested type.
   */
  mutating func decode<IntegerType: FixedWidthInteger>(_ type: IntegerType.Type) throws -> IntegerType

  /**
   Decodes a value of the given type.

   - parameter type: The type of value to decode.
   - returns: A value of the requested type.
   */
  mutating func decode<T>(_ type: T.Type) throws -> T where T: BinaryDecodable

  /**
   Decodes a specific number of bytes.

   - parameter length: The number of bytes to decode.
   - returns: A Data representation of the decoded bytes.
   */
  mutating func decode(length: Int) throws -> Data

  /**
   Reads `length` bytes without affecting the `decode` cursor.

   - parameter length: The number of bytes to peek ahead.
   - returns: `length` bytes read from the current `decode` cursor position.
   */
  mutating func peek(length: Int) throws -> Data

  /**
   Creates a nested container, optionally with a maximum number of bytes.

   - parameter maxLength: The maximum number of bytes that the returned container is allowed to decode. If nil, then the
   returned container is able to read all bytes that are readable by this container.
   - returns: A decoding container view into `self`.
   */
  mutating func nestedContainer(maxLength: Int?) -> BinaryDecodingContainer
}

// MARK: RawRepresentable extensions

extension RawRepresentable where RawValue: FixedWidthInteger, Self: BinaryDecodable {
  public init(from decoder: BinaryDecoder) throws {
    let byteWidth = RawValue.bitWidth / 8
    var container = decoder.container(maxLength: byteWidth)
    let decoded = try container.decode(RawValue.self)
    guard let value = Self(rawValue: decoded) else {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription:
        "Cannot initialize \(Self.self) from invalid \(RawValue.self) value \(decoded)"))
    }
    self = value
  }
}
