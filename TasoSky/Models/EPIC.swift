//
//  EPIC.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import Foundation

struct EPICImage: Codable, Identifiable {
    let id: String
    let caption: String
    let image: String
    let version: String
    let date: String
    let centroid: Centroid?
    let dscovrJ2000Position: Position?
    let lunarJ2000Position: Position?
    let sunJ2000Position: Position?
    let attitudeQuaternions: AttitudeQuaternions?
    
    enum CodingKeys: String, CodingKey {
        case id = "identifier"
        case caption
        case image
        case version
        case date
        case centroid
        case dscovrJ2000Position = "dscovr_j2000_position"
        case lunarJ2000Position = "lunar_j2000_position"
        case sunJ2000Position = "sun_j2000_position"
        case attitudeQuaternions = "attitude_quaternions"
    }
    
    // EPIC görsel URL'si oluştur
    var imageURL: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let imageDate = dateFormatter.date(from: date) else {
            return ""
        }
        
        let year = Calendar.current.component(.year, from: imageDate)
        let month = String(format: "%02d", Calendar.current.component(.month, from: imageDate))
        let day = String(format: "%02d", Calendar.current.component(.day, from: imageDate))
        
        return "https://epic.gsfc.nasa.gov/archive/natural/\(year)/\(month)/\(day)/png/\(image).png"
    }
}

struct Centroid: Codable {
    let lat: Double
    let lon: Double
}

struct Position: Codable {
    let x: Double
    let y: Double
    let z: Double
}

struct AttitudeQuaternions: Codable {
    let q0: Double
    let q1: Double
    let q2: Double
    let q3: Double
}

