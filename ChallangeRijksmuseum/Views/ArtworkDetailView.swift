//
//  ArtworkDetailView.swift
//  RijksmuseumChallange
//
//  Created by Ellie Egenvall on 2024-12-02.
//

import SwiftUI

/// A view that sisplayes detailed information about an artwork
struct ArtworkDetailView: View {
    // MARK: - Environment and Properties
    /// Determines the current size class for adaptive layout
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    /// Manager for handling the favorite status of artworks
    @ObservedObject var favoritesManager: FavoritesManager
    /// the artwork to display details for
    let artwork: Artwork
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: getspacing()) {
                //MARK: - Artwork Image
                if let imageURL = artwork.webImage?.url {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(16/9, contentMode: .fit)
                    }
                }
                // MARK: Artwork Information
                VStack(alignment: .leading, spacing: 12) {
                    Text(artwork.title)
                        .font(getTitleFont())
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Favorite toggle button in detail view
                    Button(action: {
                        _ = favoritesManager.toggleFavorite(for: artwork.id)
                    }) {
                        Image(systemName: favoritesManager.isFavorite(artwork.id) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesManager.isFavorite(artwork.id) ? .red : .gray)
                            .imageScale(.large)
                    }
                    
                    Text(artwork.principalOrFirstMaker)
                        .font(getSubtitleFont())
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Text("Object Number:")
                            .fontWeight(.medium)
                        Text(artwork.id)
                    }
                    .font(.subheadline)
                }
                .padding(getPadding())
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    // MARK: - Helper Methods
    
    /// Returns the approptiate spacing based on device size
    /// - Returns: Spacinf value for the current size class
    private func getspacing() -> CGFloat {
        horizontalSizeClass == .regular ? 24 : 16
    }
    /// Returns the appropriate padding based on device size
    /// - Returns: Padding value for the current size class
    private func getPadding() -> CGFloat {
        horizontalSizeClass == .regular ? 24 : 16
    }
    /// Returns the appropriate title font based on device class
    /// - Returns: Font for artwork title
    private func getTitleFont() -> Font {
        horizontalSizeClass == .regular ? .largeTitle : .title
    }
    /// Returns the appropriate subtitle font based on device class
    /// - Returns: Font for the artist name
    private func getSubtitleFont() -> Font {
        horizontalSizeClass == .regular ? .title2 : .title3
    }
}
// MARK: - Preview Provider 
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
        ArtworkDetailView(favoritesManager: FavoritesManager(), artwork: sampleArtwork)
    }
}

