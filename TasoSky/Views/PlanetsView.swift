//
//  PlanetsView.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI

struct PlanetsView: View {
    @State private var selectedPlanet: Planet? = nil
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var showOrbits = true
    @State private var animationSpeed: Double = 1.0
    @State private var currentIndex = 0
    
    let planets = Planet.planets
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Theme.spaceBlack
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Güneş Sistemi")
                                    .font(Theme.titleFont(size: 32))
                                    .foregroundColor(Theme.stellarWhite)
                                Text("Gezegenleri Keşfedin")
                                    .font(Theme.captionFont())
                                    .foregroundColor(Theme.stellarWhite.opacity(0.6))
                            }
                            Spacer()
                            
                            // Animasyon kontrolü
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showOrbits.toggle()
                                }
                            }) {
                                Image(systemName: showOrbits ? "eye.fill" : "eye.slash.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.nasaBlue)
                                    .padding(12)
                                    .background(Theme.deepSpace)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                    
                    // Güneş ve Gezegenler Animasyonu
                    VStack(spacing: 16) {
                        SolarSystemView(
                            selectedPlanet: $selectedPlanet,
                            showOrbits: showOrbits,
                            animationSpeed: animationSpeed
                        )
                        .frame(height: 400)
                        
                        // Gezegen İsimleri (Küçük)
                        if selectedPlanet == nil {
                            Text("Bir gezegene dokunarak detayları görün")
                                .font(Theme.captionFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.5))
                                .padding(.top, 8)
                        } else {
                            Text(selectedPlanet?.turkishName ?? "")
                                .font(Theme.titleFont(size: 24))
                                .foregroundColor(Color(hex: selectedPlanet?.color.primary ?? "#4A90E2"))
                                .padding(.top, 8)
                        }
                    }
                    .padding(.vertical)
                    
                    // Gezegen Listesi
                    VStack(spacing: 16) {
                        ForEach(Array(planets.enumerated()), id: \.element.id) { index, planet in
                            PlanetCard(
                                planet: planet,
                                isSelected: selectedPlanet?.id == planet.id,
                                index: index
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedPlanet = planet
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            
            // Detay Sheet
            if let planet = selectedPlanet {
                PlanetDetailSheet(
                    planet: planet,
                    isPresented: Binding(
                        get: { selectedPlanet != nil },
                        set: { if !$0 { selectedPlanet = nil } }
                    )
                )
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}

struct SolarSystemView: View {
    @Binding var selectedPlanet: Planet?
    let showOrbits: Bool
    let animationSpeed: Double
    @State private var rotationAngle: Double = 0
    
    let planets = Planet.planets
    
    // Ölçekli mesafeler (görsel olarak daha iyi)
    private var scaledDistances: [CGFloat] {
        let baseDistances: [CGFloat] = [45, 65, 85, 105, 140, 175, 210, 245]
        return baseDistances
    }
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Güneş
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.9),
                                Color.orange.opacity(0.8),
                                Color.red.opacity(0.6)
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 35
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: .yellow.opacity(0.9), radius: 25, x: 0, y: 0)
                    .blur(radius: 1)
                    .position(center)
                
                // Yörüngeler ve Gezegenler
                ForEach(Array(planets.enumerated()), id: \.element.id) { index, planet in
                    let distance = scaledDistances[min(index, scaledDistances.count - 1)]
                    let angle = Double(index) * (360.0 / Double(planets.count)) + rotationAngle * animationSpeed
                    let radian = angle * .pi / 180
                    let x = center.x + cos(radian) * distance
                    let y = center.y + sin(radian) * distance
                
                    // Yörünge çizgisi
                    if showOrbits {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: planet.color.primary).opacity(0.3),
                                        Color(hex: planet.color.primary).opacity(0.1),
                                        Color(hex: planet.color.primary).opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: distance * 2, height: distance * 2)
                            .position(center)
                    }
                    
                    // Gezegen
                    PlanetOrbitView(
                        planet: planet,
                        position: CGPoint(x: x, y: y),
                        isSelected: selectedPlanet?.id == planet.id,
                        animationSpeed: animationSpeed
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedPlanet = planet
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 40 / animationSpeed).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct PlanetOrbitView: View {
    let planet: Planet
    let position: CGPoint
    let isSelected: Bool
    let animationSpeed: Double
    @State private var planetRotation: Double = 0
    
    // Gezegen boyutları (görsel olarak daha belirgin)
    private var planetSize: CGFloat {
        let baseSizes: [CGFloat] = [12, 14, 16, 14, 28, 26, 18, 18] // Gerçekçi oranlar
        let index = Planet.planets.firstIndex(where: { $0.id == planet.id }) ?? 0
        return baseSizes[min(index, baseSizes.count - 1)] * (isSelected ? 1.5 : 1.0)
    }
    
    var body: some View {
        ZStack {
            // Gezegen gölgesi
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: planetSize * 2.2, height: planetSize * 0.8)
                .offset(x: 2, y: planetSize + 2)
                .blur(radius: 3)
            
            // Gezegen
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: planet.color.primary).opacity(0.95),
                            Color(hex: planet.color.secondary).opacity(0.9),
                            Color(hex: planet.color.accent).opacity(0.8)
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: planetSize
                    )
                )
                .frame(width: planetSize * 2, height: planetSize * 2)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: planet.color.accent).opacity(0.9),
                                    Color(hex: planet.color.primary).opacity(0.5),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isSelected ? 4 : 2
                        )
                )
                .shadow(
                    color: Color(hex: planet.color.primary).opacity(isSelected ? 0.8 : 0.5),
                    radius: isSelected ? 15 : 8
                )
            
            // Halkalar (Satürn, Jüpiter, Uranüs, Neptün için)
            if planet.hasRings {
                ZStack {
                    // Dış halka
                    Ellipse()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: planet.color.accent).opacity(0.7),
                                    Color(hex: planet.color.secondary).opacity(0.4),
                                    Color(hex: planet.color.primary).opacity(0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: planetSize * 3, height: planetSize * 1.5)
                    
                    // İç halka
                    Ellipse()
                        .stroke(
                            Color(hex: planet.color.accent).opacity(0.5),
                            lineWidth: 1
                        )
                        .frame(width: planetSize * 2.5, height: planetSize * 1.2)
                }
                .rotationEffect(.degrees(planetRotation))
            }
        }
        .position(position)
        .scaleEffect(isSelected ? 1.3 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        .onAppear {
            withAnimation(.linear(duration: 8 / animationSpeed).repeatForever(autoreverses: false)) {
                planetRotation = 360
            }
        }
    }
}

