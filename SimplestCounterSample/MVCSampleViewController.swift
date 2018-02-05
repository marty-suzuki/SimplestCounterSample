//
//  MVCSampleViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/01/25.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit

// MARK: - View

final class MVCSampleViewController: UIViewController {

    @IBOutlet private weak var incrementButton: UIButton!
    @IBOutlet private weak var decrementButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private let model = CountModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        model.countChanged = { [unowned self] in
            self.updateCountLabel()
            self.updateDecrementButton()
        }

        updateDecrementButton()
    }

    private func updateCountLabel() {
        countLabel.text = "\(model.count)"
    }

    private func updateDecrementButton() {
        let isEnabled = model.count > 0
        decrementButton.isEnabled = isEnabled
        decrementButton.alpha = isEnabled ? 1 : 0.5
    }

    @IBAction private func incrementButtonTapped(_ sender: UIButton) {
        model.increment()
    }

    @IBAction private func decrementButtonTapped(_ sender: UIButton) {
        model.decrement()
    }
}


// MARK: - Model

final class CountModel {
    private(set) var count: Int {
        didSet {
            countChanged?()
        }
    }

    var countChanged: (() -> ())?

    init() {
        self.count = 0
    }

    func increment() {
        count += 1
    }

    func decrement() {
        count -= 1
    }
}
