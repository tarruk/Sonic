//
//  NewReleases.swift
//  Sonic
//
//  Created by Tarek on 20/03/2021.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albumResponse: AlbumResponse?
    let limit: Int?
    let next: String?
    let offSet: Int?
    let previous: String?
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case albumResponse = "albums"
        case limit = "limit"
        case next = "next"
        case offSet = "offset"
        case previous = "previous"
        case total = "total"
    }
}


struct AlbumResponse: Codable {
    let albums: [Album]
    let href: String?
    
    enum CodingKeys: String, CodingKey {
        case albums = "items"
        case href = "href"
    }
    
}

struct Album: Codable {
    let albumType: String?
    let artists: [Artist]
    let avaiableMarkets: [String]
    let externalsUrls: ExternalUrls?
    let href: String?
    let id: String?
    var images: [CustomImage]
    let name: String?
    let releaseDate: String?
    let releaseDatePrecision: String?
    let totalTracks: Int?
    let type: String?
    let uri: String?
    
    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists = "artists"
        case avaiableMarkets = "available_markets"
        case externalsUrls = "external_urls"
        case href = "href"
        case id = "id"
        case images = "images"
        case name = "name"
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case totalTracks = "total_tracks"
        case type = "type"
        case uri = "uri"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.albumType = try container.decodeIfPresent(String.self, forKey: .albumType)
        self.artists = try container.decodeIfPresent([Artist].self, forKey: .artists) ?? []
        self.avaiableMarkets = try container.decodeIfPresent([String].self, forKey: .avaiableMarkets) ?? []
        self.externalsUrls = try container.decodeIfPresent(ExternalUrls.self, forKey: .externalsUrls)
        self.href = try container.decodeIfPresent(String.self, forKey: .href)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.images = try container.decodeIfPresent([CustomImage].self, forKey: .images) ?? []
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        self.releaseDatePrecision = try container.decodeIfPresent(String.self, forKey: .releaseDatePrecision)
        self.totalTracks = try container.decodeIfPresent(Int.self, forKey: .totalTracks)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.uri = try container.decodeIfPresent(String.self, forKey: .uri)
    }
    
    
}

struct Artist: Codable {
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let name: String?
    let type: String?
    let uri: String?
    let images: [CustomImage]?
    
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href = "href"
        case id = "id"
        case name = "name"
        case type = "type"
        case uri = "uri"
        case images = "images"
    }
}
