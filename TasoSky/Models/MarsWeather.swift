//
//  MarsWeather.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import Foundation

struct MarsWeatherResponse: Codable {
    let solKeys: [Int]?
    let validityChecks: ValidityChecks?
    
    enum CodingKeys: String, CodingKey {
        case solKeys = "sol_keys"
        case validityChecks = "validity_checks"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // sol_keys'i hem Int hem String array olarak handle et
        if let intKeys = try? container.decode([Int].self, forKey: .solKeys) {
            self.solKeys = intKeys
        } else if let stringKeys = try? container.decode([String].self, forKey: .solKeys) {
            let intKeys = stringKeys.compactMap { Int($0) }
            self.solKeys = intKeys.isEmpty ? nil : intKeys
        } else {
            self.solKeys = nil
        }
        
        self.validityChecks = try? container.decode(ValidityChecks.self, forKey: .validityChecks)
    }
}

struct ValidityChecks: Codable {
    let solHoursWithData: [Int]?
    let solsChecked: [String]?
    
    enum CodingKeys: String, CodingKey {
        case solHoursWithData = "sol_hours_with_data"
        case solsChecked = "sols_checked"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.solHoursWithData = try? container.decode([Int].self, forKey: .solHoursWithData)
        self.solsChecked = try? container.decode([String].self, forKey: .solsChecked)
    }
}

struct SolData: Codable, Identifiable {
    let id: Int
    let firstUTC: String?
    let lastUTC: String?
    let season: String?
    let atmosphericPressure: AtmosphericPressure?
    let horizontalWindSpeed: WindSpeed?
    let mostCommonWindDirection: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstUTC = "First_UTC"
        case lastUTC = "Last_UTC"
        case season = "Season"
        case atmosphericPressure = "PRE"
        case horizontalWindSpeed = "HWS"
        case mostCommonWindDirection = "WD"
    }
    
    init(id: Int, firstUTC: String?, lastUTC: String?, season: String?, atmosphericPressure: AtmosphericPressure?, horizontalWindSpeed: WindSpeed?, mostCommonWindDirection: String?) {
        self.id = id
        self.firstUTC = firstUTC
        self.lastUTC = lastUTC
        self.season = season
        self.atmosphericPressure = atmosphericPressure
        self.horizontalWindSpeed = horizontalWindSpeed
        self.mostCommonWindDirection = mostCommonWindDirection
    }
}

struct AtmosphericPressure: Codable {
    let average: Double?
    let minimum: Double?
    let maximum: Double?
    
    enum CodingKeys: String, CodingKey {
        case average = "av"
        case minimum = "mn"
        case maximum = "mx"
    }
    
    init(average: Double?, minimum: Double?, maximum: Double?) {
        self.average = average
        self.minimum = minimum
        self.maximum = maximum
    }
}

struct WindSpeed: Codable {
    let average: Double?
    let minimum: Double?
    let maximum: Double?
    
    enum CodingKeys: String, CodingKey {
        case average = "av"
        case minimum = "mn"
        case maximum = "mx"
    }
    
    init(average: Double?, minimum: Double?, maximum: Double?) {
        self.average = average
        self.minimum = minimum
        self.maximum = maximum
    }
}

