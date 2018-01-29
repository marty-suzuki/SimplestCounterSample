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

        updateViews()

        store.subscribe { [unowned self] _ in
            DispatchQueue.main.async { [unowned self] in
                self.updateViews()
            }
        }
        .cleaned(by: dustBuster)
    }

    private func updateViews() {
        countLabel.text = store.count
        decrementButton.isEnabled = store.isDecrementEnabled
        decrementButton.alpha = store.decrementAlpha
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

    final class CountAction: Actionable {
        typealias DispatchValueType = CountValue

        func increment() {
            invoke(.increment)
        }

        func decrement() {
            invoke(.decrement)
        }
    }

    final class CountStore: Storable {
        typealias DispatchValueType = CountValue

        private var _count: Int = 0

        var count: String {
            return "\(_count)"
        }

        var isDecrementEnabled: Bool {
            return _count > 0
        }

        var decrementAlpha: CGFloat {
            return isDecrementEnabled ? 1 : 0.5
        }

        init(dispatcher: Dispatcher) {
            register { [unowned self] value in
                switch value {
                case .increment:
                    self._count += 1
                case .decrement:
                    self._count -= 1
                }
            }
        }
    }

    enum CountValue: DispatchValue {
        typealias RelatedActionType = CountAction
        typealias RelatedStoreType = CountStore

        case increment
        case decrement
    }
}
