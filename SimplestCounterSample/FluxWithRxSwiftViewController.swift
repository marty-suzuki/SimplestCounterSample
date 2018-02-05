//
//  FluxWithRxSwiftViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/02/06.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - View

final class FluxWithRxSwiftViewController: UIViewController {

    @IBOutlet private weak var incrementButton: UIButton!
    @IBOutlet private weak var decrementButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private let action = FR.CountAction.shared
    private let store = FR.CountStore.shared
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        store.isDecrementEnabled
            .bind(to: decrementButton.rx.isEnabled)
            .disposed(by: disposeBag)

        store.decrementAlpha
            .bind(to: decrementButton.rx.alpha)
            .disposed(by: disposeBag)

        store.count
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)

        incrementButton.rx.tap
            .bind(onNext: action.increment)
            .disposed(by: disposeBag)

        decrementButton.rx.tap
            .bind(onNext: action.decrement)
            .disposed(by: disposeBag)
    }
}


// MARK: - Flux with RxSwift

enum FR {
    final class CountAction {
        static let shared = CountAction()

        private let dispatcher: CountDispatcher

        init(dispatcher: CountDispatcher = .shared) {
            self.dispatcher =  dispatcher
        }

        func increment() {
            dispatcher.value.accept(1)
        }

        func decrement() {
            dispatcher.value.accept(-1)
        }
    }

    final class CountDispatcher {
        static let shared = CountDispatcher()

        let value = PublishRelay<Int>()
    }

    final class CountStore {
        static let shared = CountStore()

        let count: Observable<String>
        let isDecrementEnabled: Observable<Bool>
        let decrementAlpha: Observable<CGFloat>

        private let disposeBag = DisposeBag()

        init(dispatcher: CountDispatcher = .shared) {
            let _count = BehaviorRelay(value: 0)

            self.count = _count
                .map(String.init)
                .share(replay: 1, scope: .forever)
            self.isDecrementEnabled = _count
                .map { $0 > 0 }
                .share(replay: 1, scope: .forever)
            self.decrementAlpha = isDecrementEnabled
                .map { $0 ? 1 : 0.5 }
                .share(replay: 1, scope: .forever)

            dispatcher.value
                .withLatestFrom(_count) { $1 + $0 }
                .bind(to: _count)
                .disposed(by: disposeBag)
        }
    }
}
