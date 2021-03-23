import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(analytics_ios_integration_amplitudeTests.allTests),
    ]
}
#endif