struct PlanetCard: View {
    let planet: Planet
    let isSelected: Bool
    let index: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Gezegen İkonu
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: planet.color.primary),
                                Color(hex: planet.color.secondary)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color(hex: planet.color.primary).opacity(0.5), radius: 10)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                if planet.hasRings {
                    Ellipse()
                        .stroke(Color(hex: planet.color.accent).opacity(0.6), lineWidth: 2)
                        .frame(width: 70, height: 30)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                }
            }
            
            // Bilgiler
            VStack(alignment: .leading, spacing: 8) {
                Text(planet.turkishName)
                    .font(Theme.titleFont(size: 20))
                    .foregroundColor(Theme.stellarWhite)
                
                Text("\(String(format: "%.1f", planet.distanceFromSun)) milyon km")
                    .font(Theme.captionFont())
                    .foregroundColor(Theme.stellarWhite.opacity(0.6))
                
                HStack(spacing: 12) {
                    Label("\(planet.moons)", systemImage: "moon.fill")
                    Label("\(String(format: "%.0f", planet.diameter)) km", systemImage: "circle")
                }
                .font(Theme.captionFont(size: 11))
                .foregroundColor(Theme.nasaBlue.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.nasaBlue)
                .font(.system(size: 14))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color(hex: planet.color.primary) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(Double(index) * 0.1)) {
                isAnimating = true
            }
        }
    }
}

struct PlanetDetailSheet: View {
    let planet: Planet
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var selectedTab: Int = 0
    @State private var planetRotation: Double = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var parallaxOffset: CGFloat = 0
    
