import XCTest

extension ArrayDecoderTests {
    static let __allTests = [
        ("testEmpty", testEmpty),
        ("testMultipleByte", testMultipleByte),
        ("testOneByte", testOneByte),
    ]
}

extension ArrayEncoderTests {
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

extension LengthEncodedPacketDecoderTests {
    static let __allTests = [
        ("testEmpty", testEmpty),
        ("testMultipleByte", testMultipleByte),
        ("testOneByte", testOneByte),
    ]
}

extension LengthEncodedPacketEncoderTests {
    static let __allTests = [
        ("testEmptyLength", testEmptyLength),
        ("testMultipleByte", testMultipleByte),
        ("testOneByte", testOneByte),
    ]
}

extension ProtobufTests {
    static let __allTests = [
        ("testGeneratedMessageDecoding", testGeneratedMessageDecoding),
        ("testMultipleInt32Decoding", testMultipleInt32Decoding),
        ("testProtoCompiler", testProtoCompiler),
        ("testProtoCompilerPipeline", testProtoCompilerPipeline),
        ("testVarInt320Decoding", testVarInt320Decoding),
        ("testVarInt32PositiveValueDecoding", testVarInt32PositiveValueDecoding),
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
        testCase(ArrayDecoderTests.__allTests),
        testCase(ArrayEncoderTests.__allTests),
        testCase(BufferedDataTests.__allTests),
        testCase(GIFDecoderTests.__allTests),
        testCase(LengthEncodedPacketDecoderTests.__allTests),
        testCase(LengthEncodedPacketEncoderTests.__allTests),
        testCase(ProtobufTests.__allTests),
        testCase(Tests.__allTests),
    ]
}
#endif
