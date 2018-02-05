//
//  FluxSampleViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/02/06.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit

// MARK: - View

final class FluxSampleViewController: UIViewController {

    @IBOutlet private weak var incrementButton: UIButton!
    @IBOutlet private weak var decrementButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private let action = FE.CountAction.shared
    private let store = FE.CountStore.shared
    private var observers: [NSObjectProtocol] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        countLabel.text = store.count
        decrementButton.isEnabled = store.isDecrementEnabled
        decrementButton.alpha = store.decrementAlpha

        observers.append(store.addObserver(for: \FE.CountStore.count) { [weak self] count in
            self?.countLabel.text = count
        })
        observers.append(store.addObserver(for: \FE.CountStore.isDecrementEnabled) { [weak self] isEnabled in
            self?.decrementButton.isEnabled = isEnabled
        })
        observers.append(store.addObserver(for: \FE.CountStore.decrementAlpha) { [weak self] alpha in
            self?.decrementButton.alpha = alpha
        })
    }

    @IBAction private func incrementButtonTapped(_ sender: UIButton) {
        action.increment()
    }

    @IBAction private func decrementButtonTapped(_ sender: UIButton) {
        action.decrement()
    }
}

// MARK: - Flux Element

enum FE {
    final class CountAction {
        static let shared = CountAction()

        private let dispatcher: CountDispatcher

        init(dispatcher: CountDispatcher = .shared) {
            self.dispatcher =  dispatcher
        }

        func increment() {
            dispatcher.dispatch(value: 1)
        }

        func decrement() {
            dispatcher.dispatch(value: -1)
        }
    }

    final class CountDispatcher {
        static let shared = CountDispatcher()

        var value: ((Int) -> ())?

        func dispatch(value _value: Int) {
            value?(_value)
        }
    }

    final class CountStore {
        static let shared = CountStore()

        static let countChanged = Notification.Name(rawValue: "CountStore.countChanged")
        static let isDecrementEnabledChanged = Notification.Name(rawValue: "CountStore.isDecrementEnabledChanged")
        static let decrementAlphaChanged = Notification.Name(rawValue: "CountStore.decrementAlphaChanged")

        var count: String {
            return String(_count)
        }
        var isDecrementEnabled: Bool {
            return _count > 0
        }
        var decrementAlpha: CGFloat {
            return isDecrementEnabled ? 1 : 0.5
        }
        let center: NotificationCenter

        private var _count: Int = 0 {
            didSet {
                center.post(name: CountStore.countChanged, object: nil)
                center.post(name: CountStore.isDecrementEnabledChanged, object: nil)
                center.post(name: CountStore.decrementAlphaChanged, object: nil)
            }
        }

        private let dispatcher: CountDispatcher

        init(dispatcher: CountDispatcher = .shared, center: NotificationCenter = .default) {
            self.dispatcher = dispatcher
            self.center = center

            dispatcher.value = { [weak self] in
                self?._count += $0
            }
        }

        func addObserver<T>(for keyPath: KeyPath<CountStore, T>,
                            queue: OperationQueue? = .main,
                            changed: @escaping (T) -> ()) -> NSObjectProtocol {
            let name: Notification.Name
            switch keyPath {
            case \CountStore.count             : name = CountStore.countChanged
            case \CountStore.isDecrementEnabled: name = CountStore.isDecrementEnabledChanged
            case \CountStore.decrementAlpha    : name = CountStore.decrementAlphaChanged
            default                            : fatalError()
            }

            return center.addObserver(forName: name, object: nil, queue: queue, using: { [weak self] _ in
                guard let me = self else { return }
                changed(me[keyPath: keyPath])
            })
        }
    }
}
