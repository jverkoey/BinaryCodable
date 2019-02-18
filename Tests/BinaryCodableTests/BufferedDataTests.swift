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

final class BufferedDataTests: XCTestCase {

  func testInitiallyPullsFromStart() throws {
    // Given
    let data = Data([UInt8](0..<255))
    let lazyData = bufferedData(from: data)

    // When
    let readData = try lazyData.read(maxBytes: 100)

    // Then
    XCTAssertEqual([UInt8](readData), [UInt8](0..<100))
  }

  func testSuccessivePullsUseCursor() throws {
    // Given
    let data = Data([UInt8](0..<255))
    let lazyData = bufferedData(from: data)

    // When
    let readData1 = try lazyData.read(maxBytes: 25)
    let readData2 = try lazyData.read(maxBytes: 25)
    let readData3 = try lazyData.read(maxBytes: 25)

    // Then
    XCTAssertEqual([UInt8](readData1), [UInt8](0..<25))
    XCTAssertEqual([UInt8](readData2), [UInt8](25..<50))
    XCTAssertEqual([UInt8](readData3), [UInt8](50..<75))
  }

  func testPullingMoreThanAvailableOnlyPullsWhatsAvailable() throws {
    // Given
    let data = Data([UInt8](0..<255))
    let lazyData = bufferedData(from: data)

    // When
    let readData = try lazyData.read(maxBytes: 1000)

    // Then
    XCTAssertEqual([UInt8](readData), [UInt8](0..<255))
  }
}
