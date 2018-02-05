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

    private let action = CountAction.shared
    private let store = CountStore.shared
    private var observers: [NSObjectProtocol] = []

    deinit {
        store.removeObservers(observers)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        countLabel.text = store.count
        decrementButton.isEnabled = store.isDecrementEnabled
        decrementButton.alpha = store.decrementAlpha

        do {
            try observers.append(store.observe(keyPath: \.count,
                                               bindTo: countLabel,
                                               keyPath: \.text))
            try observers.append(store.observe(keyPath: \.isDecrementEnabled,
                                               bindTo: decrementButton,
                                               keyPath: \.isEnabled))
            try observers.append(store.observe(keyPath: \.decrementAlpha,
                                               bindTo: decrementButton,
                                               keyPath: \.alpha))
        } catch let e {
            fatalError("\(e)")
        }
    }

    @IBAction private func incrementButtonTapped(_ sender: UIButton) {
        action.increment()
    }

    @IBAction private func decrementButtonTapped(_ sender: UIButton) {
        action.decrement()
    }
}


// MARK: - Flux Element

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

    private enum Names {
        static let countChanged = Notification.Name(rawValue: "CountStore.countChanged")
        static let isDecrementEnabledChanged = Notification.Name(rawValue: "CountStore.isDecrementEnabledChanged")
        static let decrementAlphaChanged = Notification.Name(rawValue: "CountStore.decrementAlphaChanged")
    }

    enum Error: Swift.Error {
        case invalidKeyPath(AnyKeyPath)
    }

    var count: String {
        return String(_count)
    }
    var isDecrementEnabled: Bool {
        return _count > 0
    }
    var decrementAlpha: CGFloat {
        return isDecrementEnabled ? 1 : 0.5
    }

    private let center: NotificationCenter

    private var _count: Int = 0 {
        didSet {
            center.post(name: Names.countChanged, object: nil)
            center.post(name: Names.isDecrementEnabledChanged, object: nil)
            center.post(name: Names.decrementAlphaChanged, object: nil)
        }
    }

    private let dispatcher: CountDispatcher

    init(dispatcher: CountDispatcher = .shared, center: NotificationCenter = .init()) {
        self.dispatcher = dispatcher
        self.center = center

        dispatcher.value = { [weak self] in
            self?._count += $0
        }
    }

    func observe<Value1, Target: AnyObject, Value2>(keyPath keyPath1: KeyPath<CountStore, Value1>,
                                                    on queue: OperationQueue? = .main,
                                                    bindTo target: Target,
                                                    keyPath keyPath2: ReferenceWritableKeyPath<Target, Value2>) throws -> NSObjectProtocol {
        let name: Notification.Name
        switch keyPath1 {
        case \CountStore.count             : name = Names.countChanged
        case \CountStore.isDecrementEnabled: name = Names.isDecrementEnabledChanged
        case \CountStore.decrementAlpha    : name = Names.decrementAlphaChanged
        default                            : throw Error.invalidKeyPath(keyPath1)
        }

        return center.addObserver(forName: name, object: nil, queue: queue) { [weak self, weak target] _ in
            guard let me = self, let target = target, let value = me[keyPath: keyPath1] as? Value2 else { return }
            target[keyPath: keyPath2] = value
        }
    }

    func removeObservers(_ observes: [NSObjectProtocol]) {
        observes.forEach { center.removeObserver($0) }
    }
}
