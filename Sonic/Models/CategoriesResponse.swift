//
//  CategoriesResponse.swift
//  Sonic
//
//  Created by Tarek on 27/03/2021.
//

import Foundation

struct CategoriesResponse: Codable {
    let categories: Categories?
    
    enum CodingKeys: String, CodingKey {
        case categories = "categories"
    }
    
}

struct Categories: Codable {
    let items: [MusicCategory]
    
    enum CodingKeys: String, CodingKey {
        case items = "items"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decodeIfPresent([MusicCategory].self, forKey: .items) ?? []
    }
}
