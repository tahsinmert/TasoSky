//
//  MarsWeatherView.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI
import Combine

struct MarsWeatherView: View {
    @StateObject private var viewModel = MarsWeatherViewModel()
    @State private var selectedSol: SolData? = nil
    @State private var parallaxOffset: CGFloat = 0
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            Theme.spaceBlack
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                LoadingView(message: "Mars hava durumu yükleniyor...", tintColor: Theme.nasaRed)
            } else if let error = viewModel.error {
                ErrorView(error: error, retryAction: {
                    Task {
                        await viewModel.fetchWeather()
                    }
                })
            } else if !viewModel.solData.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Parallax Header
                        MarsParallaxHeaderView(
                            solCount: viewModel.solData.count,
                            latestSol: viewModel.solData.first,
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
                            MarsStatisticsView(viewModel: viewModel)
                            
                            // Sekmeler
                            MarsTabView(selectedTab: $selectedTab)
                            
                            // İçerik
                            VStack(spacing: 20) {
                                switch selectedTab {
                                case 0:
                                    LatestSolView(
                                        sol: viewModel.solData.first,
                                        onTap: { sol in
                                            selectedSol = sol
                                        }
                                    )
                                    
                                    RecentSolsView(
                                        sols: Array(viewModel.solData.dropFirst().prefix(6)),
                                        onTap: { sol in
                                            selectedSol = sol
                                        }
                                    )
                                    
                                case 1:
                                    PressureChartView(sols: viewModel.solData)
                                    
                                case 2:
                                    WindChartView(sols: viewModel.solData)
                                    
                                case 3:
                                    AllSolsView(
                                        sols: viewModel.solData,
                                        onTap: { sol in
                                            selectedSol = sol
                                        }
                                    )
                                    
                                default:
                                    LatestSolView(
                                        sol: viewModel.solData.first,
                                        onTap: { sol in
                                            selectedSol = sol
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
                    icon: "cloud.slash",
                    title: "Hava durumu verisi bulunamadı",
                    message: "Şu anda Mars hava durumu verisi mevcut değil",
                    iconColor: Theme.nasaRed
                )
            }
        }
        .task {
            await viewModel.fetchWeather()
        }
        .refreshable {
            await viewModel.fetchWeather()
        }
        .sheet(item: $selectedSol) { sol in
            SolDetailSheet(sol: sol)
        }
    }
}

// MARK: - Parallax Header
struct MarsParallaxHeaderView: View {
    let solCount: Int
    let latestSol: SolData?
    let parallaxOffset: CGFloat
    
    var body: some View {
        ZStack {
            // Arka plan gradyanı
            LinearGradient(
                colors: [
                    Theme.nasaRed.opacity(0.4),
                    Color.orange.opacity(0.3),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 320)
            .offset(y: parallaxOffset * 0.5)
            
            // Mars yüzey efekti
            MarsSurfaceEffect()
                .frame(height: 320)
                .offset(y: parallaxOffset * 0.3)
            
            // İçerik
            VStack(spacing: 20) {
                Spacer()
                
                // Mars ikonu (animasyonlu)
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Theme.nasaRed.opacity(0.5),
                                    Color.orange.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)
                        .blur(radius: 25)
                    
                    Image(systemName: "globe.asia.australia.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Theme.nasaRed)
                        .rotationEffect(.degrees(parallaxOffset * 0.1))
                        .shadow(color: Theme.nasaRed.opacity(0.8), radius: 20)
                }
                .offset(y: parallaxOffset * 0.2)
                
                VStack(spacing: 8) {
                    Text("Mars Hava Durumu")
                        .font(Theme.titleFont(size: 32))
                        .foregroundColor(Theme.stellarWhite)
                        .shadow(color: Color.black.opacity(0.5), radius: 5)
                    
                    Text("InSight Lander")
                        .font(Theme.bodyFont(size: 16))
                        .foregroundColor(Theme.stellarWhite.opacity(0.8))
                    
                    if let sol = latestSol {
                        HStack(spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "sun.max.fill")
                                    .font(.system(size: 14))
                                Text("Sol \(sol.id)")
                                    .font(Theme.bodyFont(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Theme.nasaRed)
                            
                            if let season = sol.season {
                                Text("•")
                                    .foregroundColor(Theme.stellarWhite.opacity(0.5))
                                Text(season.capitalized)
                                    .font(Theme.bodyFont(size: 14))
                                    .foregroundColor(Theme.stellarWhite.opacity(0.8))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Theme.deepSpace.opacity(0.7))
                                .overlay(
                                    Capsule()
                                        .stroke(Theme.nasaRed.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                    
                    Text("\(solCount) sol verisi mevcut")
                        .font(Theme.captionFont())
                        .foregroundColor(Theme.stellarWhite.opacity(0.6))
                }
                .padding(.bottom, 40)
            }
        }
        .frame(height: 320)
    }
}

// MARK: - Mars Surface Effect
struct MarsSurfaceEffect: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Mars yüzey deseni
                ForEach(0..<30, id: \.self) { _ in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.orange.opacity(Double.random(in: 0.1...0.3)),
                                    Color.red.opacity(Double.random(in: 0.05...0.2)),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(
                            width: CGFloat.random(in: 20...60),
                            height: CGFloat.random(in: 20...60)
                        )
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: CGFloat.random(in: 2...8))
                }
            }
        }
    }
}

