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
 A type that can encode itself to an external binary representation.
 */
public protocol BinaryEncodable {

  /**
   Encodes this value into the given encoder.

   - parameter encoder: The encoder to write data to.
   */
  func encode(to encoder: BinaryEncoder) throws
}

/**
 A type that can encode values from a native format into in-memory representations.
 */
public protocol BinaryEncoder {
  /**
   Returns an encoding container appropriate for holding multiple values.

   - returns: A new empty container.
   */
  func container() -> BinaryEncodingContainer
}

/**
 An error that occurs during the binary encoding of a value.
 */
public enum BinaryEncodingError: Error {

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
   An indication that a string was unable to be converted to a Data representation using a given encoding.

   As an associated value, this case contains the context for debugging.
   */
  case incompatibleStringEncoding(Context)
}

/**
 A type that provides a view into an encoder's storage and is used to hold the encoded properties of a encodable type
 sequentially.
 */
public protocol BinaryEncodingContainer {

  /**
   Encodes a String value using the given encoding and with a terminator at the end.

   - parameter value: The value to encode.
   - parameter encoding: The string encoding to use when creating the data representation of the string.
   - parameter terminator: Typically 0. This will be encoded after the string has been encoded. If nil, no terminator
   will be encoded.
   */
  mutating func encode(_ value: String, encoding: String.Encoding, terminator: UInt8?) throws

  /**
   Encodes a value of the given type.

   - parameter value: The value to encode.
   */
  mutating func encode<IntegerType: FixedWidthInteger>(_ value: IntegerType) throws

  /**
   Encodes a value of the given type.

   - parameter value: The value to encode.
   */
  mutating func encode<T>(_ value: T) throws where T: BinaryEncodable

  /**
   Encodes a sequence of bytes.

   - parameter sequence: The sequence of bytes to encode.
   */
  mutating func encode<S>(sequence: S) throws where S: Sequence, S.Element == UInt8
}

// MARK: RawRepresentable extensions

extension RawRepresentable where RawValue: FixedWidthInteger, Self: BinaryEncodable {
  public func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()
    try container.encode(self.rawValue)
  }
}
