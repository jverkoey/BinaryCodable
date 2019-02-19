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

// Note: the types described below are based off - but distinct from - Swift's Codable family of APIs.

/**
 A type that can convert itself into and out of an external binary representation.
 */
public typealias BinaryCodable = BinaryDecodable & BinaryEncodable

/**
 A user-defined key for providing context during binary encoding and decoding.
 */
public typealias BinaryCodingUserInfoKey = String
