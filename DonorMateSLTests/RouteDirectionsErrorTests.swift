//
//  RouteDirectionsErrorTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct RouteDirectionsErrorTests {

    @Test
    func routeNotFoundHasExpectedErrorDescription() {

        let error =
            RouteDirectionsError.routeNotFound

        #expect(
            error.errorDescription ==
                "No driving route could be found."
        )
    }

    @Test
    func routeNotFoundProvidesLocalizedDescription() {

        let error: Error =
            RouteDirectionsError.routeNotFound

        #expect(
            error.localizedDescription ==
                "No driving route could be found."
        )
    }
}
