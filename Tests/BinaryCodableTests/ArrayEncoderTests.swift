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

private struct Packet: BinaryEncodable {
  let data: Data

  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()
    try container.encode(UInt32(data.count))
    try container.encode(sequence: data)
  }
}

final class ArrayEncoderTests: XCTestCase {

  func testEmptyLength() throws {
    // Given
    let packets = [Packet(data: Data([])), Packet(data: Data([]))]
    let encoder = BinaryDataEncoder()

    // When
    let packetData = try encoder.encode(packets)

    // Then
    XCTAssertEqual([UInt8](packetData), [0, 0, 0, 0, 0, 0, 0, 0])
  }

  func testOneByte() throws {
    // Given
    let packets = [Packet(data: Data([127])), Packet(data: Data([32]))]
    let encoder = BinaryDataEncoder()

    // When
    let packetData = try encoder.encode(packets)

    // Then
    XCTAssertEqual([UInt8](packetData), [1, 0, 0, 0, 127, 1, 0, 0, 0, 32])
  }

  func testMultipleByte() throws {
    // Given
    let packets = [Packet(data: Data([127, 32, 48, 12, 10])), Packet(data: Data([10, 15, 0, 255]))]
    let encoder = BinaryDataEncoder()

    // When
    let packetData = try encoder.encode(packets)

    // Then
    XCTAssertEqual([UInt8](packetData), [5, 0, 0, 0, 127, 32, 48, 12, 10, 4, 0, 0, 0, 10, 15, 0, 255])
  }
}
