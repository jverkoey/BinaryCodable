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
 Creates a buffered data view into a given Data object.
 */
public func bufferedData(from data: Data) -> BufferedData {
  return BufferedData(reader: DataBufferedDataSource(data: data))
}

/**
 An interface for lazily reading data from a source.

 A buffered data object allows data to be read into memory on-demand, rather than requiring that all data be represented
 in memory or even available simultaneously. This can be used to read large files from disk or to read data from a
 socket one packet at a time.
 */
public final class BufferedData {
  /**
   Whether the buffer's internal cursor has reached the end of the available content.
   */
  public var isAtEnd: Bool = false

  /**
   - parameter reader: An object that implements mechanisms for retrieving data that can be added to the buffer.
   - parameter initialCapacity: The initial capacity of the internal buffer.
   */
  public init(reader: BufferedDataSource, initialCapacity: Int = 1024) {
    self.buffer = Data(capacity: initialCapacity)
    self.reader = reader
  }

  /**
   Returns up to `maxLength` bytes from the source without modifying the internal buffer cursor.

   Note that it is not guaranteed that `maxLength` bytes will be returned. For example, if the source only has 100 bytes
   of data available but 1000 are requested, then only 100 bytes will be returned.
   */
  public func peek(maxLength: Int) throws -> Data {
    while buffer.count < maxLength {
      guard let data = try reader.read(length: maxLength - buffer.count) else {
        isAtEnd = true
        break
      }
      buffer.append(data)
    }
    return buffer.prefix(maxLength)
  }

  /**
   Returns up to `maxLength` bytes from the source.

   The internal buffer cursor will also be moved forward by the number of returned bytes.

   Note that it is not guaranteed that `maxLength` bytes will be returned. For example, if the source only has 100 bytes
   of data available but 1000 are requested, then only 100 bytes will be returned.
   */
  public func read(maxBytes: Int) throws -> Data {
    while buffer.count < maxBytes {
      guard let data = try reader.read(length: maxBytes - buffer.count) else {
        isAtEnd = true
        break
      }
      buffer.append(data)
    }
    let data = buffer.prefix(maxBytes)
    buffer = buffer[(buffer.startIndex + data.count)...]
    return data
  }

  /**
   Returns bytes from the source until either the delimiter is found or there is no remaining data in the source.

   The internal buffer cursor will also be moved forward by the number of returned bytes.

   Note that it is not guaranteed that `maxLength` bytes will be returned. For example, if the source only has 100 bytes
   of data available but 1000 are requested, then only 100 bytes will be returned.
   */
  public func read(until delimiter: UInt8) throws -> (data: Data, didFindDelimiter: Bool) {
    var indexOfDelimiter = buffer.firstIndex(of: delimiter)
    while indexOfDelimiter == nil {
      guard let data = try reader.read(length: 1) else {
        isAtEnd = true
        break
      }
      if let subIndex = data.firstIndex(of: delimiter) {
        indexOfDelimiter = buffer.startIndex + buffer.count + (subIndex - data.startIndex)
      }
      buffer.append(data)
    }
    if let indexOfDelimiter = indexOfDelimiter {
      let data = buffer.prefix(indexOfDelimiter - buffer.startIndex)
      buffer = buffer[(buffer.startIndex + data.count + 1)...]
      return (data: data, didFindDelimiter: true)
    } else {
      // Couldn't find the delimeter, so read in all of the data.
      let data = buffer
      buffer = buffer[(buffer.startIndex + data.count)...]
      return (data: data, didFindDelimiter: false)
    }
  }

  // Note: the buffer may never decrease in size which can be a concern for long-running applications.
  // This may need to be changed to a ring buffer implementation, where the ring buffer's size is increased only when
  // the number of bytes requested grows larger than the ring buffer.
  // Example implementation in Swift's Sequence:
  // https://github.com/apple/swift/blob/b0fbbb3342c1c2df0753a0fc9b469e9d951adf43/stdlib/public/core/Sequence.swift#L898
  private var buffer: Data
  private let reader: BufferedDataSource
}

/**
 A type that implements mechanisms for reading data from an external source.
 */
public protocol BufferedDataSource {
  /**
   Requests that `length` bytes be read from the external source.

   - parameter length: A recommended number of bytes to return.
   - returns: Approximately `length` bytes, or nil if no more data will ever be available.
   */
  func read(length: Int) throws -> Data?

  /**
   Whether or not the source has reached the end of its data.
   */
  var isAtEnd: Bool { get }
}

/**
 A type-erased buffered data source.
 */
public final class AnyBufferedDataSource: BufferedDataSource {
  public init(read: @escaping (Int) throws -> Data?, isAtEnd: @escaping () -> Bool) {
    self.readCallback = read
    self.isAtEndCallback = isAtEnd
  }

  public func read(length: Int) throws -> Data? {
    return try readCallback(length)
  }

  public var isAtEnd: Bool { return isAtEndCallback() }

  private let readCallback: (Int) throws -> Data?
  private let isAtEndCallback: () -> Bool
}

/**
 A buffered data source for a Data object.
 */
private final class DataBufferedDataSource: BufferedDataSource {
  init(data: Data) {
    self.data = data
  }

  func read(length: Int) throws -> Data? {
    guard !isAtEnd else {
      return nil
    }
    let requestedData = data.prefix(length)
    data = data.dropFirst(length)
    return requestedData
  }

  var isAtEnd: Bool { return data.isEmpty }

  private var data: Data
}
