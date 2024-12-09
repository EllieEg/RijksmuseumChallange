//
//  Artwork.swift
//  RijksmuseumChallange
//
//  Created by Ellie Egenvall on 2024-12-02.
//

import Foundation

/// Represents the top-levek response from the Rijksmuseum API
struct ArtworkResponse: Codable {
    /// Total count of artworks avaliable
    let count: Int
    /// Array of artwork objects returned in this response
    let artObjects: [Artwork]
}

/// Represents a single artwork from the Rijksmuseum collection
struct Artwork: Codable, Identifiable, Equatable, Hashable {
    /// Unique identifier for the artwork
    let id: String
    /// Title of the artwork
    let title: String
    /// Name of the primary artist or creator
    let principalOrFirstMaker: String
    /// Image information for the artwork, if avaliable
    let webImage: ImageObject?
    
    /// Mapping between API response keys and local property names
    enum CodingKeys: String, CodingKey {
        case id = "objectNumber"
        case title
        case principalOrFirstMaker
        case webImage
    }
    /// Implements Hashable protocol using the artwork´s unique identifier
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
    }
}
