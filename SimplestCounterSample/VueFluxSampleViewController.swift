//
//  VueFluxSampleViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/01/29.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import VueFlux
import VueFluxReactive

final class VueFluxSampleViewController: UIViewController {

    @IBOutlet private weak var incrementButton: UIButton!
    @IBOutlet private weak var decrementButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private let store = Store<VF.CountState>(state: .init(), mutations: .init(), executor: .immediate)

    override func viewDidLoad() {
        super.viewDidLoad()

        store.computed.count
            .observe(on: .mainThread)
            .bind(to: countLabel, \.text)

        store.computed.isDecrementEnabled
            .observe(on: .mainThread)
            .bind(to: decrementButton, \.isEnabled)

        store.computed.decrementAlpha
            .observe(on: .mainThread)
            .bind(to: decrementButton, \.alpha)
    }

    @IBAction private func incrementButtonTapped(_ sender: UIButton) {
        store.actions.increment()
    }

    @IBAction private func decrementButtonTapped(_ sender: UIButton) {
        store.actions.decrement()
    }
}


// MARK: - VueFlux

enum VF { // Namespace

    final class CountState: State {
        typealias Action = CountAction
        typealias Mutations = CountMutations

        fileprivate let count = Variable<Int>(0)
    }

    enum CountAction {
        case increment
        case decrement
    }

    struct CountMutations: Mutations {
        func commit(action: CountAction, state: CountState) {
            switch action {
            case .increment:
                state.count.value += 1

            case .decrement:
                state.count.value -= 1
            }
        }
    }
}

extension Actions where State == VF.CountState {
    func increment() {
        dispatch(action: .increment)
    }

    func decrement() {
        dispatch(action: .decrement)
    }
}

extension Computed where State ==VF.CountState {
    var count: Signal<String> {
        return state.count.signal
            .map(String.init)
    }

    var isDecrementEnabled: Signal<Bool> {
        return state.count.signal
            .map { $0 > 0 }
    }

    var decrementAlpha: Signal<CGFloat> {
        return isDecrementEnabled
            .map { $0 ? 1 : 0.5 }
    }
}