    let earth = Planet.planets.first(where: { $0.name == "Earth" })!
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Arka plan overlay
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }
                
                // Detay kartı
                VStack(spacing: 0) {
                    // Handle bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 50, height: 5)
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    
                    // Parallax Header
                    GeometryReader { scrollGeometry in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                // Parallax Header
                                ZStack {
                                    // Arka plan gradyanı
                                    LinearGradient(
                                        colors: [
                                            Color(hex: planet.color.primary).opacity(0.3),
                                            Color(hex: planet.color.secondary).opacity(0.2),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 280)
                                    .offset(y: parallaxOffset * 0.5)
                                    
                                    // 3D Animasyonlu Gezegen
                                    ZStack {
                                        // Gezegen glow efekti
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    colors: [
                                                        Color(hex: planet.color.primary).opacity(0.4),
                                                        Color.clear
                                                    ],
                                                    center: .center,
                                                    startRadius: 0,
                                                    endRadius: 120
                                                )
                                            )
                                            .frame(width: 240, height: 240)
                                            .blur(radius: 20)
                                        
                                        // Ana gezegen
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    colors: [
                                                        Color(hex: planet.color.primary),
                                                        Color(hex: planet.color.secondary),
                                                        Color(hex: planet.color.accent)
                                                    ],
                                                    center: UnitPoint(x: 0.3, y: 0.3),
                                                    startRadius: 0,
                                                    endRadius: 100
                                                )
                                            )
                                            .frame(width: 180, height: 180)
                                            .overlay(
                                                // Yüzey detayları
                                                Circle()
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [
                                                                Color.white.opacity(0.3),
                                                                Color(hex: planet.color.accent).opacity(0.2),
                                                                Color.clear
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 2
                                                    )
                                            )
                                            .shadow(color: Color(hex: planet.color.primary).opacity(0.8), radius: 40)
                                            .rotation3DEffect(
                                                .degrees(planetRotation),
                                                axis: (x: 0, y: 1, z: 0),
                                                perspective: 0.5
                                            )
                                        
                                        // Halkalar
                                        if planet.hasRings {
                                            ZStack {
                                                Ellipse()
                                                    .stroke(
                                                        LinearGradient(
                                                            colors: [
                                                                Color(hex: planet.color.accent).opacity(0.9),
                                                                Color(hex: planet.color.secondary).opacity(0.6),
                                                                Color(hex: planet.color.primary).opacity(0.3)
                                                            ],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        ),
                                                        lineWidth: 4
                                                    )
                                                    .frame(width: 240, height: 90)
                                                
                                                Ellipse()
                                                    .stroke(
                                                        Color(hex: planet.color.accent).opacity(0.5),
                                                        lineWidth: 2
                                                    )
                                                    .frame(width: 220, height: 80)
                                            }
                                            .rotation3DEffect(
                                                .degrees(planetRotation * 0.7),
                                                axis: (x: 0.5, y: 1, z: 0),
                                                perspective: 0.3
                                            )
                                        }
                                    }
                                    .offset(y: parallaxOffset * 0.3)
                                    
                                    // İsim ve açıklama
                                    VStack(spacing: 12) {
                                        Spacer()
                                        
                                        Text(planet.turkishName)
                                            .font(Theme.titleFont(size: 36))
                                            .foregroundColor(Theme.stellarWhite)
                                            .shadow(color: Color.black.opacity(0.5), radius: 5)
                                        
                                        Text(planet.name.uppercased())
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(hex: planet.color.accent))
                                            .tracking(3)
                                        
                                        Text(planet.description)
                                            .font(Theme.bodyFont(size: 15))
                                            .foregroundColor(Theme.stellarWhite.opacity(0.9))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 24)
                                            .padding(.top, 8)
                                    }
                                    .padding(.bottom, 40)
                                }
                                .frame(height: 280)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                                    }
                                )
                                
                                // Sekmeler
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        TabButton(title: "Genel", index: 0, selectedTab: $selectedTab, color: Color(hex: planet.color.primary))
                                        TabButton(title: "Karşılaştırma", index: 1, selectedTab: $selectedTab, color: Color(hex: planet.color.primary))
                                        TabButton(title: "Yörünge", index: 2, selectedTab: $selectedTab, color: Color(hex: planet.color.primary))
                                        TabButton(title: "Detaylar", index: 3, selectedTab: $selectedTab, color: Color(hex: planet.color.primary))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Theme.deepSpace)
                                    
                                    Divider()
                                        .background(Color(hex: planet.color.primary).opacity(0.3))
                                }
                                
                                // İçerik
                                VStack(spacing: 24) {
                                    switch selectedTab {
                                    case 0:
                                        GeneralTab(planet: planet)
                                    case 1:
                                        ComparisonTab(planet: planet, earth: earth)
                                    case 2:
                                        OrbitTab(planet: planet)
                                    case 3:
                                        DetailsTab(planet: planet)
                                    default:
                                        GeneralTab(planet: planet)
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 40)
                            }
                        }
                        .coordinateSpace(name: "scroll")
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            parallaxOffset = value
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.9)
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
                                withAnimation(.spring()) {
                                    isPresented = false
                                }
                            } else {
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                planetRotation = 360
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// Scroll offset preference key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Tab Button
struct TabButton: View {
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    let color: Color
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(Theme.bodyFont(size: 14, weight: selectedTab == index ? .semibold : .regular))
                    .foregroundColor(selectedTab == index ? color : Theme.stellarWhite.opacity(0.6))
                
                Rectangle()
                    .fill(color)
                    .frame(height: 3)
                    .cornerRadius(1.5)
                    .opacity(selectedTab == index ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Genel Sekme
struct GeneralTab: View {
    let planet: Planet
    
    var body: some View {
        VStack(spacing: 20) {
            // Hızlı İstatistikler
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                EnhancedStatCard(
                    icon: "arrow.right.circle.fill",
                    title: "Güneş'e Uzaklık",
                    value: "\(String(format: "%.1f", planet.distanceFromSun))",
                    unit: "milyon km",
                    color: Color(hex: planet.color.primary),
                    gradient: true
                )
                
                EnhancedStatCard(
                    icon: "circle.fill",
                    title: "Çap",
                    value: "\(String(format: "%.0f", planet.diameter))",
                    unit: "km",
                    color: Color(hex: planet.color.secondary),
                    gradient: true
                )
                
                EnhancedStatCard(
                    icon: "scalemass.fill",
                    title: "Kütle",
                    value: "\(String(format: "%.2f", planet.mass))",
                    unit: "Dünya",
                    color: Color(hex: planet.color.accent),
                    gradient: true
                )
                
                EnhancedStatCard(
                    icon: "clock.fill",
                    title: "Yörünge",
                    value: "\(String(format: "%.0f", planet.orbitalPeriod))",
                    unit: "gün",
                    color: Color(hex: planet.color.primary),
                    gradient: true
                )
                
                EnhancedStatCard(
                    icon: "sunrise.fill",
                    title: "Gün Süresi",
                    value: "\(String(format: "%.1f", planet.dayLength))",
                    unit: "saat",
                    color: Color(hex: planet.color.secondary),
                    gradient: true
                )
                
                EnhancedStatCard(
                    icon: "moon.fill",
                    title: "Uydu Sayısı",
                    value: "\(planet.moons)",
                    unit: planet.moons == 1 ? "uydu" : "uydu",
                    color: Color(hex: planet.color.accent),
                    gradient: true
                )
            }
            
            // Sıcaklık Grafiği
            TemperatureChart(planet: planet)
            
            // İlginç Bilgiler
            VStack(alignment: .leading, spacing: 12) {
                Text("İlginç Bilgiler")
                    .font(Theme.titleFont(size: 22))
                    .foregroundColor(Theme.stellarWhite)
                
                ForEach(Array(planet.facts.enumerated()), id: \.offset) { index, fact in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: planet.color.accent).opacity(0.2))
                                .frame(width: 28, height: 28)
                            
                            Text("\(index + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: planet.color.accent))
                        }
                        
                        Text(fact)
                            .font(Theme.bodyFont(size: 15))
                            .foregroundColor(Theme.stellarWhite.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: planet.color.primary).opacity(0.15),
                                        Color(hex: planet.color.secondary).opacity(0.08)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            }
        }
    }
}

// Karşılaştırma Sekmesi
struct ComparisonTab: View {
    let planet: Planet
    let earth: Planet
    
    var body: some View {
        VStack(spacing: 24) {
            // Dünya ile Karşılaştırma
            Text("Dünya ile Karşılaştırma")
                .font(Theme.titleFont(size: 22))
                .foregroundColor(Theme.stellarWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Boyut Karşılaştırması
            SizeComparisonView(planet: planet, earth: earth)
            
            // Kütle Karşılaştırması
            ComparisonBarChart(
                title: "Kütle Karşılaştırması",
                planetValue: planet.mass,
                earthValue: 1.0,
                planetLabel: planet.turkishName,
                earthLabel: "Dünya",
                color: Color(hex: planet.color.primary),
                unit: "Dünya Kütlesi"
            )
            
            // Sıcaklık Karşılaştırması
            ComparisonBarChart(
                title: "Ortalama Sıcaklık",
                planetValue: abs(planet.temperature.average),
                earthValue: abs(earth.temperature.average),
                planetLabel: planet.turkishName,
                earthLabel: "Dünya",
                color: Color(hex: planet.color.accent),
                unit: "°C"
            )
            
            // Yörünge Süresi Karşılaştırması
            ComparisonBarChart(
                title: "Yörünge Süresi",
                planetValue: planet.orbitalPeriod / 365.25,
                earthValue: 1.0,
                planetLabel: planet.turkishName,
                earthLabel: "Dünya",
                color: Color(hex: planet.color.secondary),
                unit: "Yıl"
            )
        }
    }
}

// Yörünge Sekmesi
struct OrbitTab: View {
    let planet: Planet
    @State private var animationPhase: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Yörünge Bilgileri")
                .font(Theme.titleFont(size: 22))
                .foregroundColor(Theme.stellarWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Yörünge Animasyonu
            OrbitAnimationView(planet: planet)
                .frame(height: 250)
            
            // Yörünge Detayları
            VStack(spacing: 16) {
                OrbitDetailRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Yörünge Süresi",
                    value: "\(String(format: "%.0f", planet.orbitalPeriod)) Dünya günü",
                    subtitle: "\(String(format: "%.2f", planet.orbitalPeriod / 365.25)) Dünya yılı",
                    color: Color(hex: planet.color.primary)
                )
                
                OrbitDetailRow(
                    icon: "speedometer",
                    title: "Ortalama Hız",
                    value: "\(String(format: "%.1f", calculateOrbitalSpeed(planet))) km/s",
                    subtitle: "Yörüngede hareket hızı",
                    color: Color(hex: planet.color.secondary)
                )
                
                OrbitDetailRow(
                    icon: "arrow.up.arrow.down",
                    title: "Gün Süresi",
                    value: "\(String(format: "%.1f", planet.dayLength)) saat",
                    subtitle: "Kendi ekseninde bir dönüş",
                    color: Color(hex: planet.color.accent)
                )
                
                OrbitDetailRow(
                    icon: "arrow.triangle.branch",
                    title: "Yörünge Mesafesi",
                    value: "\(String(format: "%.1f", planet.distanceFromSun)) milyon km",
                    subtitle: "Güneş'e olan uzaklık",
                    color: Color(hex: planet.color.primary)
                )
            }
        }
    }
    
    private func calculateOrbitalSpeed(_ planet: Planet) -> Double {
        // Basit yörünge hızı hesaplaması (km/s)
        let distanceInKm = planet.distanceFromSun * 1_000_000
        let circumference = 2 * Double.pi * distanceInKm
        let periodInSeconds = planet.orbitalPeriod * 24 * 3600
        return circumference / periodInSeconds
    }
}

