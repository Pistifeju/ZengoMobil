//
//  CustomAPIError.swift
//  ZengoMobil
//
//  Created by István Juhász on 2023. 02. 22..
//

import Foundation

enum CustomAPIError: Error {
    case missingData(String)
    case networkError(String)
    case invalidURL(String)
    case validationError(String)
    case wrongDataFormat(String)
    case unexpectedError(String)
}
