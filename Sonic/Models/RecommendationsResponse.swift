//
//  RecommendationsResponse.swift
//  Sonic
//
//  Created by Tarek on 21/03/2021.
//

import Foundation

struct GenreSeed: Codable {
    let id: String?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id     = try container.decodeIfPresent(String.self, forKey: .id)
        self.type   = try container.decodeIfPresent(String.self, forKey: .type)
    }
}

struct Recommendation: Codable {
    let seeds: [GenreSeed]
    let tracks: [AudioTrack]
    
    enum CodingKeys: String, CodingKey {
        case seeds = "seeds"
        case tracks = "tracks"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.seeds  = try container.decodeIfPresent([GenreSeed].self, forKey: .seeds) ?? []
        self.tracks = try container.decodeIfPresent([AudioTrack].self, forKey: .tracks) ?? []
    }
}


