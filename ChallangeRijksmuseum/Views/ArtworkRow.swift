//
//  ArtworkRow.swift
//  RijksmuseumChallange
//
//  Created by Ellie Egenvall on 2024-12-02.
//

import SwiftUI

/// A row view that displays a preview of an artwork in a list
struct ArtworkRow: View {
    // MARK: - Environment & Properties
    
    /// Manager for handling the favorite status of artworks
    @ObservedObject var favoritesManager: FavoritesManager
    
    /// Used to determine the current size class for adaptive layout
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The artwork to display in this row
    let artwork: Artwork
    
    // MARK: Body
    var body: some View {
        HStack(spacing: getSpacing()) {
            if let imageURL = artwork.webImage?.url {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: getThumbnailSize(), height: getThumbnailSize())
                        .clipped()
                        .cornerRadius(8)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: getThumbnailSize(), height: getThumbnailSize())
                        .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.title)
                    .font(getTitleFont())
                    .lineLimit(2)
                Text(artwork.principalOrFirstMaker)
                    .font(getSubtitleFont())
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            // Favorite toggle button
            Button(action: {
                _ = favoritesManager.toggleFavorite(for: artwork.id)
            }) {
                Image(systemName: favoritesManager.isFavorite(artwork.id) ? "heart.fill" : "heart")
                    .foregroundColor(favoritesManager.isFavorite(artwork.id) ? .red : .gray)
            }
            .buttonStyle(BorderlessButtonStyle()) // Prevents button from capturing whole row tap
        }
        .padding(.vertical, 4)
    }
    // MARK: Helper Methods
    
    /// Returns appropriate spacing based on device size
    /// - Returns: Spacing for the current size class
    private func getSpacing() -> CGFloat {
        horizontalSizeClass == .regular ? 16 : 12
    }
    /// Returns appropriate thumbnail size based on device size
    /// - Returns: Size for the artwork thumbnail
    private func getThumbnailSize() -> CGFloat {
        horizontalSizeClass == .regular ? 100 : 80
    }
    /// Returns appropriate title font based on device size
    /// - Returns: Font for the artworks title
    private func getTitleFont() -> Font {
        horizontalSizeClass == .regular ? .title3 : .headline
    }
    /// Returns appropriate subtitle font based on device size
    /// - Returns: Font for the artist name
    private func getSubtitleFont() -> Font {
        horizontalSizeClass == .regular ? .body : .subheadline
    }
}

#Preview {
        let sampleArtwork = Artwork(
                id: "SK-A-1234",
                title: "Sample Artwork",
                principalOrFirstMaker: "Sample Artist",
                webImage: ImageObject(
                    guid: "sample-guid",
                    url: URL(string: "https://picsum.photos/400")!,
                    width: 400,
                    height: 300
                    )
                )
    return NavigationView {
        ArtworkRow(favoritesManager: FavoritesManager(), artwork: sampleArtwork)
    }
}

