# #develop#

 TODO: Enumerate changes.


# 0.1.0

This is the first minor, unstable release of BinaryCodable. The public API for this library is subject to change unexpectedly until 1.0.0 is reached, at which point breaking changes will be mitigated and communicated ahead of time. This initial release includes the following features:

- Encode from Swift types to `Data`.
- Decode from `Data` to Swift types.
- Efficiently encode/decode large blocks of arbitrary data.
- Lazy decoding (read bytes from a source only as they're needed).
- Encode and decode fixed-width integer types.
- Encode and decode strings with or without terminators.
- Cap decoding containers to a maximum length.
