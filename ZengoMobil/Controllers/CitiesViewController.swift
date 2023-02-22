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
    private var cities: [City]? = nil
    
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
                    strongSelf.cities = cities.data
                    strongSelf.citiesTableView.reloadData()
                    strongSelf.loadingSpinner.stopAnimating()
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
        let alertController = UIAlertController(title: "New City", message: "Create a new city", preferredStyle: .alert)
        
        var citiesName = [String]()
        
        if let cities {
            citiesName = cities.map({$0.name.lowercased()})
        }
                
        alertController.addTextField { (textField) in
            textField.placeholder = "City Name"
        }
        
        let createCityAction = UIAlertAction(title: "Create", style: .destructive) { [weak self] (action) in
            guard let strongSelf = self else { return }
            if let textField = alertController.textFields?.first, let cityName = textField.text {
                if citiesName.contains(cityName.lowercased()) {
                    AlertManager.shared.showBasicAlert(on: strongSelf, with: "City already exists", and: "A city with this name already exists.")
                } else {
                    let city = City(id: strongSelf.state.id, name: cityName)
                    APICaller.shared.createNewCity(with: city) { [weak self] result in
                        switch result {
                        case .success(let city):
                            guard let city = city.data else { return }
                            strongSelf.cities?.append(city)
                            DispatchQueue.main.async {
                                strongSelf.citiesTableView.reloadData()
                            }
                        case .failure(let error):
                            //TODO: - SHOW ALERT HERE
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }

        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
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
        // TODO: - FINISH SELECTION
    }
}

// MARK: - UITableViewDataSource

extension CitiesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cities = cities else {
            return UITableViewCell.init()
        }
        
        let cell = citiesTableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        cell.configureCell(with: cities[indexPath.row])
        cell.accessoryType = .none
        return cell
    }
}

