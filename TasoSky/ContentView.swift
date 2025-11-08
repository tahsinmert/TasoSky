//
//  ContentView.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PlanetsView()
                .tabItem {
                    Label("Gezegenler", systemImage: "globe.americas")
                }
                .tag(0)
            
            NEOView()
                .tabItem {
                    Label("Asteroitler", systemImage: "globe")
                }
                .tag(1)
            
            MarsWeatherView()
                .tabItem {
                    Label("Mars", systemImage: "globe.asia.australia.fill")
                }
                .tag(2)
        }
        .accentColor(Theme.nasaBlue)
        .onAppear {
            // Tab bar'ın görünümünü özelleştir
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Theme.spaceBlack)
            appearance.shadowColor = .clear
            
            // Seçili tab rengi
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.nasaBlue)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.nasaBlue)]
            
            // Seçili olmayan tab rengi
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Theme.stellarWhite.opacity(0.5))
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.stellarWhite.opacity(0.5))]
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    ContentView()
}
