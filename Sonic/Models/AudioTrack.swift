//
//  AudioTrack.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import Foundation

struct AudioTrack: Codable {
    let album: Album?
    let artists: [Artist]
    let availableMarkets: [String]
    let discNumber: Int?
    let durationMiliSeconds: Int?
    let explicit: Bool?
    let externalIds: ExternalUrls?
    let id: String?
    let name: String?
    let popularity: Int?
    let uri: String?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case album = "album"
        case artists = "artists"
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMiliSeconds = "duration_ms"
        case explicit = "explicit"
        case externalIds = "external_ids"
        case id = "id"
        case name = "name"
        case popularity = "popularity"
        case uri = "uri"
        case type = "type"
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.album  = try container.decodeIfPresent(Album.self, forKey: .album)
        self.artists    = try container.decodeIfPresent([Artist].self, forKey: .artists) ?? []
        self.availableMarkets   = try container.decodeIfPresent([String].self, forKey: .availableMarkets) ?? []
        self.discNumber     = try container.decodeIfPresent(Int.self, forKey: .discNumber)
        self.durationMiliSeconds    = try container.decodeIfPresent(Int.self, forKey: .durationMiliSeconds)
        self.explicit   = try container.decodeIfPresent(Bool.self, forKey: .explicit)
        self.externalIds    = try container.decodeIfPresent(ExternalUrls.self, forKey: .externalIds)
        self.id     = try container.decodeIfPresent(String.self, forKey: .id)
        self.name   = try container.decodeIfPresent(String.self, forKey: .name)
        self.popularity     = try container.decodeIfPresent(Int.self, forKey: .popularity)
        self.uri    = try container.decodeIfPresent(String.self, forKey: .uri)
        self.type   = try container.decodeIfPresent(String.self, forKey: .type)
    }
}
