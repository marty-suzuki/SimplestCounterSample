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

        do {
            try viewModel.observe(keyPath: \.count, bindTo: countLabel, \.text)
            try viewModel.observe(keyPath: \.isDecrementEnabled, bindTo: decrementButton, \.isEnabled)
            try viewModel.observe(keyPath: \.decrementAlpha, bindTo: decrementButton, \.alpha)
        } catch let e {
            fatalError("\(e)")
        }
    }

    @IBAction private func incrementButtonTapped(_ sender: UIButton) {
        viewModel.increment()
    }

    @IBAction private func decrementButtonTapped(_ sender: UIButton) {
        viewModel.decrement()
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

    var count: String {
        return String(_count)
    }
    var isDecrementEnabled: Bool {
        return _count > 0
    }
    var decrementAlpha: CGFloat {
        return isDecrementEnabled ? 1 : 0.5
    }

    private var observers: [NSObjectProtocol] = []
    private let center: NotificationCenter

    private var _count: Int = 0 {
        didSet {
            center.post(name: Names.countChanged, object: nil)
            center.post(name: Names.isDecrementEnabledChanged, object: nil)
            center.post(name: Names.decrementAlphaChanged, object: nil)
        }
    }

    deinit {
        observers.forEach { center.removeObserver($0) }
    }

    init(center: NotificationCenter = .init()) {
        self.center = center
    }

    func increment() {
        _count += 1
    }

    func decrement() {
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

        observers.append(center.addObserver(forName: name, object: nil, queue: queue) { _ in handler() })
        handler()
    }
}
