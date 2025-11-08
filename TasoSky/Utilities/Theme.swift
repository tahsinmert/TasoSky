//
//  Theme.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI

struct Theme {
    // NASA temalı renkler
    static let spaceBlack = Color(red: 0.05, green: 0.05, blue: 0.1)
    static let deepSpace = Color(red: 0.08, green: 0.08, blue: 0.15)
    static let nasaBlue = Color(red: 0.0, green: 0.4, blue: 0.8)
    static let nasaRed = Color(red: 0.85, green: 0.15, blue: 0.2)
    static let stellarWhite = Color(red: 0.95, green: 0.95, blue: 1.0)
    static let cosmicPurple = Color(red: 0.4, green: 0.2, blue: 0.6)
    static let nebulaPink = Color(red: 0.8, green: 0.3, blue: 0.5)
    
    // Gradient'ler
    static let spaceGradient = LinearGradient(
        colors: [deepSpace, spaceBlack],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cosmicGradient = LinearGradient(
        colors: [nasaBlue.opacity(0.3), cosmicPurple.opacity(0.2), spaceBlack],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Typography
    static func titleFont(size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func bodyFont(size: CGFloat = 16, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    
    static func captionFont(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
}

