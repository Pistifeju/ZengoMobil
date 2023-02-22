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
    let data: T?
}
