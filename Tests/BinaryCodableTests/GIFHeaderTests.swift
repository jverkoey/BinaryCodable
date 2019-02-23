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

// https://www.fileformat.info/format/gif/egff.htm#GIF-DMYID.3.1.1
// typedef struct _GifHeader
// {
//   // Header
//   BYTE Signature[3];     /* Header Signature (always "GIF") */
//   BYTE Version[3];       /* GIF format version("87a" or "89a") */
//   // Logical Screen Descriptor
//   WORD ScreenWidth;      /* Width of Display Screen in Pixels */
//   WORD ScreenHeight;     /* Height of Display Screen in Pixels */
//   BYTE Packed;           /* Screen and Color Map Information */
//   BYTE BackgroundColor;  /* Background Color Index */
//   BYTE AspectRatio;      /* Pixel Aspect Ratio */
// } GIFHEAD;

struct GIFHeader: BinaryCodable {
  enum Version: String, BinaryCodable {
    case gif87a = "87a"
    case gif89a = "89a"
  }
  let version: Version

  let screenWidth: UInt16
  let screenHeight: UInt16

  struct Packed: OptionSet, BinaryCodable {
    let rawValue: UInt8
    static let globalColorTableSizeMask = Packed(rawValue: 0b00000111)
    static let colorTableSort           = Packed(rawValue: 0b00001000)
    static let colorResolutionMask      = Packed(rawValue: 0b01110000)
    static let globalColorTable         = Packed(rawValue: 0b10000000)
  }
  let numberOfGlobalColorTableEntries: Int
  let colorTableEntriesSortedByImportance: Bool
  let colorResolution: UInt8
  let hasGlobalColorTable: Bool

  let backgroundColorIndex: UInt8
  let aspectRatio: UInt8

  init(version: Version, width: UInt16, height: UInt16, numberOfGlobalColorTableEntries: Int, colorTableEntriesSortedByImportance: Bool, colorResolution: UInt8, hasGlobalColorTable: Bool, backgroundColorIndex: UInt8, aspectRatio: UInt8) {
    self.version = version
    self.screenWidth = width
    self.screenHeight = height
    self.numberOfGlobalColorTableEntries = numberOfGlobalColorTableEntries
    self.colorTableEntriesSortedByImportance = colorTableEntriesSortedByImportance
    self.colorResolution = colorResolution
    self.hasGlobalColorTable = hasGlobalColorTable
    self.backgroundColorIndex = backgroundColorIndex
    self.aspectRatio = aspectRatio
  }

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: 13)

    let signature = try container.decode(length: 3)
    if signature != Data("GIF".utf8) {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription: "Missing GIF header."))
    }

    var versionContainer = container.nestedContainer(maxLength: 3)
    self.version = try versionContainer.decode(Version.self)

    self.screenWidth = try container.decode(type(of: screenWidth))
    self.screenHeight = try container.decode(type(of: screenHeight))

    let packed = try container.decode(Packed.self)
    let globalColorTableSize = packed.intersection(.globalColorTableSizeMask).rawValue
    self.numberOfGlobalColorTableEntries = 1 << (Int(globalColorTableSize) + 1)
    self.colorTableEntriesSortedByImportance = packed.intersection(.colorTableSort).rawValue != 0
    self.colorResolution = (packed.intersection(.colorResolutionMask).rawValue >> 4) + 1
    self.hasGlobalColorTable = packed.intersection(.globalColorTable).rawValue != 0

    self.backgroundColorIndex = try container.decode(type(of: backgroundColorIndex))
    self.aspectRatio = try container.decode(type(of: aspectRatio))
  }

  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()

    try container.encode("GIF", encoding: .ascii, terminator: nil)
    try container.encode(version)
    try container.encode(screenWidth)
    try container.encode(screenHeight)

    var packed = Packed()
    packed.formUnion(Packed(rawValue: UInt8((numberOfGlobalColorTableEntries >> 1) - 1)))
    if colorTableEntriesSortedByImportance {
      packed.insert(.colorTableSort)
    }
    packed.formUnion(Packed(rawValue: (colorResolution - 1) << 4))
    if hasGlobalColorTable {
      packed.insert(.globalColorTable)
    }
    try container.encode(packed)

    try container.encode(backgroundColorIndex)
    try container.encode(aspectRatio)
  }
}

final class GIFDecoderTests: XCTestCase {

  func testDecoding() throws {
    // Given
    let underConstructionUrl = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appendingPathComponent("under_construction.gif")
    let data = try Data(contentsOf: underConstructionUrl)
    let decoder = BinaryDataDecoder()

    // When
    let header = try decoder.decode(GIFHeader.self, from: data)

    // Then
    XCTAssertEqual(header.version, .gif89a)

    XCTAssertEqual(header.screenWidth, 46)
    XCTAssertEqual(header.screenHeight, 37)

    XCTAssertEqual(header.numberOfGlobalColorTableEntries, 4)
    XCTAssertFalse(header.colorTableEntriesSortedByImportance)
    XCTAssertEqual(header.colorResolution, 8)
    XCTAssertTrue(header.hasGlobalColorTable)

    XCTAssertEqual(header.backgroundColorIndex, 0)
    XCTAssertEqual(header.aspectRatio, 0)
  }

  func testEncoding() throws {
    // Given
    let header = GIFHeader(version: .gif89a, width: 46, height: 37, numberOfGlobalColorTableEntries: 4, colorTableEntriesSortedByImportance: false, colorResolution: 8, hasGlobalColorTable: true, backgroundColorIndex: 0, aspectRatio: 0)
    let encoder = BinaryDataEncoder()

    // When
    let encodedData = try encoder.encode(header)

    // Then
    let underConstructionUrl = URL(fileURLWithPath: #file)
      .deletingLastPathComponent()
      .appendingPathComponent("under_construction.gif")
    let data = try Data(contentsOf: underConstructionUrl)
    XCTAssertEqual([UInt8](encodedData), [UInt8](data.prefix(13)))
  }
}