// Detaylar Sekmesi
struct DetailsTab: View {
    let planet: Planet
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Detaylı Bilgiler")
                .font(Theme.titleFont(size: 22))
                .foregroundColor(Theme.stellarWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Sıcaklık Detayları
            TemperatureDetailCard(planet: planet)
            
            // Gezegen Özellikleri
            VStack(spacing: 12) {
                DetailRow(label: "Gezegen Tipi", value: getPlanetType(planet), color: Color(hex: planet.color.primary))
                DetailRow(label: "Halka Durumu", value: planet.hasRings ? "Halkalı" : "Halkasız", color: Color(hex: planet.color.secondary))
                DetailRow(label: "Uydu Sayısı", value: "\(planet.moons)", color: Color(hex: planet.color.accent))
                DetailRow(label: "Çap", value: "\(String(format: "%.0f", planet.diameter)) km", color: Color(hex: planet.color.primary))
                DetailRow(label: "Kütle", value: "\(String(format: "%.3f", planet.mass)) Dünya kütlesi", color: Color(hex: planet.color.secondary))
            }
        }
    }
    
    private func getPlanetType(_ planet: Planet) -> String {
        switch planet.name {
        case "Mercury", "Venus", "Earth", "Mars":
            return "Kayalık Gezegen"
        case "Jupiter", "Saturn":
            return "Gaz Devi"
        case "Uranus", "Neptune":
            return "Buz Devi"
        default:
            return "Gezegen"
        }
    }
}


