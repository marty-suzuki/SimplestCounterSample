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

    @IBOutlet private weak var upButton: UIButton!
    @IBOutlet private weak var downButton: UIButton!
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
        downButton.isEnabled = store.isDownEnabled
        downButton.alpha = store.downAlpha
    }

    @IBAction private func upButtonTapped(_ sender: UIButton) {
        action.countUp()
    }

    @IBAction private func downButtonTapped(_ sender: UIButton) {
        action.countDown()
    }
}


// MARK: - FluxCapacitor

enum FC { // Namespace

    final class CountAction: Actionable {
        typealias DispatchValueType = CountValue

        func countUp() {
            invoke(.countUp)
        }

        func countDown() {
            invoke(.countDown)
        }
    }

    final class CountStore: Storable {
        typealias DispatchValueType = CountValue

        private var _count: Int = 0

        var count: String {
            return "\(_count)"
        }

        var isDownEnabled: Bool {
            return _count > 0
        }

        var downAlpha: CGFloat {
            return isDownEnabled ? 1 : 0.5
        }

        init(dispatcher: Dispatcher) {
            register { [unowned self] value in
                switch value {
                case .countUp:
                    self._count += 1
                case .countDown:
                    self._count -= 1
                }
            }
        }
    }

    enum CountValue: DispatchValue {
        typealias RelatedActionType = CountAction
        typealias RelatedStoreType = CountStore

        case countUp
        case countDown
    }
}