// MARK: - Statistics View
struct MarsStatisticsView: View {
    @ObservedObject var viewModel: MarsWeatherViewModel
    
    var averagePressure: Double {
        let pressures = viewModel.solData.compactMap { $0.atmosphericPressure?.average }
        return pressures.isEmpty ? 0 : pressures.reduce(0, +) / Double(pressures.count)
    }
    
    var averageWindSpeed: Double {
        let speeds = viewModel.solData.compactMap { $0.horizontalWindSpeed?.average }
        return speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count)
    }
    
    var maxWindSpeed: Double {
        viewModel.solData.compactMap { $0.horizontalWindSpeed?.maximum }.max() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("İstatistikler")
                .font(Theme.titleFont(size: 22))
                .foregroundColor(Theme.stellarWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            
            HStack(spacing: 12) {
                MarsStatCard(
                    title: "Ort. Basınç",
                    value: "\(String(format: "%.1f", averagePressure))",
                    unit: "Pa",
                    icon: "barometer",
                    color: Theme.nasaBlue,
                    gradient: true
                )
                
                MarsStatCard(
                    title: "Ort. Rüzgar",
                    value: "\(String(format: "%.1f", averageWindSpeed))",
                    unit: "m/s",
                    icon: "wind",
                    color: Theme.cosmicPurple,
                    gradient: true
                )
                
                MarsStatCard(
                    title: "Max Rüzgar",
                    value: "\(String(format: "%.1f", maxWindSpeed))",
                    unit: "m/s",
                    icon: "tornado",
                    color: Theme.nasaRed,
                    gradient: true
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Mars Stat Card
struct MarsStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let gradient: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(Theme.titleFont(size: 24))
                    .foregroundColor(Theme.stellarWhite)
                Text(unit)
                    .font(Theme.captionFont(size: 10))
                    .foregroundColor(Theme.stellarWhite.opacity(0.6))
            }
            
            Text(title)
                .font(Theme.captionFont(size: 10))
                .foregroundColor(color.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
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

// MARK: - Tab View
struct MarsTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                TabButton(title: "Güncel", index: 0, selectedTab: $selectedTab, color: Theme.nasaRed)
                TabButton(title: "Basınç", index: 1, selectedTab: $selectedTab, color: Theme.nasaRed)
                TabButton(title: "Rüzgar", index: 2, selectedTab: $selectedTab, color: Theme.nasaRed)
                TabButton(title: "Tümü", index: 3, selectedTab: $selectedTab, color: Theme.nasaRed)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Theme.deepSpace)
            
            Divider()
                .background(Theme.nasaRed.opacity(0.3))
        }
    }
}

