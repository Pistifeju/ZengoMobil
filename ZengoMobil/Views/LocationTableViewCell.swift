//
//  LocationTableViewCell.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 22..
//

import Foundation
import UIKit

class LocationTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private var location: Location? = nil
    
    private let locationNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()
    
    static let identifier = "LocationNameLabel"
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(locationNameLabel)
        
        NSLayoutConstraint.activate([
            locationNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
            trailingAnchor.constraint(equalToSystemSpacingAfter: locationNameLabel.trailingAnchor, multiplier: 2),
            locationNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    func configureCell(with location: Location ) {
        locationNameLabel.text = location.name
        self.location = location
    }
    
    // MARK: - Selectors
    
}

