import XCTest

extension BufferedDataTests {
    static let __allTests = [
        ("testInitiallyPullsFromStart", testInitiallyPullsFromStart),
        ("testPullingMoreThanAvailableOnlyPullsWhatsAvailable", testPullingMoreThanAvailableOnlyPullsWhatsAvailable),
        ("testSuccessivePullsUseCursor", testSuccessivePullsUseCursor),
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
        testCase(BufferedDataTests.__allTests),
        testCase(Tests.__allTests),
    ]
}
#endif
