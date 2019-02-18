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

import BinaryCodable
import XCTest

private struct Packet: BinaryEncodable {
  let data: Data

  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()
    try container.encode(UInt32(data.count))
    try container.encode(sequence: data)
  }
}

final class BinaryDataEncoderTests: XCTestCase {

  func testEmptyLength() throws {
    // Given
    let packet = Packet(data: Data([]))
    let encoder = BinaryDataEncoder()

    // When
    let packetData = try encoder.encode(packet)

    // Then
    XCTAssertEqual([UInt8](packetData), [0, 0, 0, 0])
  }

  func testOneByte() throws {
    // Given
    let packet = Packet(data: Data([127]))
    let encoder = BinaryDataEncoder()

    // When
    let packetData = try encoder.encode(packet)

    // Then
    XCTAssertEqual([UInt8](packetData), [1, 0, 0, 0, 127])
  }

  func testMultipleByte() throws {
    // Given
    let packet = Packet(data: Data([127, 32, 48, 12, 10]))
    let encoder = BinaryDataEncoder()

    // When
    let packetData = try encoder.encode(packet)

    // Then
    XCTAssertEqual([UInt8](packetData), [5, 0, 0, 0, 127, 32, 48, 12, 10])
  }
}
