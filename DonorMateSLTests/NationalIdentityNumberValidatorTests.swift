//
//  NationalIdentityNumberValidatorTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/23/26.
//

import Testing
@testable import DonorMateSL

struct NationalIdentityNumberValidatorTests {

    @Test
    func acceptsTwelveDigitNIC() {
        #expect(
            NationalIdentityNumberValidator
                .isValid("198554200159")
        )
    }

    @Test
    func acceptsOldNICWithUppercaseV() {
        #expect(
            NationalIdentityNumberValidator
                .isValid("855420159V")
        )
    }

    @Test
    func acceptsOldNICWithLowercaseXAndNormalizesIt() {
        #expect(
            NationalIdentityNumberValidator
                .validated("855420159x") ==
                "855420159X"
        )
    }

    @Test
    func removesSpacesAndHyphensBeforeValidation() {
        #expect(
            NationalIdentityNumberValidator
                .validated("1985-542-00159") ==
                "198554200159"
        )
    }

    @Test
    func rejectsIncorrectLength() {
        #expect(
            !NationalIdentityNumberValidator
                .isValid("123456")
        )
    }

    @Test
    func rejectsOldNICWithoutValidSuffix() {
        #expect(
            !NationalIdentityNumberValidator
                .isValid("855420159A")
        )
    }

    @Test
    func rejectsImpossibleEncodedDay() {
        #expect(
            !NationalIdentityNumberValidator
                .isValid("198500000159")
        )
    }

    @Test
    func masksAllButLastFourCharacters() {
        #expect(
            NationalIdentityNumberValidator
                .masked("198554200159") ==
                "••••••••0159"
        )
    }
}
