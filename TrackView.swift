//
//  TrackView.swift
//  FastTrack
//
//  Created by Rahan Benabid on 3/7/2024.
//

import SwiftUI

struct TrackView: View {
    let track: Track
    @State private var isHovering = false
    
    let onSelected: (Track) -> Void
    
    
    var body: some View {
        Button {
            onSelected(track)
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: track.artworkURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    case .failure(_):
                        Image(systemName: "questionmark")
                            .symbolVariant(.circle)
                            .font(.largeTitle)
                    default:
                        ProgressView() /// funny little spinner when loading
                    }
                }
                .frame(width: 150, height: 150)
                
                
                VStack {
                    Text(track.trackName)
                        .lineLimit(1)
                        .font(.headline)
                    
                    Text(track.artistName)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
                .padding(5)
                .frame(width: 150)
                .background(.regularMaterial)
            }
        }
        .buttonStyle(.borderless)
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
        .border(.primary, width: isHovering ? 3 : 0)
        .scaleEffect(isHovering ? 1.1 : 1.0)
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        TrackView(track: Track(trackId: 1, artistName: "Nirvana", trackName: "Smells Like Teen Spirit", previewUrl: URL(string: "abc")!, artworkUrl100: "https://bit.ly/teen-spirit")) { track in }
    }
}
