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

import Foundation

/**
 An object that decodes instances of a type from binary data.
 */
public struct BinaryDataDecoder {
  public init() {}

  /**
   Contextual user-provided information for use during decoding.
   */
  public var userInfo: [BinaryCodingUserInfoKey: Any] = [:]

  /**
   Returns a type you specify decoded from data.

   - parameter type: The type of the instance to be decoded.
   - parameter data: The data from which the instance should be decoded.
   - returns: An instance of `type` decoded from `data`.
   */
  public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: BinaryDecodable {
    return try decode(type, from: bufferedData(from: data))
  }

  /**
   Returns a type you specify decoded from a sequence of bytes.

   - parameter type: The type of the instance to be decoded.
   - parameter bytes: The sequence of bytes from which the instance should be decoded.
   - returns: An instance of `type` decoded from `bytes`.
   */
  public func decode<T>(_ type: T.Type, from bytes: [UInt8]) throws -> T where T: BinaryDecodable {
    return try decode(type, from: bufferedData(from: Data(bytes)))
  }

  public func decode<T>(_ type: T.Type, from bufferedData: BufferedData) throws -> T where T: BinaryDecodable {
    return try T.init(from: _BinaryDataDecoder(bufferedData: bufferedData, userInfo: userInfo))
  }
}

private struct _BinaryDataDecoder: BinaryDecoder {
  var bufferedData: BufferedData
  let userInfo: [BinaryCodingUserInfoKey: Any]
  let container: BinaryDecodingContainer?

  init(bufferedData: BufferedData, userInfo: [BinaryCodingUserInfoKey: Any]) {
    self.bufferedData = bufferedData
    self.userInfo = userInfo
    self.container = nil
  }

  init(bufferedData: BufferedData, userInfo: [BinaryCodingUserInfoKey: Any], container: BinaryDecodingContainer) {
    self.bufferedData = bufferedData
    self.userInfo = userInfo
    self.container = container
  }

  func container(maxLength: Int?) -> BinaryDecodingContainer {
    if let maxLength = maxLength, let container = container as? BinaryDataDecodingContainer, let remainingLength = container.remainingLength {
      return BinaryDataDecodingContainer(bufferedData: bufferedData,
                                         maxLength: min(maxLength, remainingLength),
                                         userInfo: userInfo)
    } else if let container = container as? BinaryDataDecodingContainer, let remainingLength = container.remainingLength {
      return BinaryDataDecodingContainer(bufferedData: bufferedData,
                                         maxLength: remainingLength,
                                         userInfo: userInfo)
    } else {
      return BinaryDataDecodingContainer(bufferedData: bufferedData, maxLength: maxLength, userInfo: userInfo)
    }
  }
}

// This needs to be a class instead of a struct because we hold a mutating reference in decode<T>.
private class BinaryDataDecodingContainer: BinaryDecodingContainer {
  var bufferedData: BufferedData
  var remainingLength: Int?
  let userInfo: [BinaryCodingUserInfoKey: Any]
  init(bufferedData: BufferedData, maxLength: Int?, userInfo: [BinaryCodingUserInfoKey: Any]) {
    self.bufferedData = bufferedData
    self.remainingLength = maxLength
    self.userInfo = userInfo
  }

  var isAtEnd: Bool {
    if let remainingLength = remainingLength {
      return remainingLength == 0 || bufferedData.isAtEnd
    }
    return bufferedData.isAtEnd
  }

  func decode<IntegerType: FixedWidthInteger>(_ type: IntegerType.Type) throws -> IntegerType {
    return try decodeFixedWidthInteger(type)
  }

  func decodeString(encoding: String.Encoding, terminator: UInt8) throws -> String {
    let result = try bufferedData.read(until: terminator)
    guard result.didFindDelimiter else {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription:
        "Unable to find delimiter for string."))
    }
    if let remainingLength = remainingLength {
      self.remainingLength = remainingLength - (result.data.count + 1)
    }
    guard let string = String(data: result.data, encoding: encoding) else {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription:
        "Unable to create string from data with \(encoding) encoding."))
    }
    return string
  }

  func decodeString(encoding: String.Encoding) throws -> String {
    let data = try bufferedData.read(maxBytes: Int.max)
    if let remainingLength = remainingLength {
      self.remainingLength = remainingLength - (data.count + 1)
    }
    guard let string = String(data: data, encoding: encoding) else {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription:
        "Unable to create string from data with \(encoding) encoding."))
    }
    return string
  }

  func decode<T>(_ type: T.Type) throws -> T where T: BinaryDecodable {
    let containedBuffer = BufferedData(reader: AnyBufferedDataSource(read: { recommendedAmount -> Data? in
      let data = try self.pullData(length: recommendedAmount)
      return data.count > 0 ? data : nil
    }, isAtEnd: {
      return self.isAtEnd
    }))
    return try T.init(from: _BinaryDataDecoder(bufferedData: containedBuffer, userInfo: userInfo, container: self))
  }

  func decode(length: Int) throws -> Data {
    let data = try pullData(length: length)
    if data.count != length {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription:
        "Not enough bytes available to decode. Requested \(length), but received \(data.count)."))
    }
    return data
  }

  func nestedContainer(maxLength: Int?) -> BinaryDecodingContainer {
    let length: Int?
    if let remainingLength = remainingLength, let maxLength = maxLength {
      length = min(remainingLength, maxLength)
    } else if let remainingLength = remainingLength {
      length = remainingLength
    } else {
      length = maxLength
    }
    return BinaryDataDecodingContainer(bufferedData: bufferedData, maxLength: length, userInfo: userInfo)
  }

  func pullData(length: Int) throws -> Data {
    let maxLength: Int
    if let remainingLength = remainingLength {
      maxLength = min(remainingLength, length)
    } else {
      maxLength = length
    }
    let data = try bufferedData.read(maxBytes: maxLength)
    if let remainingLength = remainingLength {
      self.remainingLength = remainingLength - data.count
    }
    return data
  }

  func peek(length: Int) throws -> Data {
    let maxLength: Int
    if let remainingLength = remainingLength {
      maxLength = min(remainingLength, length)
    } else {
      maxLength = length
    }
    let data = try bufferedData.peek(maxLength: maxLength)
    if data.count != length {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription:
        "Not enough bytes available to decode. Requested \(length), but received \(data.count)."))
    }
    return data
  }

  func decodeFixedWidthInteger<T>(_ type: T.Type) throws -> T where T: FixedWidthInteger {
    let byteWidth = type.bitWidth / 8
    let bytes = try pullData(length: byteWidth)
    if bytes.count < byteWidth {
      throw BinaryDecodingError.dataCorrupted(.init(debugDescription:
        "Not enough data to create a a type of \(type). Needed: \(byteWidth). Received: \(bytes.count)."))
    }
    let value = Data(bytes).withUnsafeBytes { (ptr: UnsafePointer<T>) -> T in
      return ptr.pointee
    }
    return value
  }
}
