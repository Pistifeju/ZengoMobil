//
//  StatesTableView.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 22..
//

import Foundation
import UIKit

class LocationsTableView: UITableView {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        estimatedRowHeight = 44
        rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Selectors
    
}

