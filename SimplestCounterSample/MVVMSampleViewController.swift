//
//  MVVMSampleViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/01/25.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - View

final class MVVMSampleViewController: UIViewController {

    @IBOutlet private weak var upButton: UIButton!
    @IBOutlet private weak var downButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!

    private lazy var viewModel: CountViewModel = {
        return .init(upButtonTapped: self.upButton.rx.tap.asObservable(),
                     downButtonTapped: self.downButton.rx.tap.asObservable())
    }()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.isDownEnabled
            .bind(to: downButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.downAlpha
            .bind(to: downButton.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.count
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)
    }
}


// MARK: - ViewModel

final class CountViewModel {

    let count: Observable<String>
    let isDownEnabled: Observable<Bool>
    let downAlpha: Observable<CGFloat>

    private let disposeBag = DisposeBag()

    init(upButtonTapped: Observable<Void>,
         downButtonTapped: Observable<Void>) {

        let _count = BehaviorSubject<Int>(value: 0)
        let _isDownEnabled = _count.map { $0 > 0 }

        self.isDownEnabled = _isDownEnabled
        self.count = _count.map(String.init)
        self.downAlpha = _isDownEnabled.map { $0 ? 1 : 0.5 }

        Observable.merge(upButtonTapped.map { 1 },
                         downButtonTapped.map { -1 })
            .withLatestFrom(_count.asObservable()) { $1 + $0 }
            .bind(to: _count)
            .disposed(by: disposeBag)
    }
}
