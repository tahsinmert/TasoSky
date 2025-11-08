//
//  NASAAPIService.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import Foundation

class NASAAPIService {
    static let shared = NASAAPIService()
    
    private let baseURL = "https://api.nasa.gov"
    private let apiKey = "904kMmiVhUeNiLaBKREfc2Hzlmc6gNBvnuWDLMoD"
    
    private init() {}
    
    // Astronomy Picture of the Day
    func fetchAPOD(date: Date? = nil) async throws -> APOD {
        var urlString = "\(baseURL)/planetary/apod?api_key=\(apiKey)"
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            urlString += "&date=\(formatter.string(from: date))"
        }
        
        print("🌐 API URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // HTTP response kontrolü
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ HTTP Error: \(errorMessage)")
                throw NSError(domain: "NASAAPIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage)"])
            }
        }
        
        // Response'u logla
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 API Response (first 500 chars): \(String(jsonString.prefix(500)))")
        }
        
        // JSON decode
        do {
            let decoder = JSONDecoder()
            let apod = try decoder.decode(APOD.self, from: data)
            print("✅ APOD decoded successfully")
            return apod
        } catch {
            // Eğer decode başarısız olursa, response'u logla
            print("❌ Decode error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📋 Full API Response: \(jsonString)")
            }
            throw error
        }
    }
    
    // Near Earth Objects
    func fetchNEO(startDate: Date, endDate: Date) async throws -> NEOResponse {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let startDateString = formatter.string(from: startDate)
        let endDateString = formatter.string(from: endDate)
        
        let urlString = "\(baseURL)/neo/rest/v1/feed?start_date=\(startDateString)&end_date=\(endDateString)&api_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(NEOResponse.self, from: data)
    }
    
    // Mars Weather (InSight)
    func fetchMarsWeather() async throws -> [SolData] {
        let urlString = "\(baseURL)/insight_weather/?api_key=\(apiKey)&feedtype=json&ver=1.0"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // JSON'ı dictionary olarak parse et
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "MarsWeatherError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])
        }
        
        // sol_keys'i bul
        var solKeys: [Int] = []
        if let solKeysArray = jsonObject["sol_keys"] as? [Any] {
            for key in solKeysArray {
                if let intKey = key as? Int {
                    solKeys.append(intKey)
                } else if let stringKey = key as? String, let intKey = Int(stringKey) {
                    solKeys.append(intKey)
                }
            }
        }
        
        // Eğer sol_keys yoksa, tüm numeric key'leri dene
        if solKeys.isEmpty {
            for key in jsonObject.keys {
                if let intKey = Int(key), key != "validity_checks" {
                    solKeys.append(intKey)
                }
            }
        }
        
        var sols: [SolData] = []
        
        // Her sol için veriyi çıkar
        for solKey in solKeys {
            if let solDict = jsonObject[String(solKey)] as? [String: Any] {
                // Sol verisini manuel olarak oluştur
                var firstUTC: String? = nil
                var lastUTC: String? = nil
                var season: String? = nil
                var atmosphericPressure: AtmosphericPressure? = nil
                var horizontalWindSpeed: WindSpeed? = nil
                var mostCommonWindDirection: String? = nil
                
                if let firstUTCString = solDict["First_UTC"] as? String {
                    firstUTC = firstUTCString
                }
                if let lastUTCString = solDict["Last_UTC"] as? String {
                    lastUTC = lastUTCString
                }
                if let seasonString = solDict["Season"] as? String {
                    season = seasonString
                }
                
                // Atmospheric Pressure
                if let preDict = solDict["PRE"] as? [String: Any] {
                    if let av = preDict["av"] as? Double,
                       let mn = preDict["mn"] as? Double,
                       let mx = preDict["mx"] as? Double {
                        atmosphericPressure = AtmosphericPressure(average: av, minimum: mn, maximum: mx)
                    }
                }
                
                // Horizontal Wind Speed
                if let hwsDict = solDict["HWS"] as? [String: Any] {
                    if let av = hwsDict["av"] as? Double,
                       let mn = hwsDict["mn"] as? Double,
                       let mx = hwsDict["mx"] as? Double {
                        horizontalWindSpeed = WindSpeed(average: av, minimum: mn, maximum: mx)
                    }
                }
                
                // Wind Direction
                if let wdDict = solDict["WD"] as? [String: Any] {
                    if let mostCommon = wdDict["most_common"] as? [String: Any] {
                        if let compassDegrees = mostCommon["compass_degrees"] as? Double {
                            mostCommonWindDirection = String(format: "%.0f°", compassDegrees)
                        } else if let compassPoint = mostCommon["compass_point"] as? String {
                            mostCommonWindDirection = compassPoint
                        }
                    }
                }
                
                sols.append(SolData(
                    id: solKey,
                    firstUTC: firstUTC,
                    lastUTC: lastUTC,
                    season: season,
                    atmosphericPressure: atmosphericPressure,
                    horizontalWindSpeed: horizontalWindSpeed,
                    mostCommonWindDirection: mostCommonWindDirection
                ))
            }
        }
        
        return sols.sorted { $0.id > $1.id } // En yeni sol'lar önce
    }
    
    // Mars Rover Photos
    func fetchMarsRoverPhotos(rover: String = "curiosity", sol: Int? = nil, earthDate: String? = nil, camera: String? = nil, page: Int = 1) async throws -> MarsRoverPhotosResponse {
        // Rover ve sol parametrelerini kontrol et
        let validRovers = ["curiosity", "perseverance", "opportunity", "spirit"]
        guard validRovers.contains(rover.lowercased()) else {
            throw NSError(domain: "NASAAPIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Geçersiz rover adı: \(rover)"])
        }
        
        var urlString = "\(baseURL)/mars-photos/api/v1/rovers/\(rover.lowercased())/photos?api_key=\(apiKey)&page=\(page)"
        
        if let sol = sol {
            urlString += "&sol=\(sol)"
        } else if let earthDate = earthDate {
            urlString += "&earth_date=\(earthDate)"
        } else {
            // Varsayılan olarak sol 1000 kullan (çoğu rover için veri var)
            urlString += "&sol=1000"
        }
        
        if let camera = camera, !camera.isEmpty {
            urlString += "&camera=\(camera.lowercased())"
        }
        
        print("🌐 Mars Rover API URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Mars Rover HTTP Status: \(httpResponse.statusCode)")
            
            // 404 hatası için özel mesaj
            if httpResponse.statusCode == 404 {
                throw NSError(domain: "NASAAPIService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Bu sol (\(sol ?? 0)) için fotoğraf bulunamadı. Lütfen farklı bir sol numarası deneyin."])
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                // HTML yanıtını parse etmeye çalışma, sadece hata kodu göster
                if let responseString = String(data: data, encoding: .utf8), responseString.contains("html") || responseString.contains("<!DOCTYPE") {
                    throw NSError(domain: "NASAAPIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Sunucu hatası (HTTP \(httpResponse.statusCode)). Lütfen daha sonra tekrar deneyin."])
                } else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
                    throw NSError(domain: "NASAAPIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage.prefix(100))"])
                }
            }
        }
        
        // JSON kontrolü
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "NASAAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Geçersiz yanıt formatı"])
        }
        
        // HTML yanıtı kontrolü
        if jsonString.trimmingCharacters(in: .whitespaces).hasPrefix("<!DOCTYPE") || jsonString.trimmingCharacters(in: .whitespaces).hasPrefix("<html") {
            throw NSError(domain: "NASAAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Sunucu hatası. Lütfen daha sonra tekrar deneyin."])
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(MarsRoverPhotosResponse.self, from: data)
            print("✅ Mars Rover Photos decoded: \(response.photos.count) photos")
            
            // Eğer fotoğraf yoksa boş liste döndür (hata değil)
            if response.photos.isEmpty {
                print("⚠️ Bu sol için fotoğraf bulunamadı")
            }
            
            return response
        } catch {
            print("❌ Mars Rover decode error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📋 Response: \(jsonString.prefix(500))")
            }
            throw NSError(domain: "NASAAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Veri parse hatası. Lütfen tekrar deneyin."])
        }
    }
    
    // EPIC (Earth Polychromatic Imaging Camera)
    func fetchEPICImages(date: String? = nil) async throws -> [EPICImage] {
        var urlString = "\(baseURL)/EPIC/api/natural"
        
        if let date = date {
            urlString += "/date/\(date)"
        }
        
        urlString += "?api_key=\(apiKey)"
        
        print("🌐 EPIC API URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 EPIC HTTP Status: \(httpResponse.statusCode)")
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Bilinmeyen hata"
                throw NSError(domain: "NASAAPIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errorMessage.prefix(100))"])
            }
        }
        
        do {
            let decoder = JSONDecoder()
            let images = try decoder.decode([EPICImage].self, from: data)
            print("✅ EPIC Images decoded: \(images.count) images")
            return images.sorted { $0.date > $1.date } // En yeni önce
        } catch {
            print("❌ EPIC decode error: \(error)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📋 Response: \(jsonString.prefix(500))")
            }
            throw NSError(domain: "NASAAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Veri parse hatası. Lütfen tekrar deneyin."])
        }
    }
    
    // EPIC için mevcut tarihleri al
    func fetchEPICAvailableDates() async throws -> [String] {
        let urlString = "\(baseURL)/EPIC/api/natural/available?api_key=\(apiKey)"
        
        print("🌐 EPIC Available Dates URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "NASAAPIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
            }
        }
        
        do {
            let dates = try JSONDecoder().decode([String].self, from: data)
            return dates.sorted { $0 > $1 } // En yeni önce
        } catch {
            throw NSError(domain: "NASAAPIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Tarih listesi alınamadı."])
        }
    }
}

