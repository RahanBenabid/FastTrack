//
//  ContentView.swift
//  FastTrack
//
//  Created by Rahan Benabid on 1/7/2024.
//

import SwiftUI
import AVKit

struct ContentView: View {
    /// adaptive grid, useful for resizing
    let gridItems: [GridItem] = [
        GridItem(.adaptive(minimum: 150,maximum: 200)),
    ]
    @AppStorage("searchText") var searchText = "" /// to save what the user searched for
    
    ///  for the rest of our app to remember
    @State private var tracks = [Track]()
    
    /// for the audio preview
    @State private var audioPlayer: AVPlayer?
    /// create an SVPlayer
    func play(_ track: Track) {
        audioPlayer?.pause()
        audioPlayer = AVPlayer(url: track.previewUrl)
        audioPlayer?.play()
    }
    
    enum SearchState {
        case none, seaching, success, error
    }
    @State private var searchState = SearchState.none
    @State private var selectedSong = ""
    @State private var searches = [String]()
    
    
    /**
     he adsychronous keyword tells the function it can run at the same time as the other functions, so the function can pause itself kind of like "give the function the ability to sleep while other work is being done", used mainly when fetching data from the internet, so your computer can do a lot of things during that time and not just freeze completely
     */
    func performSearch() async throws {
        /// to remove characters that aren't allowed
        guard let searchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        /// create an API
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchText)&limit=100&entity=song") else { return }
        
        /// if the data isn't cached, the function will sleep, so `await` is being used, `try` will be used in case of failure, the functions sends data and metadata
        let (data, _ /**metadata that won't be used*/) = try await URLSession.shared.data(from: url)
        
        /// to make sure the URL was correct, that we fetched the content and convert it successfully
        let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
        tracks = searchResult.results
    }
    
    /// this function will brdge between SwiftUI and the `async` method since it cannot call it directly, it will call it and wait for it to finish
    func startSearch() {
        withAnimation {
            if !searches.contains(searchText) && searchText != "" {
                searches.insert(searchText, at: 0)
            }
        }
        searchState = .seaching
        Task {
            do {
                try await performSearch()
                searchState = .success
            } catch {
                searchState = .error
            }
        }
    }
    
    func delete(_ song: String) {
        guard let index = searches.firstIndex(of: song) else { return }
        searches.remove(at: index)
    }
    
    var body: some View {
        NavigationView {
            List(searches, id: \.self, selection: $selectedSong) { search in
                HStack {
                    Text(search)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                delete(search)
                            }
                        }
                    Spacer()
                }
                .onTapGesture {
                    searchText = selectedSong
                    startSearch()
                }
            }
            .frame(minWidth: 200)
            .searchable(text: $searchText, placement: .sidebar)
            .onSubmit(of: .search , startSearch)
            .onDeleteCommand {
                for search in searches {
                    delete(search)
                }
            }
            
            
            
            VStack {
                ScrollView {
                    switch searchState {
                    case .none:
                        Text("Search for a Song, Artist or Album!")
//                            .frame(maxHeight: .infinity)
                    case .seaching:
                        ProgressView()
                    case .success:
                        LazyVGrid(columns: gridItems) {
                            ForEach(tracks) { track in
                                TrackView(track: track, onSelected: play)
                            }
                        }
                        .padding()
                    case .error:
                        Text("Sorry, your search failed – please check your internet connection then try again.")
                            .frame(maxHeight: .infinity)
                    }
                }
                .ignoresSafeArea(.all)
                .padding(30)
            }
        }
//        .navigationTitle("Fast Track")
        
    }
}

#Preview {
    ContentView()
}


/**
 - by default macOS apps aren't allowed to make network requests, that's why we need to enable the option in the options checkbox
 */
