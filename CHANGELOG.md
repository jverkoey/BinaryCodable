# #develop#

 TODO: Enumerate changes.


# 0.2.0

This minor unstable release renames `sequentialContainer` to `container` for both the BinaryEncoder and BinaryDecoder types, adds support for `BinaryFloatingPoint` decoding and encoding, automatic BinaryCodable conformance for floating point and array types, and a variety of performance improvements.

## Breaking changes

`BinaryDecoder` and `BinaryEncoder`'s `sequentialContainer` has been renamed to `container`. This is a straightforward find-and-replace operation.

## New features

`Array<BinaryCodable>` types automatically conform to BinaryCodable. It's easier now to code sequential binary objects like so:

```swift
// Decoding
let objects = try container.decode([SomeBinaryObject].self)

// Encoding
try container.encode(objects)
```

`Float` and `Double` RawRepresentable types automatically conform to BinaryCodable.

## Source changes

* [Remove excessive conditionals and buffer containment. (#40)](https://github.com/jverkoey/BinaryCodable/commit/4daaee9f3cf4c66da0f488940f5681e03b510306) (featherless)
* [Remove unnecessary cast.](https://github.com/jverkoey/BinaryCodable/commit/5308cd3139368daac29f5f60b4fc22ae6cc59a57) (Jeff Verkoeyen)
* [Fix bug and improve performance. (#39)](https://github.com/jverkoey/BinaryCodable/commit/1e9c21bc4be6e5501825665c0a73f9e87b909ffa) (featherless)
* [Remove unnecessary Data creation. (#38)](https://github.com/jverkoey/BinaryCodable/commit/49ca3e2430a51af9fd37afb15ee9b902789153e3) (featherless)
* [Use dropFirst instead of subscript notation when reading data. (#37)](https://github.com/jverkoey/BinaryCodable/commit/b1889da65bde47336bf9fa9418cde40863ffb09e) (featherless)
* [Add floating point support. (#23)](https://github.com/jverkoey/BinaryCodable/commit/2e3185ec72a7371ef9402e46b80f161849052ae9) (featherless)
* [Add array coding support + tests. (#14)](https://github.com/jverkoey/BinaryCodable/commit/9a56a79308d1096c31479f1c592b5fa331be0707) (featherless)
* [Drop "Sequential" from the container name. (#12)](https://github.com/jverkoey/BinaryCodable/commit/6b9d1ab11d77f1654dc7ef9c28eec2f52dbccf8f) (featherless)

## Non-source changes

* [Update all docs with new container APIs. (#41)](https://github.com/jverkoey/BinaryCodable/commit/c2843b87559d485cbffe7b299fd31e6ac841dc59) (featherless)
* [Update README.md](https://github.com/jverkoey/BinaryCodable/commit/ec5d1f5256f07b004b210fd9b5f5e897030a34cb) (featherless)
* [Update README.md](https://github.com/jverkoey/BinaryCodable/commit/49ce0b41000a92306c326e80333af9a427611b48) (featherless)
* [Add BinaryCookies](https://github.com/jverkoey/BinaryCodable/commit/8f85cba939ed36003389dcc1b3fdfc941bf4a333) (featherless)
* [Add support for embedded types in the proto decoder. (#35)](https://github.com/jverkoey/BinaryCodable/commit/397ccc9bb1dff24bba000b7d42d82a0115a8c74c) (featherless)
* [Add bytes decoding support to the proto decoder. (#34)](https://github.com/jverkoey/BinaryCodable/commit/1328fce67b03b5a41d99730389f21068150d2d4a) (featherless)
* [Add String support to the proto decoder. (#33)](https://github.com/jverkoey/BinaryCodable/commit/07e1c1c3fea8ac4def6fa89639a7c30e9ace217d) (featherless)
* [Add bool support to the proto decoder. (#32)](https://github.com/jverkoey/BinaryCodable/commit/0e93d2224f1a5303ec411015f8ae312aa17beb28) (featherless)
* [Add sint64 support to the proto decoder. (#31)](https://github.com/jverkoey/BinaryCodable/commit/8108735cc28ec8ad1cda549b6b5ce30ca3783427) (featherless)
* [Add uint64 decoding support. (#30)](https://github.com/jverkoey/BinaryCodable/commit/8cbf0bf2f9f7048a1cae01c3f006be3f1a0d533a) (featherless)
* [Add support for optional proto decoding. (#29)](https://github.com/jverkoey/BinaryCodable/commit/b87134d57dc152978bc214f0c7c5a13a3c033144) (featherless)
* [Add double decoding support to the proto decoder. (#28)](https://github.com/jverkoey/BinaryCodable/commit/4c303bfa0d1a6e259ab55674a7afe18409e2ebad) (featherless)
* [Rename the message fields to match the underlying types. (#27)](https://github.com/jverkoey/BinaryCodable/commit/6d937eca935c2eaed901771be83d3c124aa338d8) (featherless)
* [Add proper fixed64 support to the proto decoder. (#26)](https://github.com/jverkoey/BinaryCodable/commit/1c227a1e8f15e709d42cf8cdf0a13221b7a96e49) (featherless)
* [ Add fixed32 support to the proto decoder. (#25)](https://github.com/jverkoey/BinaryCodable/commit/e135e3ca651b91cafe5bcb3ae5babec3935fbad3) (featherless)
* [Add double/fixed64 support to the proto proof of concept. (#24)](https://github.com/jverkoey/BinaryCodable/commit/6e32bee3c8fc98a0ab4b588a0fad0df6226e7769) (featherless)
* [Add a rudimentary Codable-compatible proto decoder built on top of a BinaryCodable message decoder. (#22)](https://github.com/jverkoey/BinaryCodable/commit/21cf2f7c4a7e03f039bd8750ee1e6c91869aecd2) (featherless)
* [Add sint32 proto tests (#21)](https://github.com/jverkoey/BinaryCodable/commit/33f58fc19bbc7ca2bdfd78cc1aee034cdf06607d) (featherless)
* [Add int64 proto tests. (#20)](https://github.com/jverkoey/BinaryCodable/commit/17adab86bedc1981254ac431134a1fd6ed812ab2) (featherless)
* [Add int32 overflow tests to verify the behavior of the protoc compiler. (#19)](https://github.com/jverkoey/BinaryCodable/commit/6d4b7c9eb11643904602c68bfb5079d5e71fe5d2) (featherless)
* [ Add proof of concept protobuf decoder tests (#15)](https://github.com/jverkoey/BinaryCodable/commit/96bf29b4f9fc808c5e1772fe2712f4018e1265ee) (featherless)
* [Update Swift to the latest development snapshot (#13)](https://github.com/jverkoey/BinaryCodable/commit/9cca6e629d352890181d81ce0d2dd47dd2bd6649) (featherless)
* [Update README.md](https://github.com/jverkoey/BinaryCodable/commit/176b7718796104ad22447b4ec86b9e09cb66d8af) (featherless)
* [Fix typo in readme. (#10)](https://github.com/jverkoey/BinaryCodable/commit/ba811ac24e7114628d22792e60620e144b410c88) (featherless)
* [Add missing linux tests. (#9)](https://github.com/jverkoey/BinaryCodable/commit/d2d2c558f0c4d205ff51816965dc3be62fb69a10) (featherless)

---

# 0.1.0

This is the first minor, unstable release of BinaryCodable. The public API for this library is subject to change unexpectedly until 1.0.0 is reached, at which point breaking changes will be mitigated and communicated ahead of time. This initial release includes the following features:

- Encode from Swift types to `Data`.
- Decode from `Data` to Swift types.
- Efficiently encode/decode large blocks of arbitrary data.
- Lazy decoding (read bytes from a source only as they're needed).
- Encode and decode fixed-width integer types.
- Encode and decode strings with or without terminators.
- Cap decoding containers to a maximum length.
