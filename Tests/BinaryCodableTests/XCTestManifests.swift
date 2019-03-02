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

extension BinaryFloatingPointBytesTests {
    static let __allTests = [
        ("testDoubleIsFourBytes", testDoubleIsFourBytes),
        ("testFloatIsFourBytes", testFloatIsFourBytes),
    ]
}

extension BufferedDataTests {
    static let __allTests = [
        ("testInitiallyPullsFromStart", testInitiallyPullsFromStart),
        ("testPullingMoreThanAvailableOnlyPullsWhatsAvailable", testPullingMoreThanAvailableOnlyPullsWhatsAvailable),
        ("testSuccessivePullsUseCursor", testSuccessivePullsUseCursor),
    ]
}

extension DecodeRemainderTests {
    static let __allTests = [
        ("testDecodesAllBytes", testDecodesAllBytes),
        ("testDecodesAllContainerBytes", testDecodesAllContainerBytes),
    ]
}

extension FixedWidthIntegerBytesTests {
    static let __allTests = [
        ("testIntDependsOnThePlatform", testIntDependsOnThePlatform),
        ("testUInt16IsTwoBytesInLittleEndian", testUInt16IsTwoBytesInLittleEndian),
        ("testUInt32IsFourBytesInLittleEndian", testUInt32IsFourBytesInLittleEndian),
        ("testUInt64IsEightBytesInLittleEndian", testUInt64IsEightBytesInLittleEndian),
        ("testUInt8IsOneByte", testUInt8IsOneByte),
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
        ("testDouble0Decoding", testDouble0Decoding),
        ("testDoubleValueDecoding", testDoubleValueDecoding),
        ("testFixed320Decoding", testFixed320Decoding),
        ("testFixed32ValueDecoding", testFixed32ValueDecoding),
        ("testFloat0Decoding", testFloat0Decoding),
        ("testFloatValueDecoding", testFloatValueDecoding),
        ("testGeneratedMessageDecoding", testGeneratedMessageDecoding),
        ("testInt320Decoding", testInt320Decoding),
        ("testInt32NegativeValueDecoding", testInt32NegativeValueDecoding),
        ("testInt32OverflowFailsToCompile", testInt32OverflowFailsToCompile),
        ("testInt32PositiveValueDecoding", testInt32PositiveValueDecoding),
        ("testInt640Decoding", testInt640Decoding),
        ("testInt64NegativeValueDecoding", testInt64NegativeValueDecoding),
        ("testInt64PositiveValueDecoding", testInt64PositiveValueDecoding),
        ("testMultipleInt32Decoding", testMultipleInt32Decoding),
        ("testProtoCompiler", testProtoCompiler),
        ("testProtoCompilerPipeline", testProtoCompilerPipeline),
        ("testSInt320Decoding", testSInt320Decoding),
        ("testSInt32NegativeValueDecoding", testSInt32NegativeValueDecoding),
        ("testSInt32PositiveValueDecoding", testSInt32PositiveValueDecoding),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ArrayDecoderTests.__allTests),
        testCase(ArrayEncoderTests.__allTests),
        testCase(BinaryFloatingPointBytesTests.__allTests),
        testCase(BufferedDataTests.__allTests),
        testCase(DecodeRemainderTests.__allTests),
        testCase(FixedWidthIntegerBytesTests.__allTests),
        testCase(GIFDecoderTests.__allTests),
        testCase(LengthEncodedPacketDecoderTests.__allTests),
        testCase(LengthEncodedPacketEncoderTests.__allTests),
        testCase(ProtobufTests.__allTests),
    ]
}
#endif
