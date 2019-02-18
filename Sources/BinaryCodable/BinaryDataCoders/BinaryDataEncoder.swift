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

/**
 An object that encodes instances of a type to binary data.
 */
public struct BinaryDataEncoder {
  public init() {}

  /**
   Returns a binary-encoded representation of a given value.

   - parameter value: The instance to be encoded.
   - returns: `value` encoded in binary form.
   */
  public func encode<T>(_ value: T) throws -> Data where T: BinaryEncodable {
    let encoder = _BinaryDataEncoder()
    try value.encode(to: encoder)
    return encoder.storage.data
  }
}

private final class BinaryDataEncoderStorage {
  var data = Data()
}

private struct _BinaryDataEncoder: BinaryEncoder {
  var storage = BinaryDataEncoderStorage()

  func container() -> BinaryEncodingContainer {
    return BinaryDataEncodingContainer(encoder: self)
  }
}

private struct BinaryDataEncodingContainer: BinaryEncodingContainer {
  let encoder: _BinaryDataEncoder
  init(encoder: _BinaryDataEncoder) {
    self.encoder = encoder
  }

  func encode<IntegerType: FixedWidthInteger>(_ value: IntegerType) throws {
    encoder.storage.data.append(contentsOf: value.bytes)
  }

  func encode<T>(_ value: T) throws where T: BinaryEncodable {
    try value.encode(to: encoder)
  }

  func encode(_ value: String, encoding: String.Encoding, terminator: UInt8?) throws {
    guard let data = value.data(using: encoding) else {
      throw BinaryEncodingError.incompatibleStringEncoding(.init(debugDescription:
        "The string \(value) could not be encoded as data using the encoding \(encoding)."))
    }
    encoder.storage.data.append(contentsOf: data)
    if let terminator = terminator {
      encoder.storage.data.append(terminator)
    }
  }

  func encode<S>(sequence: S) throws where S: Sequence, S.Element == UInt8 {
    encoder.storage.data.append(contentsOf: sequence)
  }
}
