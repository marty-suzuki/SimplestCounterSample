//
//  MVVMSampleViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/02/06.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit

// MARK: - View

final class MVVMSampleViewController: UIViewController {

    @IBOutlet private weak var incrementButton: UIButton!
    @IBOutlet private weak var decrementButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private let viewModel = CountViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        incrementButton.addTarget(viewModel, action: #selector(CountViewModel.increment), for: .touchUpInside)
        decrementButton.addTarget(viewModel, action: #selector(CountViewModel.decrement), for: .touchUpInside)

        do {
            try viewModel.observe(keyPath: \.count, bindTo: countLabel, \.text)
            try viewModel.observe(keyPath: \.isDecrementEnabled, bindTo: decrementButton, \.isEnabled)
            try viewModel.observe(keyPath: \.decrementAlpha, bindTo: decrementButton, \.alpha)
        } catch let e {
            fatalError("\(e)")
        }
    }
}


// MARK: - ViewModel

final class CountViewModel {

    private enum Names {
        static let countChanged = Notification.Name(rawValue: "CountViewModel.countChanged")
        static let isDecrementEnabledChanged = Notification.Name(rawValue: "CountViewModel.isDecrementEnabledChanged")
        static let decrementAlphaChanged = Notification.Name(rawValue: "CountViewModel.decrementAlphaChanged")
    }

    enum Error: Swift.Error {
        case invalidKeyPath(AnyKeyPath)
    }

    private(set) var count: String = "" {
        didSet { center.post(name: Names.countChanged, object: nil) }
    }
    private(set) var isDecrementEnabled: Bool = false {
        didSet { center.post(name: Names.isDecrementEnabledChanged, object: nil) }
    }
    private(set) var decrementAlpha: CGFloat = 0.5 {
        didSet { center.post(name: Names.decrementAlphaChanged, object: nil) }
    }

    private var observers: [NSObjectProtocol] = []
    private let center: NotificationCenter

    private var _count: Int = 0 {
        didSet {
            count = String(_count)
            isDecrementEnabled = _count > 0
            decrementAlpha = isDecrementEnabled ? 1 : 0.5
        }
    }

    deinit {
        observers.forEach { center.removeObserver($0) }
    }

    init(center: NotificationCenter = .init()) {
        self.center = center
        setInitialValue()
    }

    private func setInitialValue() {
        _count = 0
    }

    @objc func increment() {
        _count += 1
    }

    @objc func decrement() {
        _count -= 1
    }

    func observe<Value1, Target: AnyObject, Value2>(keyPath keyPath1: KeyPath<CountViewModel, Value1>,
                                                    on queue: OperationQueue? = .main,
                                                    bindTo target: Target,
                                                    _ keyPath2: ReferenceWritableKeyPath<Target, Value2>) throws {
        let name: Notification.Name
        switch keyPath1 {
        case \CountViewModel.count             : name = Names.countChanged
        case \CountViewModel.isDecrementEnabled: name = Names.isDecrementEnabledChanged
        case \CountViewModel.decrementAlpha    : name = Names.decrementAlphaChanged
        default                                : throw Error.invalidKeyPath(keyPath1)
        }

        let handler: () -> () = { [weak self, weak target] in
            guard let me = self, let target = target, let value = me[keyPath: keyPath1] as? Value2 else { return }
            target[keyPath: keyPath2] = value
        }

        handler()
        observers.append(center.addObserver(forName: name, object: nil, queue: queue) { _ in handler() })
    }
}
