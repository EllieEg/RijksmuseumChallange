//
//  ArtworkListView.swift
//  RijksmuseumChallange
//
//  Created by Ellie Egenvall on 2024-12-02.
//

import Foundation
import UIKit

/// Manages the state and business logic for the artwork list view
@MainActor
class ArtworkListViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// Currently disaplayed artworks
    @Published var artworks: [Artwork] = []
    /// Currently selected artwork
    @Published var selectedArtwork: Artwork?
    /// Indicated if data is currently being loaded
    @Published var isLoading = false
    /// Error message to display to the user, if there is any
    @Published var errorMessage: String?
    /// Indicates if more pages are avaliable to load
    @Published var hasMorePages = true
    
    // MARK: - Private properties
    /// Current oage number for pagniartion
    private var currentPage = 1
    /// Service used to fetch artwork data
    private let service: RijksmuseumService
    /// Keeps track of the last search query to prevent duplicate searches
    private var lastSearchQuery: String?
    
    // MARK: - Initialization
    
    /// Creates a new ArtWorkListViewModel
    /// - Parameter service: The service is used to fetch artwork data
    init(service: RijksmuseumService) {
        self.service = service
    }
    
    // MARK: - Public Methods
    /// serarches for artworkds using the provided query
    /// - Parameter serachQueary: Optional search term to filter artworks
    /// if nil, returns all artworks
    func searchArtworks(searchQuery: String?) async {
        guard !isLoading else { return }
        
        // Prevent duplicate searches with same query
        if searchQuery == lastSearchQuery && !artworks.isEmpty {
            return
        }
        isLoading = true
        errorMessage = nil
        lastSearchQuery = searchQuery
        
        do {
            let newArtworks = try await service.fetchArtworks(page: currentPage, searchQuery: searchQuery)
            artworks = newArtworks
            hasMorePages = !newArtworks.isEmpty
            
            // Auto-select first artwork on Ipad for better UX
            if UIDevice.current.userInterfaceIdiom == .pad && selectedArtwork == nil {
                selectedArtwork = newArtworks.first
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    /// Loads the next page of artworks when user scrolls near the end of the list
    /// Parameter searchQuery: Optional search term to maintain consistency with current search
    func loadMoreArtworks(searchQuery: String?) async {
        guard !isLoading && hasMorePages else { return }
        isLoading = true
        
        do {
            currentPage += 1
            let newArtworks = try await service.fetchArtworks(page: currentPage, searchQuery: searchQuery)
            artworks.append(contentsOf: newArtworks)
            hasMorePages = !newArtworks.isEmpty
        } catch {
            errorMessage = error.localizedDescription
            currentPage -= 1 // Revert page increment on error
        }
        
        isLoading = false
    }
    
    /// Resets pagniation state to intitial values
    /// Called when starting a new search or refreshing the list
    func resetPagination() {
        currentPage = 1
        artworks = []
        hasMorePages = true
    }
    
    //MARK: - Private Methods
    
    /// Processes errors from the Rijksmuseum service and updates the error message for display
    /// - Parameter error: The error to handle, either a RijksmuseumError or another Error type
    private func handleError(_ error: Error) {
        if let rijksError = error as? RijksmuseumError {
            // Use the localized description from our custom error type
            errorMessage = rijksError.errorDescription
        } else {
            // Handle unexpected errors
            errorMessage = "An unexpected error occurred. Please try again."
        }
    }
}
