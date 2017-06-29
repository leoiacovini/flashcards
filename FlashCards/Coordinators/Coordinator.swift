//
//  Coordinator.swift
//  FlashCards
//
//  Created by Leonardo Iacovini on 27/06/17.
//  Copyright © 2017 Leonardo Iacovini. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var navigationController: UINavigationController! { get set }
    var childCoordinators: Array<Coordinator> { get set }
    func start()
}

extension Coordinator {
    func addChildCoordinator(coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(coordinator: Coordinator) {
        childCoordinators = self.childCoordinators.filter { $0 !== coordinator  }
    }
    
    func presentCoordinator(_ coordinator: Coordinator) {
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
}

extension Coordinator {
    func loadFromStoryboard(identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}
