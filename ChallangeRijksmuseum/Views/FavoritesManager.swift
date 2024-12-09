//
//  FavoritesManager.swift
//  RijksmuseumChallange
//
//  Created by Ellie Egenvall on 2024-12-05.
//

import Foundation

/// Manages the saving and loading of favorite artworks
class FavoritesManager: ObservableObject {
    /// Published array of favorite artwork IDs
    @Published private(set) var favoriteIds: Set<String> = []
    
    /// Key used for storing favorites in UserDefaults
    private let favoritesKey = "FavoriteArtworks"
    
    /// Initializes the FavoritesManager and loads any previously saved favorites
    init() {
        loadFavorites()
    }
    
    /// Loads saved favorites from UserDefaults
    private func loadFavorites() {
        if let savedIds = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteIds = Set(savedIds)
        }
    }
    /// Saves current favorites to UserDefaults
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: favoritesKey)
    }
    /// Toggle the favorite status of an artwork
    /// - Parameter id: The ID of the artwork to toggle
    /// - Returns: The new favorite status
    func toggleFavorite(for id: String) -> Bool {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
        saveFavorites()
        return favoriteIds.contains(id)
    }
    
    /// Checks if an artwork is favorited
    /// - Parameter id: The ID of the artwork to check
    /// - Returns: True if the artwork is favorited
    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }
}
