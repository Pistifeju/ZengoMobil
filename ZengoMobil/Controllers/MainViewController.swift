//
//  MainViewController.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 21..
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchStates()
        
        self.setupUI()
    }
    
    // MARK: - Helpers
    private func setupUI() {
        self.view.backgroundColor = .systemBlue
        
        NSLayoutConstraint.activate([
            
        ])
    }
    
    private func fetchStates() {
        APICaller.shared.fetchAllStates { result in
            switch result {
            case .success(let states):
                print(states)
                print("Success")
            case .failure(let error):
                print(error)
                print("Error happened: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Selectors
}
