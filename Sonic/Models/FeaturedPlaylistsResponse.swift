//
//  FeaturedPlaylistsResponse.swift
//  Sonic
//
//  Created by Tarek on 20/03/2021.
//

import Foundation
struct FeaturedPlaylistsResponse: Codable {
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

struct PlaylistsResponse: Codable {
    let href: String?
    let playlists: [Playlist]
    
    enum CodingKeys: String, CodingKey {
        case playlists = "items"
        case href = "href"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.href           = try container.decodeIfPresent(String.self, forKey: .href)
        self.playlists      = try container.decodeIfPresent([Playlist].self, forKey: .playlists) ?? []
    }
}

struct Playlist: Codable {
    let description: String?
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let images: [CustomImage]?
    let name: String?
    let owner: User?
    let primaryColor: String?
 
    
    enum CodingKeys: String, CodingKey {
        case description = "description"
        case externalUrls = "external_urls"
        case href = "href"
        case id = "id"
        case images = "images"
        case name = "name"
        case owner = "owner"
        case primaryColor = "primary_color"
   
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description    = try container.decodeIfPresent(String.self, forKey: .description)
        self.externalUrls   = try container.decodeIfPresent(ExternalUrls.self, forKey: .externalUrls)
        self.href           = try container.decodeIfPresent(String.self, forKey: .href)
        self.id             = try container.decodeIfPresent(String.self, forKey: .id)
        self.images         = try container.decodeIfPresent([CustomImage].self, forKey: .images)
        self.name           = try container.decodeIfPresent(String.self, forKey: .name)
        self.owner          = try container.decodeIfPresent(User.self, forKey: .owner)
        self.primaryColor   = try container.decodeIfPresent(String.self, forKey: .primaryColor)
    }
}
