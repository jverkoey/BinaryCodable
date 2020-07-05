// Copyright 2020-present the BinaryCodable authors. All Rights Reserved.
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
import XCTest

private struct MisalignedPacket: BinaryDecodable {
  let twoByteInt: UInt16
  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)
    _ = try container.decode(length: 1)
    self.twoByteInt = try container.decode(UInt16.self)
  }
}

final class MisalignedDecoderTests: XCTestCase {

  func testEmpty() throws {
    // Given
    let packetData: [UInt8] = [0, 3, 0]
    let decoder = BinaryDataDecoder()

    // When
    let packet = try decoder.decode(MisalignedPacket.self, from: packetData)

    // Then
    XCTAssertEqual(packet.twoByteInt, 3)
  }
}
