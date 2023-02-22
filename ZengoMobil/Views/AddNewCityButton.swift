//
//  AddNewCityButton.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 22..
//

import Foundation
import UIKit

class AddNewCityButton: UIButton {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: UIScreen.main.bounds.width / 7, weight: .medium, scale: .large)
        let largeImage = UIImage(systemName: "plus.circle", withConfiguration: largeConfig)
        
        setImage(largeImage, for: .normal)
        tintColor = .label
    }
    
    // MARK: - Selectors
    
}

