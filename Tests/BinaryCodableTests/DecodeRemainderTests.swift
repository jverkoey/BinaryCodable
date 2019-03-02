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
import XCTest

private struct Packet: BinaryDecodable {
  let data: Data
  let decoderWasAtEnd: Bool
  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)
    self.data = try container.decodeRemainder()
    self.decoderWasAtEnd = container.isAtEnd
  }
}

private struct NestedPacket: BinaryDecodable {
  let data: Data
  let decoderWasAtEnd: Bool
  let nestedDecoderWasAtEnd: Bool
  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)
    var nestedContainer = container.nestedContainer(maxLength: 2)
    self.data = try nestedContainer.decodeRemainder()
    self.decoderWasAtEnd = container.isAtEnd
    self.nestedDecoderWasAtEnd = nestedContainer.isAtEnd
  }
}

final class DecodeRemainderTests: XCTestCase {

  func testDecodesAllBytes() throws {
    // Given
    let packetData: [UInt8] = [0, 0, 0, 0]
    let decoder = BinaryDataDecoder()

    // When
    let packet = try decoder.decode(Packet.self, from: packetData)

    // Then
    XCTAssertEqual([UInt8](packet.data), [0, 0, 0, 0])
    XCTAssertTrue(packet.decoderWasAtEnd)
  }

  func testDecodesAllContainerBytes() throws {
    // Given
    let packetData: [UInt8] = [0, 0, 0, 0]
    let decoder = BinaryDataDecoder()

    // When
    let packet = try decoder.decode(NestedPacket.self, from: packetData)

    // Then
    XCTAssertEqual([UInt8](packet.data), [0, 0])
    XCTAssertFalse(packet.decoderWasAtEnd)
    XCTAssertTrue(packet.nestedDecoderWasAtEnd)
  }
}
