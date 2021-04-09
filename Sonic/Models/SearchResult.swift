//
//  SearchResult.swift
//  Sonic
//
//  Created by Tarek on 28/03/2021.
//

import Foundation

enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
