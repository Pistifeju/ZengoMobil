//
//  APICaller.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 21..
//
import Foundation

class APICaller {
    
    static let shared = APICaller()
    private init () {}
    
    private let token = "8cca895f10303c554c2762fb7179eb89"
    
    private let allStatesURLString = "https://probafeladat-api.zengo.eu/api/all_states"
    private let citiesForStateURLString = "https://probafeladat-api.zengo.eu/api/state_city"
    private let cityURLString = "https://probafeladat-api.zengo.eu/api/city/"
    
    func fetchAllStates(completion: @escaping(Result<APIResponse<[State]>, Error>) -> Void) {
        guard let url = URL(string: allStatesURLString) else {
            completion(.failure(URLError.init(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "token")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(CustomAPIError.networkError(error.localizedDescription)))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(CustomAPIError.networkError("A network error occurred. Please check your internet connection and try again.")))
                return
            }
            
            guard let data = data else {
                completion(.failure(CustomAPIError.missingData("The server returned an empty response.")))
                return
            }
            
            do {
                let APIResponse = try JSONDecoder().decode(APIResponse<[State]>.self, from: data)
                
                if APIResponse.success {
                    completion(.success(APIResponse))
                } else {
                    completion(.failure(CustomAPIError.unexpectedError(APIResponse.errorMessage ?? "An unexpected error occurred. Please try again later.")))
                }
                
            } catch {
                completion(.failure(CustomAPIError.wrongDataFormat("The server returned data in an unexpected format.")))
            }
        }
        task.resume()
    }
    
    func fetchCitiesForState(stateID: Int, completion: @escaping(Result<APIResponse<[City]>, Error>) -> Void) {
        guard let url = URL(string: citiesForStateURLString) else {
            completion(.failure(URLError.init(.badURL)))
            return
        }
        
        let parameters = ["state_id": stateID]
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "token")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch {
            completion(.failure(CustomAPIError.unexpectedError("Unexpected error happened"))) //This should never happen though.
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(CustomAPIError.networkError(error.localizedDescription)))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(CustomAPIError.networkError("A network error occurred. Please check your internet connection and try again.")))
                return
            }
                        
            guard let data = data else {
                completion(.failure(CustomAPIError.missingData("The server returned an empty response.")))
                return
            }
            
            do {
                let APIResponse = try JSONDecoder().decode(APIResponse<[City]>.self, from: data)
                
                if APIResponse.success {
                    completion(.success(APIResponse))
                } else {
                    completion(.failure(CustomAPIError.unexpectedError(APIResponse.errorMessage ?? "An unexpected error occurred. Please try again later.")))
                }
                
            } catch {
                completion(.failure(CustomAPIError.wrongDataFormat("The server returned data in an unexpected format.")))
            }
        }
        task.resume()
        
    }
}
