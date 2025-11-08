//
//  Planet.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import Foundation
import SwiftUI

struct Planet: Identifiable, Codable {
    let id: UUID
    let name: String
    let turkishName: String
    let distanceFromSun: Double // milyon km
    let diameter: Double // km
    let mass: Double // Dünya kütlesi cinsinden
    let orbitalPeriod: Double // Dünya günü cinsinden
    let dayLength: Double // Dünya saat cinsinden
    let temperature: Temperature
    let color: PlanetColor
    let description: String
    let facts: [String]
    let moons: Int
    let hasRings: Bool
    
    struct Temperature: Codable {
        let min: Double
        let average: Double
        let max: Double
    }
    
    struct PlanetColor: Codable {
        let primary: String
        let secondary: String
        let accent: String
    }
    
    static let planets: [Planet] = [
        Planet(
            id: UUID(),
            name: "Mercury",
            turkishName: "Merkür",
            distanceFromSun: 57.9,
            diameter: 4879,
            mass: 0.055,
            orbitalPeriod: 88,
            dayLength: 4222.6,
            temperature: Temperature(min: -173, average: 167, max: 427),
            color: PlanetColor(primary: "#8C7853", secondary: "#B8B08D", accent: "#FFD700"),
            description: "Güneş sisteminin en küçük gezegeni ve Güneş'e en yakın olanı. Yüzeyi kraterlerle kaplı ve aşırı sıcaklık farkları yaşar.",
            facts: [
                "Güneş sistemindeki en küçük gezegen",
                "1 günü, 1 yılından daha uzun sürer",
                "Atmosferi neredeyse yoktur",
                "Güneş'e en yakın gezegen"
            ],
            moons: 0,
            hasRings: false
        ),
        Planet(
            id: UUID(),
            name: "Venus",
            turkishName: "Venüs",
            distanceFromSun: 108.2,
            diameter: 12104,
            mass: 0.815,
            orbitalPeriod: 225,
            dayLength: 2802,
            temperature: Temperature(min: 437, average: 464, max: 497),
            color: PlanetColor(primary: "#FFC649", secondary: "#FFB347", accent: "#FF8C00"),
            description: "Güneş sisteminin en sıcak gezegeni. Kalın bir karbondioksit atmosferi ile kaplı ve yüzeyi volkanik aktiviteyle şekillenmiş.",
            facts: [
                "En sıcak gezegen (462°C)",
                "Geriye doğru döner",
                "Kalın bulut örtüsü",
                "Akşam yıldızı olarak bilinir"
            ],
            moons: 0,
            hasRings: false
        ),
        Planet(
            id: UUID(),
            name: "Earth",
            turkishName: "Dünya",
            distanceFromSun: 149.6,
            diameter: 12756,
            mass: 1.0,
            orbitalPeriod: 365.25,
            dayLength: 24,
            temperature: Temperature(min: -88, average: 15, max: 58),
            color: PlanetColor(primary: "#4A90E2", secondary: "#7ED321", accent: "#50E3C2"),
            description: "Bildiğimiz tek yaşam barındıran gezegen. Okyanuslar, kıtalar ve çeşitli ekosistemlerle dolu harika bir dünya.",
            facts: [
                "Tek yaşam barındıran gezegen",
                "Su ile kaplı tek gezegen",
                "Dinamik manyetik alan",
                "4.5 milyar yıl yaşında"
            ],
            moons: 1,
            hasRings: false
        ),
        Planet(
            id: UUID(),
            name: "Mars",
            turkishName: "Mars",
            distanceFromSun: 227.9,
            diameter: 6792,
            mass: 0.107,
            orbitalPeriod: 687,
            dayLength: 24.6,
            temperature: Temperature(min: -153, average: -65, max: 20),
            color: PlanetColor(primary: "#CD5C5C", secondary: "#E9967A", accent: "#FF6347"),
            description: "Kırmızı gezegen. Eski nehir yatakları ve kutup buzulları ile geçmişte sıvı su barındırmış olabilir.",
            facts: [
                "Kırmızı rengi demir oksitten gelir",
                "Güneş sistemindeki en büyük volkan",
                "2 uydusu var (Phobos, Deimos)",
                "Gelecekte kolonileştirilebilir"
            ],
            moons: 2,
            hasRings: false
        ),
        Planet(
            id: UUID(),
            name: "Jupiter",
            turkishName: "Jüpiter",
            distanceFromSun: 778.5,
            diameter: 142984,
            mass: 317.8,
            orbitalPeriod: 4331,
            dayLength: 9.9,
            temperature: Temperature(min: -163, average: -110, max: -88),
            color: PlanetColor(primary: "#D2691E", secondary: "#F4A460", accent: "#FFD700"),
            description: "Güneş sisteminin devi. Büyük Kırmızı Leke fırtınası ve 79 uydusu ile muhteşem bir gezegen.",
            facts: [
                "En büyük gezegen",
                "79 uydusu var",
                "Büyük Kırmızı Leke fırtınası",
                "Gaz devi (katı yüzey yok)"
            ],
            moons: 79,
            hasRings: true
        ),
        Planet(
            id: UUID(),
            name: "Saturn",
            turkishName: "Satürn",
            distanceFromSun: 1432.0,
            diameter: 120536,
            mass: 95.2,
            orbitalPeriod: 10747,
            dayLength: 10.7,
            temperature: Temperature(min: -191, average: -140, max: -130),
            color: PlanetColor(primary: "#FAD5A5", secondary: "#FFE4B5", accent: "#FFD700"),
            description: "Muhteşem halkaları ile ünlü gezegen. Halkaları buz ve kaya parçacıklarından oluşur.",
            facts: [
                "Güzel halkaları var",
                "82 uydusu var",
                "En az yoğun gezegen",
                "Titan adında büyük uydusu var"
            ],
            moons: 82,
            hasRings: true
        ),
        Planet(
            id: UUID(),
            name: "Uranus",
            turkishName: "Uranüs",
            distanceFromSun: 2867.0,
            diameter: 51118,
            mass: 14.5,
            orbitalPeriod: 30589,
            dayLength: 17.2,
            temperature: Temperature(min: -224, average: -195, max: -197),
            color: PlanetColor(primary: "#4FD0E7", secondary: "#87CEEB", accent: "#B0E0E6"),
            description: "Yan yatmış dev. Eksen eğikliği 98 derece olan bu gezegen yan yatık bir şekilde döner.",
            facts: [
                "Yan yatık döner (98° eğik)",
                "27 uydusu var",
                "Buz devi",
                "Soluk halkaları var"
            ],
            moons: 27,
            hasRings: true
        ),
        Planet(
            id: UUID(),
            name: "Neptune",
            turkishName: "Neptün",
            distanceFromSun: 4515.0,
            diameter: 49528,
            mass: 17.1,
            orbitalPeriod: 59800,
            dayLength: 16.1,
            temperature: Temperature(min: -218, average: -200, max: -201),
            color: PlanetColor(primary: "#4166F5", secondary: "#6495ED", accent: "#87CEEB"),
            description: "Güneş sisteminin en uzak gezegeni. Güçlü rüzgarları ve derin mavi rengi ile dikkat çeker.",
            facts: [
                "En uzak gezegen",
                "En güçlü rüzgarlar (2100 km/saat)",
                "14 uydusu var",
                "Derin mavi rengi"
            ],
            moons: 14,
            hasRings: true
        )
    ]
}

