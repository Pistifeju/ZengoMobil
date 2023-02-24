//
//  AlertManager.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 22..
//

import UIKit

final class AlertManager {
    
    static let shared = AlertManager()
    
    private init () {}
    
    func showBasicAlert(on VC: UIViewController, with title: String, and message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Vissza", style: .default))
            VC.present(alert, animated: true)
        }
    }
}
