//
//  APIResponse.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 22..
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let errorCode: Int?
    let errorMessage: String?
    var data: T? = nil
    
    enum CodingKeys: String, CodingKey {
        case success
        case errorCode
        case errorMessage
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try container.decodeIfPresent(Int.self, forKey: .errorCode)
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        
        if let data = try? container.decode(T.self, forKey: .data) {
            self.data = data
        } else if (try? container.decode(String.self, forKey: .data)) != nil {
            self.data = nil
        } else {
            self.data = try container.decodeIfPresent(T.self, forKey: .data)
        }
    }
}

