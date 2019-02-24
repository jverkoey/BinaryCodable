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
import Foundation

struct Field {
  let number: Int
  enum FieldType {
    case float
    case double
    case int32
    case int64
    case uint32
    case uint64
    case sint32
    case sint64
    case fixed32
    case fixed64
    case bool
  }
  let type: FieldType
}
typealias FieldDescriptors = [String: Field]

protocol ProtoDecodable: Codable {
  static func fieldDescriptor(for key: CodingKey) -> Field?
}

/**
 This is a hypothetical generated protobuf decoder that supports Swift's Codable interfaces.
 */
struct ProtoDecoder {

  func decode<T: ProtoDecodable>(_ type: T.Type, from data: Data) throws -> T {
    let decoder = try _ProtoDecoder(data: data, fieldDescriptor: T.fieldDescriptor)
    return try T.init(from: decoder)
  }
}

private struct _ProtoDecoder: Decoder {
  var codingPath: [CodingKey] = []
  var userInfo: [CodingUserInfoKey : Any] = [:]
  let mappedMessages: [Int: ProtoMessage]
  let fieldDescriptor: (CodingKey) -> Field?

  init(data: Data, fieldDescriptor: @escaping (CodingKey) -> Field?) throws {
    let decoder = BinaryDataDecoder()
    var mappedMessages: [Int: ProtoMessage] = [:]
    for message in try decoder.decode([ProtoMessage].self, from: data) {
      mappedMessages[Int(message.fieldNumber)] = message
    }
    self.mappedMessages = mappedMessages
    self.fieldDescriptor = fieldDescriptor
  }

  func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    let container = ProtoKeyedDecodingContainer<Key>(decoder: self)
    return KeyedDecodingContainer(container)
  }

  func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    preconditionFailure("Unimplemented")
  }

  func singleValueContainer() throws -> SingleValueDecodingContainer {
    preconditionFailure("Unimplemented")
  }
}

private struct ProtoKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
  var codingPath: [CodingKey] = []
  var allKeys: [Key] = []

  let decoder: _ProtoDecoder
  init(decoder: _ProtoDecoder) {
    self.decoder = decoder
  }

  func contains(_ key: Key) -> Bool {
    guard let fieldDescriptor = decoder.fieldDescriptor(key) else {
      return false
    }
    return decoder.mappedMessages[fieldDescriptor.number] != nil
  }

  func decodeNil(forKey key: Key) throws -> Bool {
    guard let fieldDescriptor = decoder.fieldDescriptor(key) else {
      throw DecodingError.keyNotFound(key, .init(codingPath: codingPath,
                                                 debugDescription: "No field descriptor provided for \(key)."))
    }
    return decoder.mappedMessages[fieldDescriptor.number] == nil
  }

  func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
    return try decodeFixedWidthInteger(UInt8.self, forKey: key) != 0
  }

  func decode(_ type: String.Type, forKey key: Key) throws -> String {
    preconditionFailure("Unimplemented")
  }

  func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
    guard let fieldDescriptor = decoder.fieldDescriptor(key) else {
      throw DecodingError.keyNotFound(key, .init(codingPath: codingPath,
                                                 debugDescription: "No field descriptor provided for \(key)."))
    }
    guard let message = decoder.mappedMessages[fieldDescriptor.number] else {
      throw DecodingError.valueNotFound(type, .init(codingPath: codingPath,
                                                    debugDescription: "No value found for \(key) of type \(type)."))
    }
    switch (fieldDescriptor.type, message.value) {
    case (.double, .fixed64(let value)):
      return Double(bitPattern: value)
    default:
      preconditionFailure("Unimplemented")
    }
  }

  func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
    guard let fieldDescriptor = decoder.fieldDescriptor(key) else {
      throw DecodingError.keyNotFound(key, .init(codingPath: codingPath,
                                                 debugDescription: "No field descriptor provided for \(key)."))
    }
    guard let message = decoder.mappedMessages[fieldDescriptor.number] else {
      throw DecodingError.valueNotFound(type, .init(codingPath: codingPath,
                                                    debugDescription: "No value found for \(key) of type \(type)."))
    }
    switch (fieldDescriptor.type, message.value) {
    case (.float, .fixed32(let value)):
      return Float(bitPattern: value)
    default:
      preconditionFailure("Unimplemented")
    }
  }

  func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
    return try decodeFixedWidthInteger(type, forKey: key)
  }

  private func decodeFixedWidthInteger<T: FixedWidthInteger>(_ type: T.Type, forKey key: Key) throws -> T {
    guard let fieldDescriptor = decoder.fieldDescriptor(key) else {
      throw DecodingError.keyNotFound(key, .init(codingPath: codingPath,
                                                 debugDescription: "No field descriptor provided for \(key)."))
    }
    guard let message = decoder.mappedMessages[fieldDescriptor.number] else {
      throw DecodingError.valueNotFound(T.self, .init(codingPath: codingPath,
                                                      debugDescription: "No value found for \(key) of type \(type)."))
    }
    switch (fieldDescriptor.type, message.value) {
    case (.int32, .varint(let rawValue)),
         (.int64, .varint(let rawValue)),
         (.uint32, .varint(let rawValue)),
         (.uint64, .varint(let rawValue)),
         (.bool, .varint(let rawValue)): return T.init(clamping: rawValue)
    case (.sint32, .varint(let rawValue)): return T.init(clamping: Int32(rawValue >> 1) ^ -Int32(rawValue & 1))
    case (.sint64, .varint(let rawValue)): return T.init(clamping: Int64(rawValue >> 1) ^ -Int64(rawValue & 1))
    case (.fixed32, .fixed32(let rawValue)): return T.init(clamping: rawValue)
    case (.fixed64, .fixed64(let rawValue)): return T.init(clamping: rawValue)
    default:
      preconditionFailure("Unimplemented")
    }
  }

  func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
    preconditionFailure("Unimplemented")
  }

  func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    preconditionFailure("Unimplemented")
  }

  func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
    preconditionFailure("Unimplemented")
  }

  func superDecoder() throws -> Decoder {
    preconditionFailure("Unimplemented")
  }

  func superDecoder(forKey key: Key) throws -> Decoder {
    preconditionFailure("Unimplemented")
  }


}
