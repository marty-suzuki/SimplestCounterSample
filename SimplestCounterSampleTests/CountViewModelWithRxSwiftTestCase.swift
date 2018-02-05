//
//  CountViewModelWithRxSwiftTestCase.swift
//  SimplestCounterSampleTests
//
//  Created by 鈴木大貴 on 2018/01/25.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import SimplestCounterSample

final class CountViewModelWithRxSwiftTestCase: XCTestCase {
    private var incrementButtonTapped: PublishSubject<Void>!
    private var decrementButtonTapped: PublishSubject<Void>!
    private var viewModel: Rx.CountViewModel!

    override func setUp() {
        super.setUp()

        self.incrementButtonTapped = PublishSubject()
        self.decrementButtonTapped = PublishSubject()
        self.viewModel = Rx.CountViewModel(incrementButtonTapped: incrementButtonTapped,
                                           decrementButtonTapped: decrementButtonTapped)
    }
    
    func testInitialValues() {
        let count = Variable<String?>(nil)
        let isDecrementEnabled = Variable<Bool?>(nil)
        let decrementAlpha = Variable<CGFloat?>(nil)

        _ = viewModel.count
            .take(1)
            .bind(to: count)

        _ = viewModel.isDecrementEnabled
            .take(1)
            .bind(to: isDecrementEnabled)

        _ = viewModel.decrementAlpha
            .take(1)
            .bind(to: decrementAlpha)

        XCTAssertEqual(count.value, "0")
        XCTAssertFalse(isDecrementEnabled.value!)
        XCTAssertEqual(decrementAlpha.value, 0.5)
    }

    func testCountUpAndCountDown() {
        let group = DispatchGroup()

        do { // countUp test
            group.enter()

            group.enter()
            _ = viewModel.count
                .skip(1)
                .take(1)
                .subscribe(onNext: { count in
                    XCTAssertEqual(count, "1")
                    group.leave()
                })

            group.enter()
            _ = viewModel.isDecrementEnabled
                .skip(1)
                .take(1)
                .subscribe(onNext: { isEnabled in
                    XCTAssertTrue(isEnabled)
                    group.leave()
                })

            group.enter()
            _ = viewModel.decrementAlpha
                .skip(1)
                .take(1)
                .subscribe(onNext: { alpha in
                    XCTAssertEqual(alpha, 1)
                    group.leave()
                })

            incrementButtonTapped.onNext(())
        }

        do { // countDown test
            group.enter()

            group.enter()
            _ = viewModel.count
                .skip(1)
                .take(1)
                .subscribe(onNext: { count in
                    XCTAssertEqual(count, "0")
                    group.leave()
                })

            group.enter()
            _ = viewModel.isDecrementEnabled
                .skip(1)
                .take(1)
                .subscribe(onNext: { isEnabled in
                    XCTAssertFalse(isEnabled)
                    group.leave()
                })

            group.enter()
            _ = viewModel.decrementAlpha
                .skip(1)
                .take(1)
                .subscribe(onNext: { alpha in
                    XCTAssertEqual(alpha, 0.5)
                    group.leave()
                })

            decrementButtonTapped.onNext(())
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
