//
//  City.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 22..
//

import Foundation

struct City: Codable, Location {
    var id: Int
    var name: String
    
    func performRequestOnCity(with request: RequestType, completion: @escaping (Result<City?, Error>) -> Void) {
        APICaller.shared.performRequest(request) { result in
            switch result {
            case .success(let city):
                completion(.success(city.data))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
}
