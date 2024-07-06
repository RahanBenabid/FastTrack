//
//  Track.swift
//  FastTrack
//
//  Created by Rahan Benabid on 3/7/2024.
//

import Foundation

/// they MUST match the JSON structure, and the `Decodable` protocol is for turning JSON into Swift Data, possible because all our datatype conform to it  like `Int, String`
struct Track: Identifiable, Decodable, Hashable {
    let trackId: Int
    var id: Int { trackId }
    let artistName: String
    let trackName: String
    let previewUrl: URL
    let artworkUrl100: String
    var artworkURL: URL? {
        let replacedString = artworkUrl100.replacingOccurrences(of: "100x100", with: "300x300")
        return URL(string: replacedString)
    }
}

/// since its property also conforms to `Decodable` we don't need to add anything
struct SearchResult: Decodable {
    let results: [Track]
}
