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

struct Embedded: ProtoDecodable {
  var int32Value: Int32?

  static func fieldDescriptor(for key: CodingKey) -> Field? {
    guard let codingKey = key as? CodingKeys else {
      return nil
    }
    switch codingKey {
    case .int32Value: return Field(number: 1, type: .int32)
    }
  }
}

struct Message: ProtoDecodable {
  var doubleValue: Double?
  var floatValue: Float?
  var int32Value: Int32?
  var int64Value: Int64?
  var uint32Value: UInt32?
  var uint64Value: UInt64?
  var sint32Value: Int32?
  var sint64Value: Int64?
  var fixed32Value: UInt32?
  var fixed64Value: UInt64?
  var boolValue: Bool?
  var stringValue: String?
  var bytesValue: Data?
  var embedded: Embedded?

  var missingValue: Int32?

  static func fieldDescriptor(for key: CodingKey) -> Field? {
    guard let codingKey = key as? CodingKeys else {
      return nil
    }
    switch codingKey {
    case .doubleValue: return Field(number: 1, type: .double)
    case .floatValue: return Field(number: 2, type: .float)
    case .int32Value: return Field(number: 3, type: .int32)
    case .int64Value: return Field(number: 4, type: .int64)
    case .uint32Value: return Field(number: 5, type: .uint32)
    case .uint64Value: return Field(number: 6, type: .uint64)
    case .sint32Value: return Field(number: 7, type: .sint32)
    case .sint64Value: return Field(number: 8, type: .sint64)
    case .fixed32Value: return Field(number: 9, type: .fixed32)
    case .fixed64Value: return Field(number: 10, type: .fixed64)
    case .boolValue: return Field(number: 13, type: .bool)
    case .stringValue: return Field(number: 14, type: .string)
    case .bytesValue: return Field(number: 15, type: .bytes)
    case .embedded: return Field(number: 16, type: .embedded(Embedded.self))
    case .missingValue: return Field(number: 20, type: .int32)
    }
  }
}
