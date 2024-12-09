//
//  RijksmuseumError.swift
//  RijksmuseumChallange
//
//  Created by Ellie Egenvall on 2024-12-04.
//

import Foundation

/// Represents possible errors that can occur when interacting with the Rijksmuseum API
/// Conforms to LocalizedError to provide user-friendly error descriptions
enum RijksmuseumError: LocalizedError {
    /// the URL for the API request could not be constructed
    case invalidURL
    /// A general network error occured during the API request
    case networkError
    /// The device has no active internet connection
    case noInternetConnection
    /// The server responded with a 500-level error
    case serverError
    /// Too many request were made to the API
    case toManyRequests
    /// No artwork data was found for the given request
    case NoData
    
    /// Provides user-friendly messages for each error case
    /// - Returns: A localized desription of the error duitable for user diasplay
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request. Please try again later"
        case .networkError:
            return "Something went wrong with the network. Please try again."
        case .noInternetConnection:
            return "No internet connection. Please check your connection and try again."
        case .serverError:
            return "The server is having problems. Please try again later."
        case .toManyRequests:
            return "Too many requests. Please wait a moment and try again."
        case .NoData:
            return "No artworks found. Try a different search."
        }
    }
}