// MARK: - Latest Sol View
struct LatestSolView: View {
    let sol: SolData?
    let onTap: (SolData) -> Void
    
    var body: some View {
        if let sol = sol {
            VStack(alignment: .leading, spacing: 16) {
                Text("En Son Veri")
                    .font(Theme.titleFont(size: 20))
                    .foregroundColor(Theme.stellarWhite)
                
                EnhancedSolCard(sol: sol, isLatest: true, onTap: { onTap(sol) })
            }
        }
    }
}

// MARK: - Recent Sols View
struct RecentSolsView: View {
    let sols: [SolData]
    let onTap: (SolData) -> Void
    
    var body: some View {
        if !sols.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Son Veriler")
                    .font(Theme.titleFont(size: 20))
                    .foregroundColor(Theme.stellarWhite)
                
                LazyVStack(spacing: 12) {
                    ForEach(sols) { sol in
                        EnhancedSolCard(sol: sol, isLatest: false, onTap: { onTap(sol) })
                    }
                }
            }
        }
    }
}

// MARK: - All Sols View
struct AllSolsView: View {
    let sols: [SolData]
    let onTap: (SolData) -> Void
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(sols) { sol in
                EnhancedSolCard(sol: sol, isLatest: false, onTap: { onTap(sol) })
            }
        }
    }
}

