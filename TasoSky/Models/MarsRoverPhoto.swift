//
//  MarsRoverPhoto.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import Foundation

struct MarsRoverPhotosResponse: Codable {
    let photos: [MarsRoverPhoto]
}

struct MarsRoverPhoto: Codable, Identifiable {
    let id: Int
    let sol: Int
    let camera: RoverCamera
    let imgSrc: String
    let earthDate: String
    let rover: Rover
    
    enum CodingKeys: String, CodingKey {
        case id, sol, camera, rover
        case imgSrc = "img_src"
        case earthDate = "earth_date"
    }
}

struct RoverCamera: Codable {
    let id: Int
    let name: String
    let roverId: Int
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case roverId = "rover_id"
        case fullName = "full_name"
    }
}

struct Rover: Codable {
    let id: Int
    let name: String
    let landingDate: String
    let launchDate: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, status
        case landingDate = "landing_date"
        case launchDate = "launch_date"
    }
}

