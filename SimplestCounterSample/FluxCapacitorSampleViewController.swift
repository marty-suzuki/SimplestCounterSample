//
//  FluxCapacitorSampleViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/01/29.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import FluxCapacitor

final class FluxCapacitorSampleViewController: UIViewController {

    @IBOutlet private weak var incrementButton: UIButton!
    @IBOutlet private weak var decrementButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private let action = FC.CountAction()
    private let store = FC.CountStore.instantiate()
    private let dustBuster = DustBuster()

    override func viewDidLoad() {
        super.viewDidLoad()

        store.count
            .observe(on: .main) { [weak self] in
                self?.countLabel.text = "\($0)"
            }
            .cleaned(by: dustBuster)

        store.isDecrementEnabled
            .observe(on: .main) { [weak self] in
                self?.decrementButton.isEnabled = $0
            }
            .cleaned(by: dustBuster)

        store.decrementAlpha
            .observe(on: .main) { [weak self] in
                self?.decrementButton.alpha = $0
            }
            .cleaned(by: dustBuster)
    }

    @IBAction private func incrementButtonTapped(_ sender: UIButton) {
        action.increment()
    }

    @IBAction private func decrementButtonTapped(_ sender: UIButton) {
        action.decrement()
    }
}


// MARK: - FluxCapacitor

enum FC { // Namespace

    enum CountState: DispatchState {
        typealias RelatedActionType = CountAction
        typealias RelatedStoreType = CountStore

        case increment
        case decrement
    }
    
    final class CountAction: Actionable {
        typealias DispatchStateType = CountState

        func increment() {
            invoke(.increment)
        }

        func decrement() {
            invoke(.decrement)
        }
    }

    final class CountStore: Storable {
        typealias DispatchStateType = CountState

        let count: Constant<Int>
        private let _count = Variable<Int>(0)

        let isDecrementEnabled: Constant<Bool>
        private let _isDecrementEnabled = Variable<Bool>(false)

        let decrementAlpha: Constant<CGFloat>
        private let _decrementAlpha = Variable<CGFloat>(0)

        private let dustBuster = DustBuster()

        init() {
            self.count = Constant(_count)
            self.isDecrementEnabled = Constant(_isDecrementEnabled)
            self.decrementAlpha = Constant(_decrementAlpha)

            _count
                .observe { [weak self] in
                    guard let me = self else { return }
                    me._isDecrementEnabled.value = $0 > 0
                    me._decrementAlpha.value = me._isDecrementEnabled.value ? 1 : 0.5
                }
                .cleaned(by: dustBuster)
        }

        func reduce(with state: CountState) {
            switch state {
            case .increment:
                _count.value += 1
            case .decrement:
                _count.value -= 1
            }
        }
    }
}
