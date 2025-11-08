//
//  NEO.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import Foundation

struct NEOResponse: Codable {
    let nearEarthObjects: [String: [NearEarthObject]]
    
    enum CodingKeys: String, CodingKey {
        case nearEarthObjects = "near_earth_objects"
    }
}

struct NearEarthObject: Codable, Identifiable {
    let id: String
    let name: String
    let estimatedDiameter: EstimatedDiameter
    let closeApproachData: [CloseApproachData]
    let isPotentiallyHazardousAsteroid: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case estimatedDiameter = "estimated_diameter"
        case closeApproachData = "close_approach_data"
        case isPotentiallyHazardousAsteroid = "is_potentially_hazardous_asteroid"
    }
}

struct EstimatedDiameter: Codable {
    let kilometers: DiameterRange
    
    struct DiameterRange: Codable {
        let estimatedDiameterMin: Double
        let estimatedDiameterMax: Double
        
        enum CodingKeys: String, CodingKey {
            case estimatedDiameterMin = "estimated_diameter_min"
            case estimatedDiameterMax = "estimated_diameter_max"
        }
    }
}

struct CloseApproachData: Codable {
    let closeApproachDate: String
    let relativeVelocity: RelativeVelocity
    let missDistance: MissDistance
    
    enum CodingKeys: String, CodingKey {
        case closeApproachDate = "close_approach_date"
        case relativeVelocity = "relative_velocity"
        case missDistance = "miss_distance"
    }
}

struct RelativeVelocity: Codable {
    let kilometersPerSecond: String
    
    enum CodingKeys: String, CodingKey {
        case kilometersPerSecond = "kilometers_per_second"
    }
}

struct MissDistance: Codable {
    let kilometers: String
}

