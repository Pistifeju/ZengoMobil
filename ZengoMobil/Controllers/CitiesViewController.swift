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
        
    private let loadingSpinner = UIActivityIndicatorView(style: .large)
    
    private let state: State
    private var cities: [City]? = nil

    private let citiesTableView = LocationsTableView()
    
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
        
        setupUI()
        fetchCities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = state.name
        navigationController?.navigationBar.tintColor = .black
    }
    
    // MARK: - Helpers
    private func setupUI() {
        view.backgroundColor = .systemBlue
        
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(citiesTableView)
        view.addSubview(loadingSpinner)
        
        NSLayoutConstraint.activate([
            citiesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            citiesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            citiesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            citiesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func fetchCities() {
        loadingSpinner.startAnimating()
        APICaller.shared.fetchCitiesForState(stateID: state.id) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let cities):
                DispatchQueue.main.async {
                    print(cities)
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
        return cell
    }
    
    
}
