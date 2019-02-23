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

import XCTest
@testable import BinaryCodable

final class BinaryFloatingPointBytesTests: XCTestCase {

  func testFloatIsFourBytes() {
    // Given
    let value: Float = 3.14159

    // When
    let bytes = value.bytes

    // Then
    XCTAssertEqual(bytes.count, 4)
  }

  func testDoubleIsFourBytes() {
    // Given
    let value: Double = 3.14159

    // When
    let bytes = value.bytes

    // Then
    XCTAssertEqual(bytes.count, 8)
  }
}
