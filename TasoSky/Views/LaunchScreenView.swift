//
//  LaunchScreenView.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Theme.spaceBlack
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo/İkon
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.nasaBlue)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Text("TasoSky")
                    .font(Theme.titleFont(size: 40))
                    .foregroundColor(Theme.stellarWhite)
                
                Text("Uzayın Derinliklerini Keşfet")
                    .font(Theme.bodyFont())
                    .foregroundColor(Theme.stellarWhite.opacity(0.7))
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LaunchScreenView()
}

