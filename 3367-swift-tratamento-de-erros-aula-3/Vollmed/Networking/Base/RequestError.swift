//
//  RequestError.swift
//  Vollmed
//
//  Created by ALURA on 06/10/23.
//

import Foundation

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unknown
    case custom(error: [String: Any]?)
    
    var customMessage: String {
        switch self {
        case .decode:
            return "erro de decodificação"
        case .unauthorized:
            return "sessão expirada"
        case .custom(let errorData):
            if let jsonError = errorData?["error"] as? [String: Any] {
                let message = jsonError["message"] as? String ?? ""
                return message
            }
            return "Ops! Ocorreu um erro ao carregar as informações"
        default:
            return "erro desconhecido"
        }
    }
}
