// Copyright 2019-present the BinaryCodable authors. All Rights Reserved.
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

import BinaryCodable
import Foundation

/**
 This is a hypothetical binary codable protobuf implementation.

 Documentation: https://developers.google.com/protocol-buffers/docs/encoding
 */
struct ProtoMessage: BinaryDecodable, Equatable {
  let fieldNumber: UInt64
  enum Value: Equatable {
    case varint(rawValue: UInt64)
    case lengthDelimited(data: Data)
    case fixed32(rawValue: UInt32)
    case fixed64(rawValue: UInt64)
  }
  let value: Value

  init(fieldNumber: UInt64, value: Value) {
    self.fieldNumber = fieldNumber
    self.value = value
  }

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)

    let key = try container.decode(VarInt.self)

    let lowerBits = UInt8(key.rawValue & 0b00000111)
    guard let wireType = ValueType(rawValue: lowerBits) else {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription: "Unknown value type \(lowerBits)"))
    }

    self.fieldNumber = key.rawValue >> 3

    switch wireType {
    case .varint: self.value = try .varint(rawValue: container.decode(VarInt.self).rawValue)
    case .lengthDelimited: self.value = try .lengthDelimited(data: container.decode(LengthDelimited.self).data)
    case .fixed32: self.value = try .fixed32(rawValue: container.decode(UInt32.self))
    case .fixed64: self.value = try .fixed64(rawValue: container.decode(UInt64.self))
    }
  }

  private enum ValueType: UInt8 {
    case varint = 0
    case fixed64 = 1
    case lengthDelimited = 2
    case fixed32 = 5
  }
}

struct VarInt: BinaryDecodable {
  let rawValue: UInt64
  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)

    let msb = UInt8(0b10000000)
    let lowerbits = UInt8(0b01111111)
    var value: UInt64 = 0
    var byte: UInt8
    var shiftAmount: Int = 0
    repeat {
      byte = try container.decode(UInt8.self)
      value |= UInt64(byte & lowerbits) << shiftAmount
      shiftAmount += 7
    } while (byte & msb) == msb
    self.rawValue = value
  }
}

struct LengthDelimited: BinaryDecodable {
  let data: Data
  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)

    let length = try container.decode(VarInt.self)
    self.data = try container.decode(length: Int(length.rawValue))
  }
}
