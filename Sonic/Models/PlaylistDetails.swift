//
//  PlaylistDetails.swift
//  Sonic
//
//  Created by Tarek on 23/03/2021.
//

import Foundation
struct PlaylistDetail: Codable {
    let description: String?
    let externalUrls: ExternalUrls?
    let id: String?
    let images: [CustomImage]
    let name: String?
    let tracks: PlaylistTracksResponse?
    
    enum CodingKeys: String, CodingKey {
        case description = "description"
        case externalUrls = "external_urls"
        case id = "id"
        case images = "images"
        case name = "name"
        case tracks = "tracks"
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description    = try container.decodeIfPresent(String.self, forKey: .description)
        self.externalUrls   = try container.decodeIfPresent(ExternalUrls.self, forKey: .externalUrls)
        self.id             = try container.decodeIfPresent(String.self, forKey: .id)
        self.images         = try container.decodeIfPresent([CustomImage].self, forKey: .images) ?? []
        self.name           = try container.decodeIfPresent(String.self, forKey: .name)
        self.tracks         = try container.decodeIfPresent(PlaylistTracksResponse.self, forKey: .tracks)
    }
}

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decodeIfPresent([PlaylistItem].self, forKey: .items) ?? []
    }
}
struct PlaylistItem: Codable {
    let track: AudioTrack?
    
    enum CodingKeys: String, CodingKey {
        case track = "track"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.track = try container.decodeIfPresent(AudioTrack.self, forKey: .track)
    }
}
