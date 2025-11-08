//
//  NEOView.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI
import Combine

struct NEOView: View {
    @StateObject private var viewModel = NEOViewModel()
    @State private var selectedAsteroid: NearEarthObject? = nil
    @State private var filterOption: FilterOption = .all
    @State private var sortOption: SortOption = .date
    @State private var searchText: String = ""
    @State private var showFilters = false
    @State private var parallaxOffset: CGFloat = 0
    
    enum FilterOption: String, CaseIterable {
        case all = "Tümü"
        case hazardous = "Tehlikeli"
        case safe = "Güvenli"
    }
    
    enum SortOption: String, CaseIterable {
        case date = "Tarihe Göre"
        case distance = "Mesafeye Göre"
        case size = "Boyuta Göre"
        case speed = "Hıza Göre"
    }
    
    var filteredAndSortedAsteroids: [NearEarthObject] {
        var asteroids = viewModel.asteroids
        
        // Filtreleme
        switch filterOption {
        case .hazardous:
            asteroids = asteroids.filter { $0.isPotentiallyHazardousAsteroid }
        case .safe:
            asteroids = asteroids.filter { !$0.isPotentiallyHazardousAsteroid }
        case .all:
            break
        }
        
        // Arama
        if !searchText.isEmpty {
            asteroids = asteroids.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Sıralama
        switch sortOption {
        case .date:
            asteroids = asteroids.sorted { asteroid1, asteroid2 in
                guard let date1 = asteroid1.closeApproachData.first?.closeApproachDate,
                      let date2 = asteroid2.closeApproachData.first?.closeApproachDate else {
                    return false
                }
                return date1 < date2
            }
        case .distance:
            asteroids = asteroids.sorted { asteroid1, asteroid2 in
                guard let dist1 = asteroid1.closeApproachData.first?.missDistance.kilometers,
                      let dist2 = asteroid2.closeApproachData.first?.missDistance.kilometers,
                      let d1 = Double(dist1),
                      let d2 = Double(dist2) else {
                    return false
                }
                return d1 < d2
            }
        case .size:
            asteroids = asteroids.sorted { asteroid1, asteroid2 in
                let size1 = asteroid1.estimatedDiameter.kilometers.estimatedDiameterMax
                let size2 = asteroid2.estimatedDiameter.kilometers.estimatedDiameterMax
                return size1 > size2
            }
        case .speed:
            asteroids = asteroids.sorted { asteroid1, asteroid2 in
                guard let speed1 = asteroid1.closeApproachData.first?.relativeVelocity.kilometersPerSecond,
                      let speed2 = asteroid2.closeApproachData.first?.relativeVelocity.kilometersPerSecond,
                      let s1 = Double(speed1),
                      let s2 = Double(speed2) else {
                    return false
                }
                return s1 > s2
            }
        }
        
        return asteroids
    }
    
    var body: some View {
        ZStack {
            Theme.spaceBlack
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingView(message: "Asteroitler yükleniyor...", tintColor: Theme.nasaBlue)
            } else if let error = viewModel.error {
                ErrorView(error: error, retryAction: {
                    Task {
                        await viewModel.fetchNEOs()
                    }
                })
            } else if !viewModel.asteroids.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Parallax Header
                        ParallaxHeaderView(
                            totalCount: viewModel.asteroids.count,
                            hazardousCount: viewModel.hazardousCount,
                            parallaxOffset: parallaxOffset
                        )
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                            }
                        )
                        
                        // Content
                        VStack(spacing: 24) {
                            // İstatistikler
                            StatisticsView(viewModel: viewModel)
                            
                            // Filtreler ve Arama
                            FiltersView(
                                filterOption: $filterOption,
                                sortOption: $sortOption,
                                searchText: $searchText,
                                showFilters: $showFilters
                            )
                            
                            // Asteroit Listesi
                            LazyVStack(spacing: 16) {
                                ForEach(filteredAndSortedAsteroids) { asteroid in
                                    EnhancedNEOCard(
                                        asteroid: asteroid,
                                        onTap: {
                                            selectedAsteroid = asteroid
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 30)
                        }
                        .padding(.top, 20)
                    }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    parallaxOffset = value
                }
            } else {
                EmptyStateView(
                    icon: "star",
                    title: "Yakın asteroit bulunamadı",
                    message: "Şu anda Dünya'ya yakın asteroit yok",
                    iconColor: Theme.nasaBlue
                )
            }
        }
        .task {
            await viewModel.fetchNEOs()
        }
        .refreshable {
            await viewModel.fetchNEOs()
        }
        .sheet(item: $selectedAsteroid) { asteroid in
            AsteroidDetailSheet(asteroid: asteroid)
        }
    }
}

