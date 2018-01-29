//
//  CountPresenterTestCase.swift
//  SimplestCounterSampleTests
//
//  Created by 鈴木大貴 on 2018/01/25.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest

@testable import SimplestCounterSample

final class CountPresenterTestCase: XCTestCase {

    private final class MockCountView: CountViewType {

        private(set) lazy var presenter: CountPresenterType = {
            fatalError("presetnter does not use in this mock.")
        }()

        var didCallUpdateDecrementButton: (((isEnabled: Bool, alpha: CGFloat)) -> ())?
        var didCallUpdateCountLabel: ((String) -> ())?

        init() {}

        func updateDecrementButton(isEnabled: Bool, alpha: CGFloat) {
            didCallUpdateDecrementButton?((isEnabled, alpha))
        }

        func updateCountLabel(count: String) {
            didCallUpdateCountLabel?(count)
        }
    }

    private var view: MockCountView!
    private var presenter: CountPresenter!

    override func setUp() {
        super.setUp()

        self.view = MockCountView()
        self.presenter = CountPresenter(view: view)
    }

    func testInitialValue() {
        self.view = MockCountView()

        let group = DispatchGroup()

        group.enter()
        view.didCallUpdateCountLabel = { count in
            XCTAssertEqual(count, "0")
            group.leave()
        }

        group.enter()
        view.didCallUpdateDecrementButton = { arg in
            XCTAssertFalse(arg.isEnabled)
            XCTAssertEqual(arg.alpha, 0.5)
            group.leave()
        }

        let expect = expectation(description: "initial values")
        group.notify(queue: .main) {
            expect.fulfill()
        }

        self.presenter = CountPresenter(view: view)

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testCountUpAndDown() {
        let group = DispatchGroup()

        do { // countUp test
            group.enter()

            group.enter()
            view.didCallUpdateCountLabel = { count in
                XCTAssertEqual(count, "1")
                group.leave()
            }

            group.enter()
            view.didCallUpdateDecrementButton = { arg in
                XCTAssertTrue(arg.isEnabled)
                XCTAssertEqual(arg.alpha, 1)
                group.leave()
            }

            presenter.increment()
        }

        do { // countDown test
            group.enter()

            group.enter()
            view.didCallUpdateCountLabel = { count in
                XCTAssertEqual(count, "0")
                group.leave()
            }

            group.enter()
            view.didCallUpdateDecrementButton = { arg in
                XCTAssertFalse(arg.isEnabled)
                XCTAssertEqual(arg.alpha, 0.5)
                group.leave()
            }

            presenter.decrement()
        }

        let expect = expectation(description: "increment and decrement count")
        group.notify(queue: .main) {
            expect.fulfill()
        }
        group.leave()
        group.leave()

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