// MARK: - Enhanced Sol Card
struct EnhancedSolCard: View {
    let sol: SolData
    let isLatest: Bool
    let onTap: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    // Sol İkonu
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Theme.nasaRed.opacity(0.3),
                                        Color.orange.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.nasaRed)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sol \(sol.id)")
                            .font(Theme.titleFont(size: isLatest ? 22 : 18))
                            .foregroundColor(Theme.stellarWhite)
                        
                        if let season = sol.season {
                            Text(season.capitalized)
                                .font(Theme.captionFont(size: 12))
                                .foregroundColor(Theme.nasaRed)
                        }
                    }
                    
                    Spacer()
                    
                    if isLatest {
                        Text("EN SON")
                            .font(Theme.captionFont(size: 10))
                            .foregroundColor(Theme.nasaRed)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Theme.nasaRed.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Theme.nasaRed.opacity(0.5), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.nasaBlue)
                        .font(.system(size: 14))
                }
                
                Divider()
                    .background(Theme.nasaRed.opacity(0.2))
                
                // Metrics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    if let pressure = sol.atmosphericPressure {
                        MarsMetricItem(
                            icon: "barometer",
                            label: "Basınç",
                            value: "\(String(format: "%.1f", pressure.average ?? 0))",
                            unit: "Pa",
                            min: pressure.minimum,
                            max: pressure.maximum,
                            color: Theme.nasaBlue
                        )
                    }
                    
                    if let windSpeed = sol.horizontalWindSpeed {
                        MarsMetricItem(
                            icon: "wind",
                            label: "Rüzgar",
                            value: "\(String(format: "%.1f", windSpeed.average ?? 0))",
                            unit: "m/s",
                            min: windSpeed.minimum,
                            max: windSpeed.maximum,
                            color: Theme.cosmicPurple
                        )
                    }
                    
                    if let direction = sol.mostCommonWindDirection {
                        MarsMetricItem(
                            icon: "arrow.up.right",
                            label: "Rüzgar Yönü",
                            value: direction,
                            unit: "",
                            min: nil,
                            max: nil,
                            color: Theme.nebulaPink
                        )
                    }
                    
                    if let firstUTC = sol.firstUTC {
                        MarsMetricItem(
                            icon: "clock",
                            label: "Tarih",
                            value: formatShortDate(firstUTC),
                            unit: "",
                            min: nil,
                            max: nil,
                            color: Theme.nasaBlue
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
                                isLatest ? Theme.nasaRed.opacity(0.6) : Theme.nasaBlue.opacity(0.3),
                                lineWidth: isLatest ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isLatest ? Theme.nasaRed.opacity(0.3) : Theme.nasaBlue.opacity(0.1),
                radius: isLatest ? 10 : 5
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    private func formatShortDate(_ dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMM"
            outputFormatter.locale = Locale(identifier: "tr_TR")
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Mars Metric Item
struct MarsMetricItem: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    let min: Double?
    let max: Double?
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
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(Theme.bodyFont(size: 15, weight: .semibold))
                    .foregroundColor(Theme.stellarWhite)
                if !unit.isEmpty {
                    Text(unit)
                        .font(Theme.captionFont(size: 9))
                        .foregroundColor(Theme.stellarWhite.opacity(0.5))
                }
            }
            
            if let min = min, let max = max {
                HStack(spacing: 4) {
                    Text("\(String(format: "%.1f", min))")
                        .font(.system(size: 8))
                        .foregroundColor(Theme.stellarWhite.opacity(0.4))
                    Text("-")
                        .font(.system(size: 8))
                        .foregroundColor(Theme.stellarWhite.opacity(0.4))
                    Text("\(String(format: "%.1f", max))")
                        .font(.system(size: 8))
                        .foregroundColor(Theme.stellarWhite.opacity(0.4))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Pressure Chart View
struct PressureChartView: View {
    let sols: [SolData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basınç Grafiği")
                .font(Theme.titleFont(size: 20))
                .foregroundColor(Theme.stellarWhite)
            
            if !sols.isEmpty {
                ChartContainerView(
                    data: sols.compactMap { sol -> ChartDataPoint? in
                        guard let pressure = sol.atmosphericPressure?.average else { return nil }
                        return ChartDataPoint(
                            label: "Sol \(sol.id)",
                            value: pressure,
                            color: Theme.nasaBlue
                        )
                    },
                    unit: "Pa",
                    color: Theme.nasaBlue
                )
            }
        }
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

// MARK: - Wind Chart View
struct WindChartView: View {
    let sols: [SolData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rüzgar Hızı Grafiği")
                .font(Theme.titleFont(size: 20))
                .foregroundColor(Theme.stellarWhite)
            
            if !sols.isEmpty {
                ChartContainerView(
                    data: sols.compactMap { sol -> ChartDataPoint? in
                        guard let windSpeed = sol.horizontalWindSpeed?.average else { return nil }
                        return ChartDataPoint(
                            label: "Sol \(sol.id)",
                            value: windSpeed,
                            color: Theme.cosmicPurple
                        )
                    },
                    unit: "m/s",
                    color: Theme.cosmicPurple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.cosmicPurple.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Chart Data Point
struct ChartDataPoint {
    let label: String
    let value: Double
    let color: Color
}

// MARK: - Chart Container View
struct ChartContainerView: View {
    let data: [ChartDataPoint]
    let unit: String
    let color: Color
    
    var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }
    
    var minValue: Double {
        data.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Y ekseni
            HStack(alignment: .bottom, spacing: 8) {
                // Y ekseni etiketleri
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(String(format: "%.1f", maxValue)) \(unit)")
                        .font(.system(size: 9))
                        .foregroundColor(Theme.stellarWhite.opacity(0.5))
                    Spacer()
                    Text("\(String(format: "%.1f", minValue)) \(unit)")
                        .font(.system(size: 9))
                        .foregroundColor(Theme.stellarWhite.opacity(0.5))
                }
                .frame(width: 50)
                
                // Grafik çubukları
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(Array(data.enumerated()), id: \.offset) { index, point in
                            VStack(spacing: 4) {
                                GeometryReader { geometry in
                                    VStack {
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        color.opacity(0.8),
                                                        color.opacity(0.6)
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(
                                                height: max(4, geometry.size.height * CGFloat((point.value - minValue) / (maxValue - minValue)))
                                            )
                                    }
                                }
                                .frame(width: 30, height: 120)
                                
                                Text(point.label)
                                    .font(.system(size: 8))
                                    .foregroundColor(Theme.stellarWhite.opacity(0.6))
                                    .rotationEffect(.degrees(-45))
                                    .frame(width: 40)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
    }
}

// MARK: - Sol Detail Sheet
struct SolDetailSheet: View {
    let sol: SolData
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
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    Theme.nasaRed.opacity(0.4),
                                                    Color.orange.opacity(0.3),
                                                    Color.clear
                                                ],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 60
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                        .blur(radius: 15)
                                    
                                    Image(systemName: "sun.max.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(Theme.nasaRed)
                                }
                                
                                Text("Sol \(sol.id)")
                                    .font(Theme.titleFont(size: 28))
                                    .foregroundColor(Theme.stellarWhite)
                                
                                if let season = sol.season {
                                    Text(season.capitalized)
                                        .font(Theme.bodyFont(size: 16))
                                        .foregroundColor(Theme.nasaRed)
                                }
                            }
                            .padding(.top)
                            
                            Divider()
                                .background(Theme.nasaRed.opacity(0.3))
                            
                            // Detaylar
                            VStack(spacing: 20) {
                                // Basınç Detayları
                                if let pressure = sol.atmosphericPressure {
                                    DetailSectionView(
                                        title: "Atmosfer Basıncı",
                                        items: [
                                            DetailItem(label: "Ortalama", value: "\(String(format: "%.2f", pressure.average ?? 0)) Pa", icon: "barometer", color: Theme.nasaBlue),
                                            DetailItem(label: "Minimum", value: "\(String(format: "%.2f", pressure.minimum ?? 0)) Pa", icon: "arrow.down", color: Theme.nasaBlue),
                                            DetailItem(label: "Maksimum", value: "\(String(format: "%.2f", pressure.maximum ?? 0)) Pa", icon: "arrow.up", color: Theme.nasaBlue),
                                        ]
                                    )
                                }
                                
                                // Rüzgar Detayları
                                if let windSpeed = sol.horizontalWindSpeed {
                                    DetailSectionView(
                                        title: "Rüzgar Hızı",
                                        items: [
                                            DetailItem(label: "Ortalama", value: "\(String(format: "%.2f", windSpeed.average ?? 0)) m/s", icon: "wind", color: Theme.cosmicPurple),
                                            DetailItem(label: "Minimum", value: "\(String(format: "%.2f", windSpeed.minimum ?? 0)) m/s", icon: "arrow.down", color: Theme.cosmicPurple),
                                            DetailItem(label: "Maksimum", value: "\(String(format: "%.2f", windSpeed.maximum ?? 0)) m/s", icon: "arrow.up", color: Theme.cosmicPurple),
                                        ]
                                    )
                                }
                                
                                // Rüzgar Yönü
                                if let direction = sol.mostCommonWindDirection {
                                    DetailSectionView(
                                        title: "Rüzgar Yönü",
                                        items: [
                                            DetailItem(label: "En Yaygın", value: direction, icon: "arrow.up.right", color: Theme.nebulaPink),
                                        ]
                                    )
                                }
                                
                                // Tarih Bilgileri
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Tarih Bilgileri")
                                        .font(Theme.titleFont(size: 18))
                                        .foregroundColor(Theme.stellarWhite)
                                    
                                    if let firstUTC = sol.firstUTC {
                                        DetailRow(label: "İlk Ölçüm", value: formatDate(firstUTC), color: Theme.nasaBlue)
                                    }
                                    
                                    if let lastUTC = sol.lastUTC {
                                        DetailRow(label: "Son Ölçüm", value: formatDate(lastUTC), color: Theme.nasaBlue)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            
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
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMMM yyyy, HH:mm"
            outputFormatter.locale = Locale(identifier: "tr_TR")
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - ViewModel
class MarsWeatherViewModel: ObservableObject {
    @Published var solData: [SolData] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetchWeather() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let sols = try await NASAAPIService.shared.fetchMarsWeather()
            await MainActor.run {
                self.solData = sols
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
    MarsWeatherView()
}
