//
//  NewReleases.swift
//  Sonic
//
//  Created by Tarek on 20/03/2021.
//

import Foundation

struct NewReleasesResponse: Codable {
    let albums: AlbumResponse?
    let limit: Int?
    let next: String?
    let offSet: Int?
    let previous: String?
    let total: Int?
    
    enum CodingKeys: String, CodingKey {
        case albums = "albums"
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
    let images: [CustomImage]
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
    
}

struct Artist: Codable {
    let externalUrls: ExternalUrls?
    let href: String?
    let id: String?
    let name: String?
    let type: String?
    let uri: String?
    
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href = "href"
        case id = "id"
        case name = "name"
        case type = "type"
        case uri = "uri"
    }
}