// Enhanced Stat Card
struct EnhancedStatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    let gradient: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(value)
                .font(Theme.titleFont(size: 24))
                .foregroundColor(Theme.stellarWhite)
            
            Text(unit)
                .font(Theme.captionFont(size: 10))
                .foregroundColor(Theme.stellarWhite.opacity(0.6))
            
            Text(title)
                .font(Theme.captionFont(size: 11))
                .foregroundColor(color.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
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

// Temperature Chart
struct TemperatureChart: View {
    let planet: Planet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sıcaklık Aralığı")
                .font(Theme.titleFont(size: 22))
                .foregroundColor(Theme.stellarWhite)
            
            VStack(spacing: 12) {
                // Min
                HStack {
                    Text("Min")
                        .font(Theme.captionFont())
                        .foregroundColor(Theme.stellarWhite.opacity(0.7))
                        .frame(width: 50, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Theme.deepSpace)
                                .frame(height: 24)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.7),
                                            Color.cyan.opacity(0.5)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: calculateWidth(for: planet.temperature.min, in: geometry.size.width), height: 24)
                        }
                    }
                    .frame(height: 24)
                    
                    Text("\(String(format: "%.0f", planet.temperature.min))°C")
                        .font(Theme.captionFont(size: 12))
                        .foregroundColor(Theme.stellarWhite)
                        .frame(width: 60, alignment: .trailing)
                }
                
                // Average
                HStack {
                    Text("Ort")
                        .font(Theme.captionFont())
                        .foregroundColor(Theme.stellarWhite.opacity(0.7))
                        .frame(width: 50, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Theme.deepSpace)
                                .frame(height: 24)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: planet.color.accent).opacity(0.8),
                                            Color(hex: planet.color.primary).opacity(0.6)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: calculateWidth(for: planet.temperature.average, in: geometry.size.width), height: 24)
                        }
                    }
                    .frame(height: 24)
                    
                    Text("\(String(format: "%.0f", planet.temperature.average))°C")
                        .font(Theme.captionFont(size: 12))
                        .foregroundColor(Theme.stellarWhite)
                        .frame(width: 60, alignment: .trailing)
                }
                
                // Max
                HStack {
                    Text("Max")
                        .font(Theme.captionFont())
                        .foregroundColor(Theme.stellarWhite.opacity(0.7))
                        .frame(width: 50, alignment: .leading)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Theme.deepSpace)
                                .frame(height: 24)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.red.opacity(0.8),
                                            Color.orange.opacity(0.6)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: calculateWidth(for: planet.temperature.max, in: geometry.size.width), height: 24)
                        }
                    }
                    .frame(height: 24)
                    
                    Text("\(String(format: "%.0f", planet.temperature.max))°C")
                        .font(Theme.captionFont(size: 12))
                        .foregroundColor(Theme.stellarWhite)
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: planet.color.primary).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func calculateWidth(for temperature: Double, in maxWidth: CGFloat) -> CGFloat {
        // Normalize temperature to 0-1 range (assuming -250 to 500 range)
        let minTemp: Double = -250
        let maxTemp: Double = 500
        let normalized = (temperature - minTemp) / (maxTemp - minTemp)
        return maxWidth * CGFloat(max(0, min(1, normalized)))
    }
}

