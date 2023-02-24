//
//  APICaller.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 21..
//
import Foundation

enum RequestType {
    case createNewCity(city: City)
    case deleteCity(city_id: Int)
    case updateCity(city: City)
}

class APICaller {
    
    static let shared = APICaller()
    private init () {}
    
    private let token = "8cca895f10303c554c2762fb7179eb89"
    
    private let allStatesURLString = "https://probafeladat-api.zengo.eu/api/all_states"
    private let citiesForStateURLString = "https://probafeladat-api.zengo.eu/api/state_city"
    private let cityURLString = "https://probafeladat-api.zengo.eu/api/city"
    
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
            if error != nil {
                completion(.failure(CustomAPIError.networkError("Váratlan hiba történt.")))

                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(CustomAPIError.networkError("Hálózati hiba történt. Kérjük, ellenőrizze az internetkapcsolatát, és próbálja meg újra.")))
                return
            }
            
            guard let data = data else {
                completion(.failure(CustomAPIError.missingData("A kiszolgáló üres választ küldött vissza.")))
                return
            }
            
            do {
                let APIResponse = try JSONDecoder().decode(APIResponse<[State]>.self, from: data)
                
                if APIResponse.success {
                    completion(.success(APIResponse))
                    return
                } else {
                    completion(.failure(CustomAPIError.unexpectedError(APIResponse.errorMessage.debugDescription)))
                    return
                }
                
            } catch {
                completion(.failure(CustomAPIError.wrongDataFormat("A kiszolgáló nem várt formátumban küldte vissza az adatokat.")))
                return
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
            completion(.failure(CustomAPIError.networkError("Váratlan hiba történt.")))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(CustomAPIError.networkError("Váratlan hiba történt.")))
                return
            }
            
            guard response is HTTPURLResponse else {
                completion(.failure(CustomAPIError.networkError("Hálózati hiba történt. Kérjük, ellenőrizze az internetkapcsolatát, és próbálja meg újra.")))
                return
            }
                        
            guard let data = data else {
                completion(.failure(CustomAPIError.missingData("A kiszolgáló üres választ küldött vissza.")))
                return
            }
            
            do {
                let APIResponse = try JSONDecoder().decode(APIResponse<[City]>.self, from: data)
                if APIResponse.success {
                    completion(.success(APIResponse))
                    return
                } else {
                    if let errorMessage = APIResponse.errorMessage {
                        switch errorMessage {
                            
                        case .single(let singleError):
                            completion(.failure(CustomAPIError.unexpectedError(singleError)))
                            return
                        case .multiple(let multipleErrors):
                            for singleError in multipleErrors {
                                completion(.failure(CustomAPIError.unexpectedError(singleError.value.first ?? "Váratlan hiba történt.")))
                                return
                            }
                        }
                    }
                }
                
            } catch {
                completion(.failure(CustomAPIError.wrongDataFormat("A kiszolgáló nem várt formátumban küldte vissza az adatokat.")))
                return
            }
        }
        task.resume()
    }
    
    func performRequest(_ requestType: RequestType, completion: @escaping(Result<APIResponse<City>, Error>) -> Void) {
        guard let url = URL(string: cityURLString) else {
            completion(.failure(URLError.init(.badURL)))
            return
        }
        
        var httpMethod: String
        var httpBody: Data?
        var body: [String: Any]
        
        switch requestType {
        case .createNewCity(city: let city):
            httpMethod = "PUT"
            body = ["name": city.name, "state_id": city.id]
        case .deleteCity(city_id: let city_id):
            httpMethod = "DELETE"
            body = ["city_id": city_id]
        case .updateCity(city: let city):
            httpMethod = "PATCH"
            body = ["name": city.name, "city_id": city.id]
        }
        
        do {
            httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(CustomAPIError.unexpectedError("Váratlan hiba történt.")))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(token, forHTTPHeaderField: "token")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                completion(.failure(CustomAPIError.networkError("Váratlan hiba történt.")))
                return
            }
            
            guard response is HTTPURLResponse else {
                completion(.failure(CustomAPIError.networkError("Hálózati hiba történt. Kérjük, ellenőrizze az internetkapcsolatát, és próbálja meg újra.")))
                return
            }
            
            guard let data = data else {
                completion(.failure(CustomAPIError.missingData("A kiszolgáló üres választ küldött vissza.")))
                return
            }
                                    
            do {
                let APIResponse = try JSONDecoder().decode(APIResponse<City>.self, from: data)
                
                if APIResponse.success {
                    completion(.success(APIResponse))
                    return
                } else {
                    if let errorMessage = APIResponse.errorMessage {
                        switch errorMessage {
                            
                        case .single(let singleError):
                            completion(.failure(CustomAPIError.unexpectedError(singleError)))
                            return
                        case .multiple(let multipleErrors):
                            for singleError in multipleErrors {
                                completion(.failure(CustomAPIError.unexpectedError(singleError.value.first ?? "Váratlan hiba történt.")))
                                return
                            }
                        }
                    }
                }
            } catch {
                completion(.failure(CustomAPIError.wrongDataFormat("A kiszolgáló nem várt formátumban küldte vissza az adatokat.")))
                return
            }
        }
        task.resume()
    }
}
