//
//  AlbumDetails.swift
//  Sonic
//
//  Created by Tarek on 23/03/2021.
//

import Foundation
struct AlbumDetails: Codable {
    let albumType: String?
    let artists: [Artist]
    let availableMarkets: [String]
    let externalUrls: ExternalUrls?
    let id: String?
    let images: [CustomImage]
    let label: String?
    let name: String?
    let tracks: TracksResponse?
    
    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists = "artists"
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case id = "id"
        case images = "images"
        case label = "label"
        case name = "name"
        case tracks = "tracks"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.albumType          = try container.decodeIfPresent(String.self, forKey: .albumType)
        self.artists            = try container.decodeIfPresent([Artist].self, forKey: .artists) ?? []
        self.availableMarkets   = try container.decodeIfPresent([String].self, forKey: .availableMarkets) ?? []
        self.externalUrls       = try container.decodeIfPresent(ExternalUrls.self, forKey: .externalUrls)
        self.id                 = try container.decodeIfPresent(String.self, forKey: .id)
        self.images             = try container.decodeIfPresent([CustomImage].self, forKey: .images) ?? []
        self.label              = try container.decodeIfPresent(String.self, forKey: .label)
        self.name               = try container.decodeIfPresent(String.self, forKey: .name)
        self.tracks             = try container.decodeIfPresent(TracksResponse.self, forKey: .tracks)
    }
}
