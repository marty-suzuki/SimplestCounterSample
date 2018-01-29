//
//  MVPSampleViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/01/25.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit

// MARK: - View

protocol CountViewType: class {
    var presenter: CountPresenterType { get }
    func updateDecrementButton(isEnabled: Bool, alpha: CGFloat)
    func updateCountLabel(count: String)
}

final class MVPSampleViewController: UIViewController, CountViewType {

    @IBOutlet private weak var incrementButton: UIButton!
    @IBOutlet private weak var decrementButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private(set) lazy var presenter: CountPresenterType = CountPresenter(view: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = presenter
    }

    @IBAction private func incrementButtonTapped(_ sender: UIButton) {
        presenter.increment()
    }

    @IBAction private func decrementButtonTapped(_ sender: UIButton) {
        presenter.decrement()
    }

    func updateDecrementButton(isEnabled: Bool, alpha: CGFloat) {
        decrementButton.isEnabled = isEnabled
        decrementButton.alpha = alpha
    }

    func updateCountLabel(count: String) {
        countLabel.text = count
    }
}


// MARK: - Presenter

protocol CountPresenterType: class {
    var view: CountViewType? { get }
    func increment()
    func decrement()
}

final class CountPresenter: CountPresenterType {

    private(set) weak var view: CountViewType?
    private var count: Int {
        didSet {
            didSetCount()
        }
    }

    init(view: CountViewType) {
        self.view = view
        self.count = 0
        didSetCount()
    }

    private func didSetCount() {
        let isEnabled = count > 0
        let alpha: CGFloat = isEnabled ? 1 : 0.5
        view?.updateDecrementButton(isEnabled: isEnabled, alpha: alpha)
        view?.updateCountLabel(count: "\(count)")
    }

    func increment() {
        count += 1
    }

    func decrement() {
        count -= 1
    }
}
