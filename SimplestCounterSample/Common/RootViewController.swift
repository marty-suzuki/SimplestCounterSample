//
//  RootViewController.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/02/06.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit

final class RootViewController: UIViewController {

    fileprivate enum Pattern {
        case mvc
        case mvp
        case mvvm
        case flux
        case vueFlux
        case fluxCapacitor
        case fluxWithRxSwift
    }

    @IBOutlet private weak var tableView: UITableView!

    private let patterns: [Pattern] = {
        var n = 0
        return Array(AnyIterator {
            defer { n += 1 }
            let next = withUnsafePointer(to: &n) {
                UnsafeRawPointer($0).assumingMemoryBound(to: Pattern.self).pointee
            }
            return next.hashValue == n ? next : nil
        })
    }()

    private let cellIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patterns.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = patterns[indexPath.row].text
        return cell
    }
}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pattern = patterns[indexPath.row]
        let viewController = pattern.makeViewController()
        viewController.navigationItem.title = pattern.text
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension RootViewController.Pattern {
    var text: String {
        switch self {
        case .mvc            : return "MVC"
        case .mvp            : return "MVP"
        case .mvvm           : return "MVVM with RxSwift"
        case .flux           : return "Flux"
        case .vueFlux        : return "Flux with VueFlux"
        case .fluxCapacitor  : return "Flux with FluxCapacitor"
        case .fluxWithRxSwift: return "Flux with RxSwift"
        }
    }

    func makeViewController() -> UIViewController {
        switch self {
        case .mvc            : return MVCSampleViewController.makeFromNib()
        case .mvp            : return MVPSampleViewController.makeFromNib()
        case .mvvm           : return MVVMWithRxSwiftSampleViewController.makeFromNib()
        case .flux           : return FluxSampleViewController.makeFromNib()
        case .vueFlux        : return VueFluxSampleViewController.makeFromNib()
        case .fluxCapacitor  : return FluxCapacitorSampleViewController.makeFromNib()
        case .fluxWithRxSwift: return FluxWithRxSwiftSampleViewController.makeFromNib()
        }
    }
}
