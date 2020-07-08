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

private struct MisalignedUInt16Packet: BinaryDecodable {
  let twoByteInt: UInt16
  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)
    _ = try container.decode(length: 1)
    self.twoByteInt = try container.decode(UInt16.self)
  }
}

private struct MisalignedFloatPacket: BinaryDecodable {
  let fourByteFloat: Float
  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)
    _ = try container.decode(length: 1)
    self.fourByteFloat = try container.decode(Float.self)
  }
}

final class MisalignedDecoderTests: XCTestCase {

  func testUInt16() throws {
    // Given
    let packetData: [UInt8] = [0, 3, 0]
    let decoder = BinaryDataDecoder()

    // When
    let packet = try decoder.decode(MisalignedUInt16Packet.self, from: packetData)

    // Then
    XCTAssertEqual(packet.twoByteInt, 3)
  }

  func testFloat() throws {
    // Given
    let packetData: [UInt8] = [0, 0, 0, 0x80, 0x3f]
    let decoder = BinaryDataDecoder()

    // When
    let packet = try decoder.decode(MisalignedFloatPacket.self, from: packetData)

    // Then
    XCTAssertEqual(packet.fourByteFloat, 1.0, accuracy: 0.001)
  }
}
