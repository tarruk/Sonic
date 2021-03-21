//
//  User.swift
//  Sonic
//
//  Created by Tarek on 19/03/2021.
//

import Foundation

struct User: Codable {
    let country: String?
    let displayName: String?
    let email: String?
    let explicitContent: ExplicitContent?
    let externalUrls: ExternalUrls?
    let followers: Followers?
    let id: String?
    let product: String?
    let images: [CustomImage]
    let type: String?

    enum CodingKeys: String, CodingKey {
        case country = "country"
        case displayName = "display_name"
        case email = "email"
        case explicitContent = "explicit_content"
        case externalUrls = "external_urls"
        case followers = "followers"
        case id = "id"
        case product = "product"
        case images = "images"
        case type = "type"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.country            = try container.decodeIfPresent(String.self, forKey: .country)
        self.displayName        = try container.decodeIfPresent(String.self, forKey: .displayName)
        self.email              = try container.decodeIfPresent(String.self, forKey: .email)
        self.explicitContent    = try container.decodeIfPresent(ExplicitContent.self, forKey: .explicitContent)
        self.externalUrls       = try container.decodeIfPresent(ExternalUrls.self, forKey: .externalUrls)
        self.followers          = try container.decodeIfPresent(Followers.self, forKey: .followers)
        self.id                 = try container.decodeIfPresent(String.self, forKey: .id)
        self.product            = try container.decodeIfPresent(String.self, forKey: .product)
        self.images             = try container.decodeIfPresent([CustomImage].self, forKey: .images) ?? []
        self.type               = try container.decodeIfPresent(String.self, forKey: .type)
    }
}

struct CustomImage: Codable {
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case url = "url"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}

struct ExplicitContent: Codable {
    let filterEnabled: Bool?
    let filterLocked: Bool?
    enum CodingKeys: String, CodingKey {
        case filterEnabled = "filter_enabled"
        case filterLocked = "filter_locked"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filterEnabled  = try container.decodeIfPresent(Bool.self, forKey: .filterEnabled)
        self.filterLocked   = try container.decodeIfPresent(Bool.self, forKey: .filterLocked)
    }
}

struct ExternalUrls: Codable {
    let spotify: String?
    enum CodingKeys: String, CodingKey {
        case spotify = "spotify"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.spotify  = try container.decodeIfPresent(String.self, forKey: .spotify)
    
    }
}

struct Followers: Codable {
    let href: String?
    let total: Int?
    enum CodingKeys: String, CodingKey {
        case href = "href"
        case total = "total"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.href   = try container.decodeIfPresent(String.self, forKey: .href)
        self.total  = try container.decodeIfPresent(Int.self, forKey: .total)
    }
}
