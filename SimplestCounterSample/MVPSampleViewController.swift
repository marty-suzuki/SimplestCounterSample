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
    func updateDownButton(isEnabled: Bool, alpha: CGFloat)
    func updateCountLabel(count: String)
}

final class MVPSampleViewController: UIViewController, CountViewType {

    @IBOutlet private weak var upButton: UIButton!
    @IBOutlet private weak var downButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private(set) lazy var presenter: CountPresenterType = CountPresenter(view: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = presenter
    }

    @IBAction private func upButtonTapped(_ sender: UIButton) {
        presenter.countUp()
    }

    @IBAction private func downButtonTapped(_ sender: UIButton) {
        presenter.countDown()
    }

    func updateDownButton(isEnabled: Bool, alpha: CGFloat) {
        downButton.isEnabled = isEnabled
        downButton.alpha = alpha
    }

    func updateCountLabel(count: String) {
        countLabel.text = count
    }
}


// MARK: - Presenter

protocol CountPresenterType: class {
    var view: CountViewType? { get }
    func countUp()
    func countDown()
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
        view?.updateDownButton(isEnabled: isEnabled, alpha: alpha)
        view?.updateCountLabel(count: "\(count)")
    }

    func countUp() {
        count += 1
    }

    func countDown() {
        count -= 1
    }
}
