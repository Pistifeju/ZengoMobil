//
//  CitiesViewController.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 22..
//

import Foundation
import UIKit

class CitiesViewController: UIViewController {
    
    // MARK: - Properties
    
    private let state: State
    private var cities: [City] = [City]()
    
    private let addNewCityButton = AddNewCityButton(type: .system)
    private let citiesTableView = LocationsTableView()
    
    private let loadingSpinner = UIActivityIndicatorView(style: .large)
    // MARK: - LifeCycle
    
    init(state: State) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.dataSource = self
        citiesTableView.delegate = self
        citiesTableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.identifier)
        
        addNewCityButton.addTarget(self, action: #selector(didTapAddNewCityButton), for: .touchUpInside)
        
        setupUI()
        fetchCities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = state.name
        navigationController?.navigationBar.tintColor = .label
    }
    
    // MARK: - Helpers
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(citiesTableView)
        view.addSubview(loadingSpinner)
        view.addSubview(addNewCityButton)
        
        NSLayoutConstraint.activate([
            citiesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            citiesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            citiesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            citiesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addNewCityButton.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.bottomAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: addNewCityButton.trailingAnchor, multiplier: 2),
        ])
    }
    
    private func fetchCities() {
        loadingSpinner.startAnimating()
        APICaller.shared.fetchCitiesForState(stateID: state.id) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let cities):
                DispatchQueue.main.async {
                    strongSelf.loadingSpinner.stopAnimating()
                    strongSelf.loadingSpinner.hidesWhenStopped = true
                    strongSelf.cities = cities.data ?? []
                    strongSelf.citiesTableView.reloadData()
                }
            case .failure(let error):
                print(error)
                print("Error happened: \(error.localizedDescription)")
                //TODO: - Show alert here
            }
        }
    }
    
    // MARK: - Selectors
    
    @objc private func didTapAddNewCityButton() {
        let alertController = UIAlertController(title: "Új város", message: "Új város hozzáadása.", preferredStyle: .alert)
        
        var citiesName = [String]()

        citiesName = cities.map({$0.name.lowercased()})
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Város név"
        }
        
        let createCityAction = UIAlertAction(title: "Hozzáadás", style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            if let textField = alertController.textFields?.first, let cityName = textField.text {
                if citiesName.contains(cityName.lowercased()) {
                    AlertManager.shared.showBasicAlert(on: strongSelf, with: "Létező város", and: "Ilyen nevű város már létezik.")
                } else {
                    let stateID = strongSelf.state.id
                    let city = City(id: stateID, name: cityName)
                    let requestType = RequestType.createNewCity(city: city)
                    city.performRequestOnCity(with: requestType) { result in
                        switch result {
                        case .success(let city):
                            guard let city = city else { return }
                            DispatchQueue.main.async {
                                strongSelf.cities.append(city)
                                strongSelf.citiesTableView.reloadData()
                            }
                        case .failure(let error):
                            // TODO: - Show error alert here
                            print(error)
                        }
                    }
                }
            }
        }
        
        let dismissAction = UIAlertAction(title: "Vissza", style: .cancel)
        alertController.addAction(dismissAction)
        alertController.addAction(createCityAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension CitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath)
        let selectedCity = cities[indexPath.row]
        
        let alertController = UIAlertController(title: "Város szerkesztés", message: "Add meg a város új nevét.", preferredStyle: .alert)
        
        let citiesName = cities.map({$0.name.lowercased()})
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Város név"
        }
        
        let createCityAction = UIAlertAction(title: "Szerkeszt", style: .default) { [weak self] (action) in
            guard let strongSelf = self else { return }
            if let textField = alertController.textFields?.first, let cityName = textField.text {
                if citiesName.contains(cityName.lowercased()) {
                    AlertManager.shared.showBasicAlert(on: strongSelf, with: "Létező város", and: "Ilyen nevű város már létezik.")
                } else {
                    let newCity = City(id: selectedCity.id, name: cityName)
                    let requestType = RequestType.updateCity(city: newCity)
                    newCity.performRequestOnCity(with: requestType) { result in
                        switch result {
                        case .success(let city):
                            guard let city = city else { return }
                            DispatchQueue.main.async {
                                strongSelf.cities[indexPath.row] = city
                                strongSelf.citiesTableView.reloadData()
                            }
                        case .failure(let error):
                            // TODO: - Show error alert here
                            print(error)
                        }
                    }
                }
            }
        }
        
        let dismissAction = UIAlertAction(title: "Vissza", style: .cancel)
        alertController.addAction(dismissAction)
        alertController.addAction(createCityAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension CitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedCity = cities[indexPath.row]
            let requestType = RequestType.deleteCity(city_id: selectedCity.id)
            selectedCity.performRequestOnCity(with: requestType) { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.cities.remove(at: indexPath.row)
                        self.citiesTableView.deleteRows(at: [indexPath], with: .fade)
                    }
                case .failure(let error):
                    // TODO: - Show error alert here
                    print(error)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !cities.isEmpty else {
            return UITableViewCell.init()
        }
        
        let cell = citiesTableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        cell.configureCell(with: cities[indexPath.row])
        cell.accessoryType = .none
        return cell
    }
}

