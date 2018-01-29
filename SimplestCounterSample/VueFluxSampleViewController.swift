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

    @IBOutlet private weak var upButton: UIButton!
    @IBOutlet private weak var downButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private let store = Store<CountState>(state: .init(), mutations: .init(), executor: .immediate)

    override func viewDidLoad() {
        super.viewDidLoad()

        store.computed.count
            .observe(on: .mainThread)
            .bind(to: countLabel, \.text)

        store.computed.isDownEnabled
            .observe(on: .mainThread)
            .bind(to: downButton, \.isEnabled)

        store.computed.downAlpha
            .observe(on: .mainThread)
            .bind(to: downButton, \.alpha)
    }

    @IBAction private func upButtonTapped(_ sender: UIButton) {
        store.actions.countUp()
    }

    @IBAction private func downButtonTapped(_ sender: UIButton) {
        store.actions.countDown()
    }
}


// MARK: - VueFlux

final class CountState: State {
    typealias Action = CountAction
    typealias Mutations = CountMutations

    fileprivate let count = Variable<Int>(0)
}

enum CountAction {
    case down
    case up
}

struct CountMutations: Mutations {
    func commit(action: CountAction, state: CountState) {
        switch action {
        case .up:
            state.count.value += 1

        case .down:
            state.count.value -= 1
        }
    }
}

extension Actions where State == CountState {
    func countUp() {
        dispatch(action: .up)
    }

    func countDown() {
        dispatch(action: .down)
    }
}

extension Computed where State == CountState {
    var count: Signal<String> {
        return state.count.signal
            .map(String.init)
    }

    var isDownEnabled: Signal<Bool> {
        return state.count.signal
            .map { $0 > 0 }
    }

    var downAlpha: Signal<CGFloat> {
        return isDownEnabled
            .map { $0 ? 1 : 0.5 }
    }
}