// Size Comparison View
struct SizeComparisonView: View {
    let planet: Planet
    let earth: Planet
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Boyut Karşılaştırması")
                .font(Theme.titleFont(size: 18))
                .foregroundColor(Theme.stellarWhite)
            
            HStack(spacing: 20) {
                // Earth
                VStack(spacing: 8) {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: earth.color.primary),
                                    Color(hex: earth.color.secondary)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: earth.color.primary).opacity(0.5), radius: 10)
                    
                    Text("Dünya")
                        .font(Theme.captionFont())
                        .foregroundColor(Theme.stellarWhite.opacity(0.8))
                    
                    Text("1x")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: earth.color.accent))
                }
                
                // VS
                Text("VS")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.stellarWhite.opacity(0.5))
                
                // Planet
                VStack(spacing: 8) {
                    let scale = min(1.5, max(0.3, planet.diameter / earth.diameter))
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: planet.color.primary),
                                    Color(hex: planet.color.secondary)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80 * scale, height: 80 * scale)
                        .shadow(color: Color(hex: planet.color.primary).opacity(0.5), radius: 10)
                    
                    Text(planet.turkishName)
                        .font(Theme.captionFont())
                        .foregroundColor(Theme.stellarWhite.opacity(0.8))
                    
                    Text("\(String(format: "%.2f", planet.diameter / earth.diameter))x")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: planet.color.accent))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: planet.color.primary).opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// Comparison Bar Chart
