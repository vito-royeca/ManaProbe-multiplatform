//
//  Tests_Prefetch.swift
//  Tests iOS
//
//  Created by Vito Royeca on 5/16/26.
//

import XCTest
import ManaKit

@MainActor
final class Tests_Prefetch: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let apiURLEndpoint = "http://matilda:4000/graphql"
        print("apiURLEndpoint = \(apiURLEndpoint)")
        ManaKitUtilities.shared.configure(apiURL: apiURLEndpoint)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testPrefetchSets() async throws {
        do {
            try await ManaKitUtilities.shared.prefetchSets(fetchSetDetails: true,
                                                           includeNonEnglishSets: false,
                                                           fetchCards: false)
        } catch {
            print(error)
            
        }
    }
}
