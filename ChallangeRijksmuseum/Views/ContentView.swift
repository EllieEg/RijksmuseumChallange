//
//  ContentView.swift
//  RijksmuseumChallange
//
//  Created by Ellie Egenvall on 2024-12-02.
//

import SwiftUI
import Combine

/// Main view of the Rijksmuseum app that displays a list of artworks and handles search functionality
/// Implements a sl´plit view layout for Ipad support and handles search with debouncing
struct ContentView: View {
    
    // MARK: - Properties
    /// View model that manages the artwork list state and business logic
    @StateObject private var viewModel: ArtworkListViewModel
    
    @StateObject private var favoritesManager = FavoritesManager()

    /// Current search text entered by the user
    @State private var searchText = ""
    /// Task that handles search debouncing
    @State private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    /// Creates a new ContentView instance
    /// - Parameter apikey: The API key used for Rijksmuseum service authentication
    init(apiKey: String) {
        let service = RijksmuseumService(apiKey: apiKey)
        _viewModel = StateObject(wrappedValue: ArtworkListViewModel(service: service))
    }
    // MARK: - Body
    var body: some View {
        NavigationSplitView {
            /// Main list view content
            ZStack {
                // Artwork list with pagniation
                List(viewModel.artworks, selection: $viewModel.selectedArtwork) { artwork in
                    NavigationLink(destination: ArtworkDetailView(favoritesManager: favoritesManager, artwork: artwork)) {
                        ArtworkRow(favoritesManager: favoritesManager, artwork: artwork)
                    }
                        .onAppear {
                            // Load more content when reaching the end
                            if artwork == viewModel.artworks.last && viewModel.hasMorePages && !viewModel.isLoading {
                                Task {
                                    await viewModel.loadMoreArtworks(searchQuery: searchText)
                                }
                            }
                        }
                        .tag(artwork)
                }
                .listStyle(.plain)
                .refreshable {
                    // Pull to refresh functionality
                    viewModel.resetPagination()
                    await viewModel.searchArtworks(searchQuery: searchText)
                }
                // Loading indicator
                if viewModel.isLoading && viewModel.artworks.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Rijksmuseum")
            .searchable(text: $searchText)
            .onChange(of: searchText) { oldValue, newValue in
                // Debounced search implementation
                searchTask?.cancel()
                
                searchTask = Task {
                    viewModel.resetPagination()
                    
                    try? await Task.sleep(for: .milliseconds(500))
                    
                    
                    if !Task.isCancelled {
                        await viewModel.searchArtworks(searchQuery: newValue)
                    }
                }
            }
            .task {
                // Initial data load
                await viewModel.searchArtworks(searchQuery: searchText)
            }
        } detail: {
            // Detail view selection handling
            if let selectedArtwork = viewModel.selectedArtwork {
                ArtworkDetailView(favoritesManager: favoritesManager, artwork: selectedArtwork)
            } else {
                Text("Select an artwork")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.artframe")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Select an artwork")
                .font(.title2)
                .foregroundColor(.secondary)
        }
    }
}
// MARK: - Preview Provider
#Preview {
    ContentView(apiKey: Config.apiKey)
}