struct ComparisonBarChart: View {
    let title: String
    let planetValue: Double
    let earthValue: Double
    let planetLabel: String
    let earthLabel: String
    let color: Color
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.titleFont(size: 18))
                .foregroundColor(Theme.stellarWhite)
            
            VStack(spacing: 16) {
                // Earth bar
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(earthLabel)
                            .font(Theme.captionFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.8))
                        Spacer()
                        Text("\(String(format: "%.2f", earthValue)) \(unit)")
                            .font(Theme.captionFont(size: 11))
                            .foregroundColor(Theme.stellarWhite.opacity(0.6))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Theme.deepSpace)
                                .frame(height: 28)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.6))
                                .frame(width: geometry.size.width * 0.5, height: 28)
                        }
                    }
                    .frame(height: 28)
                }
                
                // Planet bar
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(planetLabel)
                            .font(Theme.captionFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.8))
                        Spacer()
                        Text("\(String(format: "%.2f", planetValue)) \(unit)")
                            .font(Theme.captionFont(size: 11))
                            .foregroundColor(Theme.stellarWhite.opacity(0.6))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Theme.deepSpace)
                                .frame(height: 28)
                            
                            let maxValue = max(planetValue, earthValue)
                            let width = maxValue > 0 ? min(1.0, planetValue / maxValue) : 0.5
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            color.opacity(0.8),
                                            color.opacity(0.6)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(width), height: 28)
                        }
                    }
                    .frame(height: 28)
                }
            }
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

// Orbit Animation View
struct OrbitAnimationView: View {
    let planet: Planet
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Güneş
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.yellow.opacity(0.9),
                            Color.orange.opacity(0.7)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)
                .shadow(color: .yellow.opacity(0.6), radius: 15)
            
            // Yörünge çizgisi
            Circle()
                .stroke(
                    Color(hex: planet.color.primary).opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [5, 5])
                )
                .frame(width: 200, height: 200)
            
            // Gezegen
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: planet.color.primary),
                            Color(hex: planet.color.secondary)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 15
                    )
                )
                .frame(width: 30, height: 30)
                .offset(x: 100)
                .rotationEffect(.degrees(rotation))
                .shadow(color: Color(hex: planet.color.primary).opacity(0.5), radius: 8)
        }
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// Orbit Detail Row
struct OrbitDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.captionFont())
                    .foregroundColor(Theme.stellarWhite.opacity(0.7))
                
                Text(value)
                    .font(Theme.bodyFont(size: 16, weight: .semibold))
                    .foregroundColor(Theme.stellarWhite)
                
                Text(subtitle)
                    .font(Theme.captionFont(size: 11))
                    .foregroundColor(Theme.stellarWhite.opacity(0.5))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// Temperature Detail Card
struct TemperatureDetailCard: View {
    let planet: Planet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "thermometer")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: planet.color.accent))
                
                Text("Sıcaklık Detayları")
                    .font(Theme.titleFont(size: 18))
                    .foregroundColor(Theme.stellarWhite)
            }
            
            VStack(spacing: 12) {
                TemperatureRow(label: "Minimum", value: planet.temperature.min, color: .blue)
                TemperatureRow(label: "Ortalama", value: planet.temperature.average, color: Color(hex: planet.color.accent))
                TemperatureRow(label: "Maksimum", value: planet.temperature.max, color: .red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: planet.color.primary).opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// Temperature Row
struct TemperatureRow: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.captionFont())
                .foregroundColor(Theme.stellarWhite.opacity(0.7))
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            Text("\(String(format: "%.1f", value))°C")
                .font(Theme.bodyFont(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.bodyFont(size: 15))
                .foregroundColor(Theme.stellarWhite.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(Theme.bodyFont(size: 15, weight: .semibold))
                .foregroundColor(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.deepSpace)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    PlanetsView()
}

