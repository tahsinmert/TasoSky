//
//  InfoRow.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.nasaBlue)
                .frame(width: 24)
            Text(label)
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(Theme.stellarWhite.opacity(0.7))
            Spacer()
            Text(value)
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(Theme.stellarWhite)
        }
    }
}

// NEOView için özel versiyon (dikey layout)
struct NEOInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.nasaBlue)
                Text(label)
                    .font(Theme.captionFont(size: 10))
                    .foregroundColor(Theme.stellarWhite.opacity(0.6))
            }
            Text(value)
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(Theme.stellarWhite)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// NEOView için basit stat kartı
struct NEOStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            Text(value)
                .font(Theme.titleFont(size: 32))
                .foregroundColor(Theme.stellarWhite)
            Text(title)
                .font(Theme.captionFont())
                .foregroundColor(Theme.stellarWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// PlanetsView için detaylı stat kartı
struct PlanetStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(Theme.captionFont(size: 11))
                .foregroundColor(Theme.stellarWhite.opacity(0.6))
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(Theme.bodyFont(size: 14))
                .foregroundColor(Theme.stellarWhite)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

