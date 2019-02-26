# Binary Codable Documentation

- [Introduction](#introduction)
  - [Decoding](#decoding)
  - [Encoding](#encoding)
- [Comparison to Swift Codable](ComparisonToSwiftCodable.md)

## Introduction

Note: while it will be helpful to have an understanding of Swift's Codable family of interfaces, Binary Codable is a separate implementation optimized for binary representations and should be understood as familiar, yet distinct.

This introductory guide will explore how one might read and write GIF files by implementing the [GIF file format](https://www.fileformat.info/format/gif/egff.htm#GIF-DMYID.2) using Binary Codable.

### Decoding

A GIF file starts with a header. Let's start by defining this type:

```swift
struct GIFHeader {
}
```

We'll implement decoding first because it's easier to test our code against an existing gif file.

```swift
// New
import BinaryCodable

// Modified
struct GIFHeader: BinaryDecodable {
  // New
  init(from decoder: BinaryDecoder) throws {
  }
}

// Use these three lines of code to debug your implementation as we go along.
let data = try Data(contentsOf: gifUrl)
let decoder = BinaryDataDecoder()
let header = try decoder.decode(GIFHeader.self, from: data)
```

Aside: the biggest distinction between Swift Codable and Binary Codable is that we do not get encoding and decoding implementations for complex types for free. This is presently by design, though there are [opportunities for improving this in the future](https://github.com/jverkoey/BinaryCodable/issues/4). That being said, Binary Codable does provide automatic implementations for RawRepresentable types (namely enums with raw values).

Like Swift Codable, we first create a sequential container.

Note: the container variable needs to be a `var` because we will mutate it.

```swift
import BinaryCodable

struct GIFHeader: BinaryDecodable {
  init(from decoder: BinaryDecoder) throws {
    // New
    // A nil maxLength means we don't know how long this container is.
    var container = decoder.container(maxLength: nil)
  }
}
```

We can now use our container to decode values from the external representation. But first, let's take a look at the [GIF header](https://www.fileformat.info/format/gif/egff.htm#GIF-DMYID.3.1.1) specification:

```c
typedef struct _GifHeader
{
  // Header
  BYTE Signature[3];     /* Header Signature (always "GIF") */
  BYTE Version[3];       /* GIF format version("87a" or "89a") */
  // Logical Screen Descriptor
  WORD ScreenWidth;      /* Width of Display Screen in Pixels */
  WORD ScreenHeight;     /* Height of Display Screen in Pixels */
  BYTE Packed;           /* Screen and Color Map Information */
  BYTE BackgroundColor;  /* Background Color Index */
  BYTE AspectRatio;      /* Pixel Aspect Ratio */
} GIFHEAD;
```

If we count up the bytes in the header we'll see that there are exactly 13 bytes. Let's make our implementation a bit safer by coding this known size into our container.

```swift
import BinaryCodable

struct GIFHeader: BinaryDecodable {
  init(from decoder: BinaryDecoder) throws {
    // Modified
    var container = decoder.container(maxLength: 13)
  }
}
```

Time to start decoding some bytes!

The first three bytes are the GIF's signature, which is always "GIF". Let's decode those three bytes and consider any value other than "GIF" as a decoding error.

```swift
import BinaryCodable

struct GIFHeader: BinaryDecodable {
  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: 13)

    // New
    let signature = try container.decode(length: 3)
    if signature != Data("GIF".utf8) {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription: "Missing GIF header."))
    }
  }
}
```

The next three bytes are the GIF format version, which will either by 87a or 89a. We could use the same approach as above to decode these next three bytes, but that would require we implement validation for the possible versions. Instead, let's let Swift's enum type do the validation for us.

In the example below we:

1. Define a `Version` enum type with the GIF format versions we're aware of. The enum type needs to be a raw representable type. It also needs to conform to `BinaryDecodable`.
2. Define a property of this type for future reference.
3. Create a nested container with a maximum length of 3 bytes.
4. Decode our version type using the nested container.

```swift
import BinaryCodable

struct GIFHeader: BinaryDecodable {
  // New
  enum Version: String, BinaryDecodable {
    case gif87a = "87a"
    case gif89a = "89a"
  }
  let version: Version

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: 13)

    let signature = try container.decode(length: 3)
    if signature != Data("GIF".utf8) {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription: "Missing GIF header."))
    }

    // New
    var versionContainer = container.nestedContainer(maxLength: 3)
    self.version = try versionContainer.decode(Version.self)
  }
}
```

By using an enum we've accomplished two things:

1. Clearly defined the expected values for this field.
2. Added error handling for unexpected values: if a GIF format version other than 87a or 89a is encountered, a `BinaryDecodingError.dataCorrupted` exception will be thrown.

Note: we can also apply this pattern to `signature` using a single-value String enum. Try cleaning up your implementation accordingly!

Let's move on to the next part of the header: the width and height. These two 16-bit values are relatively easy to decode. We'll also store these values because they'll be useful later.

```swift
import BinaryCodable

struct GIFHeader: BinaryDecodable {
  enum Version: String, BinaryDecodable {
    case gif87a = "87a"
    case gif89a = "89a"
  }
  let version: Version

  // New
  let screenWidth: UInt16
  let screenHeight: UInt16

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: 13)

    let signature = try container.decode(length: 3)
    if signature != Data("GIF".utf8) {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription: "Missing GIF header."))
    }

    var versionContainer = container.nestedContainer(maxLength: 3)
    self.version = try versionContainer.decode(Version.self)

    // New
    self.screenWidth = try container.decode(UInt16.self)
    self.screenHeight = try container.decode(UInt16.self)
  }
}
```

The next byte in the header is the `packed` parameter which is defined as follows:

> Packed contains the following four subfields of data:
> 
>     Bits 0-2:  Size of the Global Color Table
>     Bit 3:     Color Table Sort Flag
>     Bits 4-6:  Color Resolution
>     Bit 7:     Global Color Table Flag

We can again capture this information in a Swift data type, but this time as an `OptionSet`. This next part gets a little more complicated due to bit unpacking; there's [room for improvement](https://github.com/jverkoey/BinaryCodable/issues/5) here.

```swift
import BinaryCodable

struct GIFHeader: BinaryDecodable {
  enum Version: String, BinaryDecodable {
    case gif87a = "87a"
    case gif89a = "89a"
  }
  let version: Version

  let screenWidth: UInt16
  let screenHeight: UInt16

  // New
  struct Packed: OptionSet, BinaryDecodable {
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

  init(from decoder: BinaryDecoder) throws {
    var container = decoder.container(maxLength: 13)

    let signature = try container.decode(length: 3)
    if signature != Data("GIF".utf8) {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription: "Missing GIF header."))
    }

    var versionContainer = container.nestedContainer(maxLength: 3)
    self.version = try versionContainer.decode(Version.self)

    self.screenWidth = try container.decode(type(of: self.screenWidth))
    self.screenHeight = try container.decode(type(of: self.screenHeight))

    // New
    let packed = try container.decode(Packed.self)
    let globalColorTableSize = packed.intersection(.globalColorTableSizeMask).rawValue
    self.numberOfGlobalColorTableEntries = 1 << (Int(globalColorTableSize) + 1)
    self.colorTableEntriesSortedByImportance = packed.intersection(.colorTableSort).rawValue != 0
    self.colorResolution = (packed.intersection(.colorResolutionMask).rawValue >> 4) + 1
    self.hasGlobalColorTable = packed.intersection(.globalColorTable).rawValue != 0
  }
}
```

Phew. Not the prettiest code, but we now have meaningful properties initialized from the packed bits.

The last two values are relatively straightforward:

```swift
import BinaryCodable

struct GIFHeader: BinaryDecodable {
  enum Version: String, BinaryDecodable {
    case gif87a = "87a"
    case gif89a = "89a"
  }
  let version: Version

  let screenWidth: UInt16
  let screenHeight: UInt16

  struct Packed: OptionSet, BinaryDecodable {
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

  // New
  let backgroundColorIndex: UInt8
  let aspectRatio: UInt8

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

    // New
    self.backgroundColorIndex = try container.decode(type(of: backgroundColorIndex))
    self.aspectRatio = try container.decode(type(of: aspectRatio))
  }
}
```

Hurrah! We've implemented a GIF header decoder in Swift using Binary Codable. Implementing the remainder of the GIF specification will be left as an exercise for you.

Now let's add encoding support.

### Encoding

Let's expand on the GIFHeader data type we fleshed out in the preceding section. We'll start by making the type fully BinaryCodable.

Note: I'm leaving the `init(from decoder: BinaryDecoder) throws` implementation out from here on for readability's sake. We'll also need to implement an initailizer so that we can create customized instances of the GIFHeader type.

```swift
import BinaryCodable

struct GIFHeader: BinaryCodable {
  // New (Swift won't generate this automatically)
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

  func encode(to encoder: BinaryEncoder) throws {
  }
}

// Use these three lines of code to debug your implementation as we go along.
let header = GIFHeader(version: .gif89a, width: 46, height: 37, numberOfGlobalColorTableEntries: 4, colorTableEntriesSortedByImportance: false, colorResolution: 8, hasGlobalColorTable: true, backgroundColorIndex: 0, aspectRatio: 0)
let encoder = BinaryDataEncoder()
let encodedData = try encoder.encode(header)
```

Like our decoder, we first need to create a container view. This will let us encode bytes sequentially.

```swift
import BinaryCodable

struct GIFHeader: BinaryCodable {
  func encode(to encoder: BinaryEncoder) throws {
    // New
    var container = encoder.container()
  }
}
```

Encoding the GIF header is straightforward:

```swift
import BinaryCodable

struct GIFHeader: BinaryCodable {
  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()

    // New
    try container.encode("GIF", encoding: .ascii, terminator: nil)
  }
}
```

Encoding our enum requires that we first mark the enum as BinaryCodable as well. We can then easily encode the enum value.

```swift
import BinaryCodable

struct GIFHeader: BinaryCodable {
  // Changed
  enum Version: String, BinaryCodable {
    case gif87a = "87a"
    case gif89a = "89a"
  }
  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()

    try container.encode("GIF", encoding: .ascii, terminator: nil)
    // New
    try container.encode(version)
  }
}
```

Encoding width and height is also straightforward:

```swift
import BinaryCodable

struct GIFHeader: BinaryCodable {
  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()

    try container.encode("GIF", encoding: .ascii, terminator: nil)
    try container.encode(version)
    // New
    try container.encode(screenWidth)
    try container.encode(screenHeight)
  }
}
```

Encoding the packed byte requires some bit-fiddling again and modifying the Packed type to conform to `BinaryCodable`:

```swift
import BinaryCodable

struct GIFHeader: BinaryCodable {
  // Changed
  struct Packed: OptionSet, BinaryCodable

  func encode(to encoder: BinaryEncoder) throws {
    var container = encoder.container()

    try container.encode("GIF", encoding: .ascii, terminator: nil)
    try container.encode(version)
    try container.encode(screenWidth)
    try container.encode(screenHeight)

    // New
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
  }
}
```

But the remainder of the header is straightforward:

```swift
import BinaryCodable

struct GIFHeader: BinaryCodable {
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

    // New
    try container.encode(backgroundColorIndex)
    try container.encode(aspectRatio)
  }
}
```

And that's it! We've now added full binary coding support to our GIFHeader type. Check out the full tested implementation of this documentation in [Tests/BinaryCodableTests/GIFHeaderTests.swift](../Tests/BinaryCodableTests/GIFHeaderTests.swift).
