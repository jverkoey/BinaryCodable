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
  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)
    let payloadLength = try container.decode(UInt32.self)
    self.data = try container.decode(length: Int(payloadLength))
  }
}

final class ArrayDecoderTests: XCTestCase {

  func testEmpty() throws {
    // Given
    let packetData: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0]
    let decoder = BinaryDataDecoder()

    // When
    let packets = try decoder.decode([Packet].self, from: packetData)

    // Then
    XCTAssertEqual(packets.map { [UInt8]($0.data) }, [[], []])
  }

  func testOneByte() throws {
    // Given
    let packetData: [UInt8] = [1, 0, 0, 0, 127, 1, 0, 0, 0, 32]
    let decoder = BinaryDataDecoder()

    // When
    let packets = try decoder.decode([Packet].self, from: packetData)

    // Then
    XCTAssertEqual(packets.map { [UInt8]($0.data) }, [[127], [32]])
  }

  func testMultipleByte() throws {
    // Given
    let packetData: [UInt8] = [5, 0, 0, 0, 127, 32, 48, 12, 10, 4, 0, 0, 0, 10, 15, 0, 255]
    let decoder = BinaryDataDecoder()

    // When
    let packets = try decoder.decode([Packet].self, from: packetData)

    // Then
    XCTAssertEqual(packets.map { [UInt8]($0.data) }, [[127, 32, 48, 12, 10], [10, 15, 0, 255]])
  }
}
