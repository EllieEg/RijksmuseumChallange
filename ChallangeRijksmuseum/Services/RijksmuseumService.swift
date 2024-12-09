//
//  RijksmuseumService.swift
//  RijksmuseumChallange
//
//  Created by Ellie Egenvall on 2024-12-02.
//

import Foundation

/// Service class responsible for communicating with the Rijksmuseum API
actor RijksmuseumService {
    // MARK: - Properties
    
    /// API key required for authentication with the Rijksmuseum API
    private let apiKey: String
    /// Base URL for the Rijksmuseum API
    private let baseURL = "https://www.rijksmuseum.nl/api/en"
    
    // MARK: - Initialization
    
    /// Creates a new RijksmuseumService instance
    /// - Parameter apikey: The API key for authentication
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Public Methods
    
    /// Fetches artworks from the Rijksmuseum API
    /// - Parameters:
    /// - page:The page number to fetch
    /// - searchQuery: Optional search term to filter artworks
    /// - Returns: An array of artwork objects
    /// - Throws: RijksmuesumError for various failure cases:
    /// - invalidURL: If the API URL cannot be constructed
    /// - .networkError: For general network failures
    /// - .noInternetConnection: When device is offline
    /// - .serverError: For 500-level server errors
    /// - .tooManyRequests: When exceeding API rate limits
    /// - .noData: When no artworks are found
    func fetchArtworks(page: Int = 1, searchQuery: String? = nil) async throws -> [Artwork] {
        var components = URLComponents(string: "\(baseURL)/collection")
        
        var queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "ps", value: "10"), // Page size
            URLQueryItem(name: "p", value: String(page))
        ]
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: searchQuery))
        }
        
        components?.queryItems = queryItems
        
        /// checks if the URL is valid
        guard let url = components?.url else {
            throw RijksmuseumError.invalidURL
        }
        do {
            // Attempt to fetch data from the API
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RijksmuseumError.networkError
            }
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200: // Success
                let decoder = JSONDecoder()
                let artworkResponse = try decoder.decode(ArtworkResponse.self, from: data)
                
                if artworkResponse.artObjects.isEmpty {
                    throw RijksmuseumError.NoData
                }
                return artworkResponse.artObjects
                
            case 429: // Too many requests
                throw RijksmuseumError.toManyRequests
            case 500...599: // Server Errors
                throw RijksmuseumError.serverError
            default: // Any other error responses 
                throw RijksmuseumError.networkError
            }
        } catch let error as RijksmuseumError {
            // Re-throw our custom errors
            throw error
        } catch let error as URLError {
            // Convert URLError to our custom error types
            switch error.code {
            case .notConnectedToInternet:
                throw RijksmuseumError.noInternetConnection
            default:
                throw RijksmuseumError.networkError
            }
        } catch {
            // Handle any unexpected errors
            throw RijksmuseumError.networkError
        }
    }
}
