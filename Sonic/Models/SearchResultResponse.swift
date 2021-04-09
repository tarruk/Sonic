//
//  SearchResultResponse.swift
//  Sonic
//
//  Created by Tarek on 28/03/2021.
//

import Foundation

struct SearchResultResponse: Codable {
    let albums: SearchAlbumsResponse?
    let artists: SearchArtistsResponse?
    let playlists: SearchPlaylistsResponse?
    let tracks: SearchTracksResponse?
}


struct SearchAlbumsResponse: Codable {
    let items: [Album]
}


struct SearchArtistsResponse: Codable {
    let items: [Artist]
}

struct SearchPlaylistsResponse: Codable {
    let items: [Playlist]
}

struct SearchTracksResponse: Codable {
    let items: [AudioTrack]
}
