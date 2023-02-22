//
//  StatesViewController.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 21..
//

import UIKit

class StatesViewController: UIViewController {
    
    // MARK: - Properties
    private let loadingSpinner = UIActivityIndicatorView(style: .large)
    
    private var states: [State]? = nil
    
    private let statesTableView = LocationsTableView()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statesTableView.delegate = self
        statesTableView.dataSource = self
        statesTableView.register(LocationTableViewCell.self, forCellReuseIdentifier: LocationTableViewCell.identifier)
        
        setupUI()
        fetchStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Megyék"
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - Helpers
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(statesTableView)
        view.addSubview(loadingSpinner)
        
        NSLayoutConstraint.activate([
            statesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
    }
    
    private func fetchStates() {
        loadingSpinner.startAnimating()
        APICaller.shared.fetchAllStates { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let states):
                DispatchQueue.main.async {
                    strongSelf.states = states.data
                    strongSelf.statesTableView.reloadData()
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

extension StatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let state = states?[indexPath.row] else { //This should never happen.
            print("Error selecting state")
            //TODO: - Show alert here
            return
        }
        let cityViewController = CitiesViewController(state: state)
        navigationController?.pushViewController(cityViewController, animated: true)        
    }
}

// MARK: - UITableViewDataSource

extension StatesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let states = states else {
            return UITableViewCell.init()
        }
        
        let cell = statesTableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        cell.configureCell(with: states[indexPath.row])
        return cell
    }
}
