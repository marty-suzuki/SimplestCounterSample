//
//  CountViewModelTestCase.swift
//  SimplestCounterSampleTests
//
//  Created by 鈴木大貴 on 2018/01/25.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa

@testable import SimplestCounterSample

final class CountViewModelTestCase: XCTestCase {
    private var upButtonTapped: PublishSubject<Void>!
    private var downButtonTapped: PublishSubject<Void>!
    private var viewModel: CountViewModel!

    override func setUp() {
        super.setUp()

        self.upButtonTapped = PublishSubject()
        self.downButtonTapped = PublishSubject()
        self.viewModel = CountViewModel(upButtonTapped: upButtonTapped,
                                        downButtonTapped: downButtonTapped)
    }
    
    func testInitialValues() {
        let count = Variable<String?>(nil)
        let isDownEnabled = Variable<Bool?>(nil)
        let downAlpha = Variable<CGFloat?>(nil)

        _ = viewModel.count
            .take(1)
            .bind(to: count)

        _ = viewModel.isDownEnabled
            .take(1)
            .bind(to: isDownEnabled)

        _ = viewModel.downAlpha
            .take(1)
            .bind(to: downAlpha)

        XCTAssertEqual(count.value, "0")
        XCTAssertFalse(isDownEnabled.value!)
        XCTAssertEqual(downAlpha.value, 0.5)
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
            _ = viewModel.isDownEnabled
                .skip(1)
                .take(1)
                .subscribe(onNext: { isEnabled in
                    XCTAssertTrue(isEnabled)
                    group.leave()
                })

            group.enter()
            _ = viewModel.downAlpha
                .skip(1)
                .take(1)
                .subscribe(onNext: { alpha in
                    XCTAssertEqual(alpha, 1)
                    group.leave()
                })

            upButtonTapped.onNext(())
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
            _ = viewModel.isDownEnabled
                .skip(1)
                .take(1)
                .subscribe(onNext: { isEnabled in
                    XCTAssertFalse(isEnabled)
                    group.leave()
                })

            group.enter()
            _ = viewModel.downAlpha
                .skip(1)
                .take(1)
                .subscribe(onNext: { alpha in
                    XCTAssertEqual(alpha, 0.5)
                    group.leave()
                })

            downButtonTapped.onNext(())
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