// MARK: - Parallax Header
struct ParallaxHeaderView: View {
    let totalCount: Int
    let hazardousCount: Int
    let parallaxOffset: CGFloat
    
    var body: some View {
        ZStack {
            // Arka plan gradyanı
            LinearGradient(
                colors: [
                    Theme.nasaBlue.opacity(0.3),
                    Theme.cosmicPurple.opacity(0.2),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
            .offset(y: parallaxOffset * 0.5)
            
            // Yıldızlar efekti
            StarsBackground()
                .frame(height: 280)
                .offset(y: parallaxOffset * 0.3)
            
            // İçerik
            VStack(spacing: 20) {
                Spacer()
                
                // Asteroit ikonu (animasyonlu)
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Theme.nasaBlue.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                    
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.nasaBlue)
                        .rotationEffect(.degrees(parallaxOffset * 0.1))
                }
                .offset(y: parallaxOffset * 0.2)
                
                VStack(spacing: 8) {
                    Text("Yakın Dünya Asteroitleri")
                        .font(Theme.titleFont(size: 32))
                        .foregroundColor(Theme.stellarWhite)
                        .shadow(color: Color.black.opacity(0.5), radius: 5)
                    
                    Text("\(totalCount) asteroit tespit edildi")
                        .font(Theme.bodyFont(size: 16))
                        .foregroundColor(Theme.stellarWhite.opacity(0.8))
                    
                    if hazardousCount > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Theme.nasaRed)
                            Text("\(hazardousCount) tehlikeli")
                                .font(Theme.captionFont())
                                .foregroundColor(Theme.nasaRed)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Theme.nasaRed.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Theme.nasaRed.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .frame(height: 280)
    }
}

// MARK: - Stars Background
struct StarsBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
}

// MARK: - Statistics View
struct StatisticsView: View {
    @ObservedObject var viewModel: NEOViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("İstatistikler")
                .font(Theme.titleFont(size: 22))
                .foregroundColor(Theme.stellarWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            
            HStack(spacing: 12) {
                EnhancedNEOStatCard(
                    title: "Toplam",
                    value: "\(viewModel.asteroids.count)",
                    icon: "globe",
                    color: Theme.nasaBlue,
                    gradient: true
                )
                
                EnhancedNEOStatCard(
                    title: "Tehlikeli",
                    value: "\(viewModel.hazardousCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: Theme.nasaRed,
                    gradient: true
                )
                
                EnhancedNEOStatCard(
                    title: "Güvenli",
                    value: "\(viewModel.asteroids.count - viewModel.hazardousCount)",
                    icon: "checkmark.circle.fill",
                    color: Theme.nasaBlue,
                    gradient: true
                )
            }
            .padding(.horizontal, 16)
            
            // Grafikler
            if !viewModel.asteroids.isEmpty {
                StatisticsChartsView(asteroids: viewModel.asteroids)
                    .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Enhanced Stat Card
struct EnhancedNEOStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let gradient: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(Theme.titleFont(size: 28))
                .foregroundColor(Theme.stellarWhite)
            
            Text(title)
                .font(Theme.captionFont(size: 11))
                .foregroundColor(color.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            Group {
                if gradient {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.15),
                                    color.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(color.opacity(0.3), lineWidth: 1.5)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.deepSpace)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        )
    }
}

// MARK: - Statistics Charts
struct StatisticsChartsView: View {
    let asteroids: [NearEarthObject]
    
    var averageSpeed: Double {
        let speeds = asteroids.compactMap { asteroid -> Double? in
            guard let speedStr = asteroid.closeApproachData.first?.relativeVelocity.kilometersPerSecond,
                  let speed = Double(speedStr) else { return nil }
            return speed
        }
        return speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count)
    }
    
