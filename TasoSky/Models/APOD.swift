//
//  APOD.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import Foundation

struct APOD: Codable, Identifiable {
    let id = UUID()
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: String
    let serviceVersion: String?
    let title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case date, explanation, hdurl, title, url
        case mediaType = "media_type"
        case serviceVersion = "service_version"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(String.self, forKey: .date)
        explanation = try container.decode(String.self, forKey: .explanation)
        hdurl = try container.decodeIfPresent(String.self, forKey: .hdurl)
        mediaType = try container.decode(String.self, forKey: .mediaType)
        serviceVersion = try container.decodeIfPresent(String.self, forKey: .serviceVersion)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)
    }
}

