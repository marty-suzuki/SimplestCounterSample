//
//  CountModelTestCase.swift
//  SimplestCounterSampleTests
//
//  Created by 鈴木大貴 on 2018/01/25.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest

@testable import SimplestCounterSample

final class CountModelTestCase: XCTestCase {

    private var model: CountModel!

    override func setUp() {
        super.setUp()

        self.model = CountModel()
    }
    
    func testCountUp() {
        let expect = expectation(description: "will increment count")

        model.countChanged = { [unowned self] in
            XCTAssertEqual(self.model.count, 1)
            expect.fulfill()
        }

        model.countUp()

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testCountDown() {
        let expect = expectation(description: "will decrement count")

        model.countChanged = { [unowned self] in
            XCTAssertEqual(self.model.count, -1)
            expect.fulfill()
        }

        model.countDown()

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
