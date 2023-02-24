//
//  CustomAPIError.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 22..
//

import Foundation

enum ErrorMessage: Codable {
    case single(String)
    case multiple([String: [String]])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .single(value)
        } else if let value = try? container.decode([String: [String]].self) {
            self = .multiple(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Hiba történt")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let value):
            try container.encode(value)
        case .multiple(let value):
            try container.encode(value)
        }
    }
}

enum CustomAPIError: Error {
    case missingData(String)
    case networkError(String)
    case invalidURL(String)
    case validationError(String)
    case wrongDataFormat(String)
    case unexpectedError(String)
    
    public var toString: String {
        switch self {
        case .missingData(let string):
            return string
        case .networkError(let string):
            return string
        case .invalidURL(let string):
            return string
        case .validationError(let string):
            return string
        case .wrongDataFormat(let string):
            return string
        case .unexpectedError(let string):
            return string
        }
    }
}
