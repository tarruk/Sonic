//
//  MusicCategory.swift
//  Sonic
//
//  Created by Tarek on 27/03/2021.
//

import Foundation

struct MusicCategory: Codable {
    let id: String?
    let name: String?
    let icons: [CustomImage]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case icons = "icons"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id     = try container.decodeIfPresent(String.self, forKey: .id)
        self.name   = try container.decodeIfPresent(String.self, forKey: .name)
        self.icons  = try container.decodeIfPresent([CustomImage].self, forKey: .icons) ?? []
        
    }
}
