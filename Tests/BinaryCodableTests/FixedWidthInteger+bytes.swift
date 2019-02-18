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

import XCTest
@testable import BinaryCodable

final class Tests: XCTestCase {

  func testUInt8IsOneByte() {
    // Given
    let value: UInt8 = 0x12

    // When
    let bytes = value.bytes

    // Then
    XCTAssertEqual(bytes, [0x12])
  }

  func testUInt16IsTwoBytesInLittleEndian() {
    // Given
    let value: UInt16 = 0x3412

    // When
    let bytes = value.bytes

    // Then
    XCTAssertEqual(bytes, [0x12, 0x34])
  }

  func testUInt32IsFourBytesInLittleEndian() {
    // Given
    let value: UInt32 = 0x78563412

    // When
    let bytes = value.bytes

    // Then
    XCTAssertEqual(bytes, [0x12, 0x34, 0x56, 0x78])
  }

  func testUInt64IsEightBytesInLittleEndian() {
    // Given
    let value: UInt64 = 0x6587099078563412

    // When
    let bytes = value.bytes

    // Then
    XCTAssertEqual(bytes, [0x12, 0x34, 0x56, 0x78, 0x90, 0x09, 0x87, 0x65])
  }

  func testIntDependsOnThePlatform() {
    // Given
    let value: Int = 0x6587099078563412

    // When
    let bytes = value.bytes

    // Then
    XCTAssertEqual(bytes, [0x12, 0x34, 0x56, 0x78, 0x90, 0x09, 0x87, 0x65])
  }
}
