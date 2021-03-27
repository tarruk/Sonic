//
//  CategoryPlaylistsResponse.swift
//  Sonic
//
//  Created by Tarek on 27/03/2021.
//

import Foundation
struct CategoryPlaylistsResponse: Codable {
    let message: String?
    let playlistsResponse: PlaylistsResponse?
    
    enum CodingKeys: String, CodingKey {
        case playlistsResponse = "playlists"
        case message = "message"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message            = try container.decodeIfPresent(String.self, forKey: .message)
        self.playlistsResponse  = try container.decodeIfPresent(PlaylistsResponse.self, forKey: .playlistsResponse)

    }
}
