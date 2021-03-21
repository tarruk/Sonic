//
//  RecommendedGenres.swift
//  Sonic
//
//  Created by Tarek on 20/03/2021.
//

import Foundation

struct RecommendedGenres: Codable {
    let genres: [String]
    
    enum CodingKeys: String, CodingKey {
        case genres = "genres"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.genres = try container.decodeIfPresent([String].self, forKey: .genres) ?? []
    }
}
