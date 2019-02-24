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

struct Message: ProtoDecodable {
  // Intentionally shown here unordered.
  var value1: Int32 = 0
  var value4: Float = 0
  var value2: UInt32 = 0
  var value3: Int32 = 0
  var value5: UInt32 = 0
  var value6: UInt64 = 0

  static func fieldDescriptor(for key: CodingKey) -> Field? {
    guard let codingKey = key as? CodingKeys else {
      return nil
    }
    switch codingKey {
    case .value1: return Field(number: 1, type: .int32)
    case .value2: return Field(number: 2, type: .uint32)
    case .value3: return Field(number: 3, type: .sint32)
    case .value4: return Field(number: 4, type: .float)
    case .value5: return Field(number: 5, type: .fixed32)
    case .value6: return Field(number: 6, type: .fixed64)
    }
  }
}
