//
//  MVVMWithRxSwiftSampleViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/01/25.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - View

final class MVVMWithRxSwiftSampleViewController: UIViewController {

    @IBOutlet private weak var incrementButton: UIButton!
    @IBOutlet private weak var decrementButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private lazy var viewModel: Rx.CountViewModel = {
        return .init(incrementButtonTapped: self.incrementButton.rx.tap.asObservable(),
                     decrementButtonTapped: self.decrementButton.rx.tap.asObservable())
    }()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.isDecrementEnabled
            .bind(to: decrementButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.decrementAlpha
            .bind(to: decrementButton.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.count
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)
    }
}


// MARK: - ViewModel

enum Rx {
    final class CountViewModel {

        let count: Observable<String>
        let isDecrementEnabled: Observable<Bool>
        let decrementAlpha: Observable<CGFloat>

        private let disposeBag = DisposeBag()

        init(incrementButtonTapped: Observable<Void>,
             decrementButtonTapped: Observable<Void>) {

            let _count = BehaviorSubject<Int>(value: 0)
            let _isDecrementEnabled = _count.map { $0 > 0 }

            self.isDecrementEnabled = _isDecrementEnabled
            self.count = _count.map(String.init)
            self.decrementAlpha = _isDecrementEnabled.map { $0 ? 1 : 0.5 }

            Observable.merge(incrementButtonTapped.map { 1 },
                             decrementButtonTapped.map { -1 })
                .withLatestFrom(_count.asObservable()) { $1 + $0 }
                .bind(to: _count)
                .disposed(by: disposeBag)
        }
    }
}
