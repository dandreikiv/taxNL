//
//  taxNLTests.swift
//  taxNLTests
//
//  Created by dmytro.andreikiv@philips.com on 23/06/16.
//  Copyright © 2016 A-Level. All rights reserved.
//

import XCTest
@testable import taxNL

class taxNLTests: XCTestCase {
    
    let calculator = TaxCalculator()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIncomeTax35000() {
        let income: Double = 35000
        let rate1: Double = 36.55     //19992
        let rate2: Double = 40.4   //33715
        let rate3: Double = 40.4    //66.421
        
        let actualResult = calculator.incomeTaxWith(income: income)
        let expectedResult = (19992 * rate1 / 100) + (33715 - 19992) * rate2 / 100 + (income - 33715) * rate3 / 100
        print("actual result \(actualResult), expected result \(expectedResult)")
        XCTAssert(actualResult == expectedResult, "actual result \(actualResult) is not equal to expected result \(expectedResult)")
    }
    
    func testIncomeTaxBelow18000() {
        let income: Double = 18000
        let rate = 8.4
        
        let actualResult = calculator.incomeTaxWith(income: income)
        let expectedResult = income * rate / 100
        print("actual result \(actualResult), expected result \(expectedResult)")
        XCTAssert(actualResult == expectedResult, "actual result \(actualResult) is not equal to expected result \(expectedResult)")
    }
    
    func testIncomeTax19000() {
        let income: Double = 19000
        let rate = 8.4
        
        let actualResult = calculator.incomeTaxWith(income: income)
        let expectedResult = income * rate / 100
        print("actual result \(actualResult), expected result \(expectedResult)")
        XCTAssert(actualResult == expectedResult, "actual result \(actualResult) is not equal to expected result \(expectedResult)")
    }
    
    func testIncomeTax19993() {
        let income: Double = 19993
        let rate1 = 8.4
        let rate2 = 12.25
        
        let actualResult = calculator.incomeTaxWith(income: income)
        let expectedResult = (income - 19992) * rate2 / 100 + 19992 * rate1 / 100
        print("actual result \(actualResult), expected result \(expectedResult)")
        XCTAssert(actualResult == expectedResult, "actual result \(actualResult) is not equal to expected result \(expectedResult)")
    }
}
