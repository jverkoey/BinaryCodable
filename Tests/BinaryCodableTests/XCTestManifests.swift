import XCTest

extension BinaryDataDecoderTests {
    static let __allTests = [
        ("testEmpty", testEmpty),
        ("testMultipleByte", testMultipleByte),
        ("testOneByte", testOneByte),
    ]
}

extension BinaryDataEncoderTests {
    static let __allTests = [
        ("testEmptyLength", testEmptyLength),
        ("testMultipleByte", testMultipleByte),
        ("testOneByte", testOneByte),
    ]
}

extension BufferedDataTests {
    static let __allTests = [
        ("testInitiallyPullsFromStart", testInitiallyPullsFromStart),
        ("testPullingMoreThanAvailableOnlyPullsWhatsAvailable", testPullingMoreThanAvailableOnlyPullsWhatsAvailable),
        ("testSuccessivePullsUseCursor", testSuccessivePullsUseCursor),
    ]
}

extension GIFDecoderTests {
    static let __allTests = [
        ("testDecoding", testDecoding),
        ("testEncoding", testEncoding),
    ]
}

extension Tests {
    static let __allTests = [
        ("testIntDependsOnThePlatform", testIntDependsOnThePlatform),
        ("testUInt16IsTwoBytesInLittleEndian", testUInt16IsTwoBytesInLittleEndian),
        ("testUInt32IsFourBytesInLittleEndian", testUInt32IsFourBytesInLittleEndian),
        ("testUInt64IsEightBytesInLittleEndian", testUInt64IsEightBytesInLittleEndian),
        ("testUInt8IsOneByte", testUInt8IsOneByte),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BinaryDataDecoderTests.__allTests),
        testCase(BinaryDataEncoderTests.__allTests),
        testCase(BufferedDataTests.__allTests),
        testCase(GIFDecoderTests.__allTests),
        testCase(Tests.__allTests),
    ]
}
#endif