    var averageSize: Double {
        let sizes = asteroids.map { asteroid in
            (asteroid.estimatedDiameter.kilometers.estimatedDiameterMin + asteroid.estimatedDiameter.kilometers.estimatedDiameterMax) / 2
        }
        return sizes.reduce(0, +) / Double(sizes.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Ortalama Hız
            ChartCard(
                title: "Ortalama Hız",
                value: "\(String(format: "%.2f", averageSpeed)) km/s",
                icon: "speedometer",
                color: Theme.nasaBlue,
                percentage: min(1.0, averageSpeed / 50.0) // Normalize to 0-50 km/s range
            )
            
            // Ortalama Boyut
            ChartCard(
                title: "Ortalama Boyut",
                value: "\(String(format: "%.2f", averageSize)) km",
                icon: "circle",
                color: Theme.cosmicPurple,
                percentage: min(1.0, averageSize / 5.0) // Normalize to 0-5 km range
            )
        }
    }
}

// MARK: - Chart Card
struct ChartCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let percentage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(Theme.bodyFont(size: 16, weight: .semibold))
                    .foregroundColor(Theme.stellarWhite)
                Spacer()
                Text(value)
                    .font(Theme.bodyFont(size: 14))
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.deepSpace)
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.8), color.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(percentage), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Filters View
struct FiltersView: View {
    @Binding var filterOption: NEOView.FilterOption
    @Binding var sortOption: NEOView.SortOption
    @Binding var searchText: String
    @Binding var showFilters: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Arama Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.nasaBlue)
                
                TextField("Asteroit ara...", text: $searchText)
                    .foregroundColor(Theme.stellarWhite)
                    .font(Theme.bodyFont())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.deepSpace)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.nasaBlue.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Filtre ve Sıralama Butonları
            HStack(spacing: 12) {
                // Filtre
                Menu {
                    ForEach(NEOView.FilterOption.allCases, id: \.self) { option in
                        Button(action: {
                            filterOption = option
                        }) {
                            HStack {
                                Text(option.rawValue)
                                if filterOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(filterOption.rawValue)
                    }
                    .font(Theme.bodyFont(size: 14))
                    .foregroundColor(Theme.stellarWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.deepSpace)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Theme.nasaBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // Sıralama
                Menu {
                    ForEach(NEOView.SortOption.allCases, id: \.self) { option in
                        Button(action: {
                            sortOption = option
                        }) {
                            HStack {
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortOption.rawValue)
                    }
                    .font(Theme.bodyFont(size: 14))
                    .foregroundColor(Theme.stellarWhite)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.deepSpace)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Theme.nasaBlue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Enhanced NEO Card
struct EnhancedNEOCard: View {
    let asteroid: NearEarthObject
    let onTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    // Asteroit İkonu (3D efekti)
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: asteroid.isPotentiallyHazardousAsteroid ?
                                    [Theme.nasaRed.opacity(0.3), Color.clear] :
                                    [Theme.nasaBlue.opacity(0.3), Color.clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: asteroid.isPotentiallyHazardousAsteroid ? "exclamationmark.triangle.fill" : "circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(asteroid.isPotentiallyHazardousAsteroid ? Theme.nasaRed : Theme.nasaBlue)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(asteroid.name)
                            .font(Theme.titleFont(size: 18))
                            .foregroundColor(Theme.stellarWhite)
                            .lineLimit(1)
                        
                        if asteroid.isPotentiallyHazardousAsteroid {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                Text("Tehlikeli")
                                    .font(Theme.captionFont(size: 11))
                            }
                            .foregroundColor(Theme.nasaRed)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Theme.nasaRed.opacity(0.2))
                            )
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.nasaBlue)
                        .font(.system(size: 14))
                }
                
                if let approach = asteroid.closeApproachData.first {
                    Divider()
                        .background(Theme.nasaBlue.opacity(0.2))
                    
                    // Detaylar Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        NEODetailItem(
                            icon: "calendar",
                            label: "Yaklaşma",
                            value: formatDate(approach.closeApproachDate),
                            color: Theme.nasaBlue
                        )
                        
                        NEODetailItem(
                            icon: "speedometer",
                            label: "Hız",
                            value: "\(String(format: "%.2f", Double(approach.relativeVelocity.kilometersPerSecond) ?? 0)) km/s",
                            color: Theme.cosmicPurple
                        )
                        
                        NEODetailItem(
                            icon: "ruler",
                            label: "Çap",
                            value: "\(String(format: "%.1f", asteroid.estimatedDiameter.kilometers.estimatedDiameterMin))-\(String(format: "%.1f", asteroid.estimatedDiameter.kilometers.estimatedDiameterMax)) km",
                            color: Theme.nasaBlue
                        )
                        
                        NEODetailItem(
                            icon: "arrow.down.right",
                            label: "Mesafe",
                            value: formatDistance(approach.missDistance.kilometers),
                            color: Theme.cosmicPurple
                        )
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Theme.deepSpace,
                                Theme.deepSpace.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                asteroid.isPotentiallyHazardousAsteroid ? Theme.nasaRed.opacity(0.6) : Theme.nasaBlue.opacity(0.3),
                                lineWidth: asteroid.isPotentiallyHazardousAsteroid ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: asteroid.isPotentiallyHazardousAsteroid ? Theme.nasaRed.opacity(0.3) : Theme.nasaBlue.opacity(0.1),
                radius: asteroid.isPotentiallyHazardousAsteroid ? 10 : 5
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMM yyyy"
        outputFormatter.locale = Locale(identifier: "tr_TR")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    private func formatDistance(_ distanceString: String) -> String {
        if let distance = Double(distanceString) {
            let distanceInMillionKm = distance / 1_000_000
            if distanceInMillionKm < 1 {
                return String(format: "%.2f milyon km", distanceInMillionKm)
            } else {
                return String(format: "%.1f milyon km", distanceInMillionKm)
            }
        }
        return "Bilinmiyor"
    }
}

// MARK: - NEO Detail Item
struct NEODetailItem: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(label)
                    .font(Theme.captionFont(size: 10))
                    .foregroundColor(Theme.stellarWhite.opacity(0.6))
            }
            
            Text(value)
                .font(Theme.bodyFont(size: 13, weight: .semibold))
                .foregroundColor(Theme.stellarWhite)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var message: String = "Yükleniyor..."
    var tintColor: Color = Theme.nasaBlue
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
                .scaleEffect(1.5)
            
            Text(message)
                .font(Theme.bodyFont())
                .foregroundColor(Theme.stellarWhite.opacity(0.7))
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(Theme.nasaRed)
            
            Text("Hata")
                .font(Theme.titleFont(size: 24))
                .foregroundColor(Theme.stellarWhite)
            
            Text(error.localizedDescription)
                .font(Theme.bodyFont())
                .foregroundColor(Theme.stellarWhite.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Yeniden Dene") {
                retryAction()
            }
            .buttonStyle(NASAPrimaryButtonStyle())
        }
        .padding()
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var icon: String = "star"
    var title: String = "Veri bulunamadı"
    var message: String = "Şu anda veri mevcut değil"
    var iconColor: Color = Theme.nasaBlue
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(iconColor)
            
            Text(title)
                .font(Theme.titleFont(size: 20))
                .foregroundColor(Theme.stellarWhite)
            
            Text(message)
                .font(Theme.bodyFont())
                .foregroundColor(Theme.stellarWhite.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Asteroid Detail Sheet
struct AsteroidDetailSheet: View {
    let asteroid: NearEarthObject
    @Environment(\.dismiss) var dismiss
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }
                
                VStack(spacing: 0) {
                    // Handle bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 50, height: 5)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Header
                            VStack(spacing: 16) {
                                // Asteroit İkonu
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: asteroid.isPotentiallyHazardousAsteroid ?
                                                [Theme.nasaRed.opacity(0.4), Color.clear] :
                                                [Theme.nasaBlue.opacity(0.4), Color.clear],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 60
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                        .blur(radius: 15)
                                    
                                    Image(systemName: asteroid.isPotentiallyHazardousAsteroid ? "exclamationmark.triangle.fill" : "circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(asteroid.isPotentiallyHazardousAsteroid ? Theme.nasaRed : Theme.nasaBlue)
                                }
                                
                                Text(asteroid.name)
                                    .font(Theme.titleFont(size: 28))
                                    .foregroundColor(Theme.stellarWhite)
                                
                                if asteroid.isPotentiallyHazardousAsteroid {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                        Text("Potansiyel Tehlikeli Asteroit")
                                    }
                                    .font(Theme.bodyFont(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.nasaRed)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Theme.nasaRed.opacity(0.2))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Theme.nasaRed.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            .padding(.top)
                            
                            Divider()
                                .background(Theme.nasaBlue.opacity(0.3))
                            
                            // Detaylar
                            if let approach = asteroid.closeApproachData.first {
                                VStack(spacing: 20) {
                                    // Yaklaşma Bilgileri
                                    DetailSectionView(
                                        title: "Yaklaşma Bilgileri",
                                        items: [
                                            DetailItem(label: "Tarih", value: formatDate(approach.closeApproachDate), icon: "calendar", color: Theme.nasaBlue),
                                            DetailItem(label: "Hız", value: "\(String(format: "%.2f", Double(approach.relativeVelocity.kilometersPerSecond) ?? 0)) km/s", icon: "speedometer", color: Theme.cosmicPurple),
                                            DetailItem(label: "Mesafe", value: formatDistance(approach.missDistance.kilometers), icon: "arrow.down.right", color: Theme.nasaBlue),
                                        ]
                                    )
                                    
                                    // Boyut Bilgileri
                                    DetailSectionView(
                                        title: "Boyut Bilgileri",
                                        items: [
                                            DetailItem(label: "Min Çap", value: "\(String(format: "%.2f", asteroid.estimatedDiameter.kilometers.estimatedDiameterMin)) km", icon: "arrow.down", color: Theme.nasaBlue),
                                            DetailItem(label: "Max Çap", value: "\(String(format: "%.2f", asteroid.estimatedDiameter.kilometers.estimatedDiameterMax)) km", icon: "arrow.up", color: Theme.cosmicPurple),
                                            DetailItem(label: "Ortalama Çap", value: "\(String(format: "%.2f", (asteroid.estimatedDiameter.kilometers.estimatedDiameterMin + asteroid.estimatedDiameter.kilometers.estimatedDiameterMax) / 2)) km", icon: "circle", color: Theme.nasaBlue),
                                        ]
                                    )
                                    
                                    // Görselleştirme
                                    SizeVisualizationView(asteroid: asteroid)
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            Spacer(minLength: 30)
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.85)
                .background(
                    LinearGradient(
                        colors: [
                            Theme.deepSpace,
                            Theme.spaceBlack.opacity(0.98),
                            Theme.spaceBlack
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(25, corners: [.topLeft, .topRight])
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 150 {
                                dismiss()
                            } else {
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy"
        outputFormatter.locale = Locale(identifier: "tr_TR")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    private func formatDistance(_ distanceString: String) -> String {
        if let distance = Double(distanceString) {
            let distanceInMillionKm = distance / 1_000_000
            if distanceInMillionKm < 1 {
                return String(format: "%.3f milyon km", distanceInMillionKm)
            } else {
                return String(format: "%.2f milyon km", distanceInMillionKm)
            }
        }
        return "Bilinmiyor"
    }
}

// MARK: - Detail Section View
struct DetailSectionView: View {
    let title: String
    let items: [DetailItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.titleFont(size: 20))
                .foregroundColor(Theme.stellarWhite)
            
            VStack(spacing: 12) {
                ForEach(items) { item in
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(item.color.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: item.icon)
                                .font(.system(size: 18))
                                .foregroundColor(item.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.label)
                                .font(Theme.captionFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.7))
                            
                            Text(item.value)
                                .font(Theme.bodyFont(size: 16, weight: .semibold))
                                .foregroundColor(Theme.stellarWhite)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Theme.deepSpace)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(item.color.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}

// MARK: - Detail Item
struct DetailItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String
    let color: Color
}

// MARK: - Size Visualization View
struct SizeVisualizationView: View {
    let asteroid: NearEarthObject
    
    var averageDiameter: Double {
        (asteroid.estimatedDiameter.kilometers.estimatedDiameterMin + asteroid.estimatedDiameter.kilometers.estimatedDiameterMax) / 2
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Boyut Görselleştirme")
                .font(Theme.titleFont(size: 18))
                .foregroundColor(Theme.stellarWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Dünya ile karşılaştırma
            HStack(spacing: 20) {
                // Dünya (referans)
                VStack(spacing: 8) {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.blue, Color.cyan],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.blue.opacity(0.5), radius: 10)
                    
                    Text("Dünya")
                        .font(Theme.captionFont(size: 11))
                        .foregroundColor(Theme.stellarWhite.opacity(0.8))
                    
                    Text("12,756 km")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.stellarWhite.opacity(0.6))
                }
                
                // Asteroit
                VStack(spacing: 8) {
                    let scale = min(0.8, max(0.05, averageDiameter / 12756.0))
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Theme.nasaBlue, Theme.cosmicPurple],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 60 * scale, height: 60 * scale)
                        .shadow(color: Theme.nasaBlue.opacity(0.5), radius: 10)
                    
                    Text("Asteroit")
                        .font(Theme.captionFont(size: 11))
                        .foregroundColor(Theme.stellarWhite.opacity(0.8))
                    
                    Text("\(String(format: "%.2f", averageDiameter)) km")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.stellarWhite.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.deepSpace)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.nasaBlue.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - ViewModel
class NEOViewModel: ObservableObject {
    @Published var asteroids: [NearEarthObject] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    var hazardousCount: Int {
        asteroids.filter { $0.isPotentiallyHazardousAsteroid }.count
    }
    
    func fetchNEOs() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
            let response = try await NASAAPIService.shared.fetchNEO(startDate: startDate, endDate: endDate)
            
            var allAsteroids: [NearEarthObject] = []
            for (_, asteroids) in response.nearEarthObjects {
                allAsteroids.append(contentsOf: asteroids)
            }
            
            await MainActor.run {
                self.asteroids = allAsteroids.sorted { asteroid1, asteroid2 in
                    guard let date1 = asteroid1.closeApproachData.first?.closeApproachDate,
                          let date2 = asteroid2.closeApproachData.first?.closeApproachDate else {
                        return false
                    }
                    return date1 < date2
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
}

#Preview {
    NEOView()
}
