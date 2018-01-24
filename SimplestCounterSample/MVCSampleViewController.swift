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

    @IBOutlet private weak var upButton: UIButton!
    @IBOutlet private weak var downButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private let model = CountModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        model.countChanged = { [unowned self] in
            self.updateCountLabel()
            self.updateDownButton()
        }

        updateDownButton()
    }

    private func updateCountLabel() {
        countLabel.text = "\(model.count)"
    }

    private func updateDownButton() {
        let isEnabled = model.count > 0
        downButton.isEnabled = isEnabled
        downButton.alpha = isEnabled ? 1 : 0.5
    }

    @IBAction private func upButtonTapped(_ sender: UIButton) {
        model.countUp()
    }

    @IBAction private func downButtonTapped(_ sender: UIButton) {
        model.countDown()
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

    func countUp() {
        count += 1
    }

    func countDown() {
        count -= 1
    }
}
