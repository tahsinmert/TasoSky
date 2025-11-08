//
//  MarsRoverPhotosView.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI
import Combine

struct MarsRoverPhotosView: View {
    @StateObject private var viewModel = MarsRoverPhotosViewModel()
    @State private var selectedRover = "curiosity"
    @State private var selectedSol = 1000
    @State private var isInitialLoad = true
    
    let rovers = ["curiosity", "perseverance", "opportunity", "spirit"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mars Rover Fotoğrafları")
                            .font(Theme.titleFont(size: 28))
                            .foregroundColor(Theme.stellarWhite)
                        Text("Kızıl Gezegenden Görüntüler")
                            .font(Theme.captionFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.6))
                    }
                    Spacer()
                }
                .padding()
                .padding(.top, 8)
                .background(Theme.spaceBlack)
                
                // Rover ve Sol Seçici
                VStack(spacing: 16) {
                    // Rover Seçici
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rover")
                            .font(Theme.bodyFont(size: 14))
                            .foregroundColor(Theme.stellarWhite.opacity(0.7))
                        
                        Picker("Rover", selection: $selectedRover) {
                            ForEach(rovers, id: \.self) { rover in
                                Text(rover.capitalized).tag(rover)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedRover) {
                            Task {
                                await viewModel.fetchPhotos(rover: selectedRover, sol: selectedSol)
                            }
                        }
                    }
                    
                    // Sol Seçici
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mars Günü (Sol): \(selectedSol)")
                            .font(Theme.bodyFont(size: 14))
                            .foregroundColor(Theme.stellarWhite.opacity(0.7))
                        
                        HStack {
                            Button(action: {
                                if selectedSol > 0 {
                                    selectedSol -= 10
                                    Task {
                                        await viewModel.fetchPhotos(rover: selectedRover, sol: selectedSol)
                                    }
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.nasaBlue)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(selectedSol) },
                                set: { newValue in
                                    selectedSol = Int(newValue)
                                }
                            ), in: 0...4000, step: 10)
                            .accentColor(Theme.nasaBlue)
                            .onChange(of: selectedSol) {
                                // Slider değiştiğinde API çağrısı yap
                                Task {
                                    await viewModel.fetchPhotos(rover: selectedRover, sol: selectedSol)
                                }
                            }
                            
                            Button(action: {
                                if selectedSol < 4000 {
                                    selectedSol += 10
                                    Task {
                                        await viewModel.fetchPhotos(rover: selectedRover, sol: selectedSol)
                                    }
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(Theme.nasaBlue)
                            }
                        }
                    }
                }
                .padding()
                .background(Theme.deepSpace)
                
                // Fotoğraflar
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.nasaRed))
                        .scaleEffect(1.5)
                        .padding(.top, 100)
                } else if let error = viewModel.error {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(Theme.nasaRed)
                        Text("Hata")
                            .font(Theme.titleFont(size: 20))
                            .foregroundColor(Theme.stellarWhite)
                            Text(formatErrorMessage(error.localizedDescription))
                            .font(Theme.bodyFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Yeniden Dene") {
                            Task {
                                await viewModel.fetchPhotos(rover: selectedRover, sol: selectedSol)
                            }
                        }
                        .buttonStyle(NASAPrimaryButtonStyle())
                    }
                    .padding(.top, 100)
                } else if viewModel.photos.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "camera")
                            .font(.system(size: 50))
                            .foregroundColor(Theme.nasaRed)
                        Text("Fotoğraf Bulunamadı")
                            .font(Theme.titleFont(size: 20))
                            .foregroundColor(Theme.stellarWhite)
                        Text("Bu sol (\(selectedSol)) için \(selectedRover.capitalized) rover'ından fotoğraf bulunamadı.")
                            .font(Theme.bodyFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Text("Farklı bir sol numarası veya rover deneyin")
                            .font(Theme.captionFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.5))
                            .padding(.horizontal)
                        
                        Button("Popüler Sol'ları Dene") {
                            // Popüler sol numaralarını dene
                            let popularSols = [100, 500, 1000, 1500, 2000, 2500, 3000]
                            if let randomSol = popularSols.randomElement() {
                                selectedSol = randomSol
                                Task {
                                    await viewModel.fetchPhotos(rover: selectedRover, sol: selectedSol)
                                }
                            }
                        }
                        .buttonStyle(NASAPrimaryButtonStyle())
                    }
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(viewModel.photos.prefix(20)) { photo in
                            NavigationLink(destination: MarsRoverPhotoDetailView(photo: photo)) {
                                MarsRoverPhotoCard(photo: photo)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Theme.spaceBlack)
        .task {
            if isInitialLoad {
                isInitialLoad = false
                // İlk yüklemede popüler bir sol kullan
                selectedSol = 1000
                await viewModel.fetchPhotos(rover: selectedRover, sol: selectedSol)
            }
        }
        .refreshable {
            await viewModel.fetchPhotos(rover: selectedRover, sol: selectedSol)
        }
    }
    
    private func formatErrorMessage(_ error: String) -> String {
        // HTML içeriğini temizle
        if error.contains("<!DOCTYPE") || error.contains("<html") {
            return "Sunucu hatası. Lütfen daha sonra tekrar deneyin."
        }
        
        // HTTP 404 için özel mesaj
        if error.contains("404") {
            return "Bu sol için fotoğraf bulunamadı. Farklı bir sol numarası deneyin."
        }
        
        // Çok uzun hata mesajlarını kısalt
        if error.count > 200 {
            return String(error.prefix(200)) + "..."
        }
        
        return error
    }
}

struct MarsRoverPhotoCard: View {
    let photo: MarsRoverPhoto
    
    var body: some View {
        VStack(spacing: 0) {
            RemoteImage(url: URL(string: photo.imgSrc))
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(photo.camera.fullName)
                    .font(Theme.captionFont(size: 11))
                    .foregroundColor(Theme.stellarWhite.opacity(0.8))
                    .lineLimit(1)
                
                Text("Sol \(photo.sol)")
                    .font(Theme.captionFont(size: 10))
                    .foregroundColor(Theme.stellarWhite.opacity(0.5))
                
                Text(formatDate(photo.earthDate))
                    .font(Theme.captionFont(size: 9))
                    .foregroundColor(Theme.nasaRed.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Theme.deepSpace)
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.nasaRed.opacity(0.3), lineWidth: 1)
        )
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
}

struct MarsRoverPhotoDetailView: View {
    let photo: MarsRoverPhoto
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                RemoteImage(url: URL(string: photo.imgSrc))
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(photo.camera.fullName)
                        .font(Theme.titleFont(size: 24))
                        .foregroundColor(Theme.stellarWhite)
                    
                    HStack {
                        InfoBadge(icon: "camera", text: photo.camera.name.uppercased(), color: Theme.nasaBlue)
                        InfoBadge(icon: "globe", text: photo.rover.name.capitalized, color: Theme.nasaRed)
                    }
                    
                    Divider()
                        .background(Theme.nasaBlue.opacity(0.3))
                    
                    InfoRow(icon: "calendar", label: "Mars Günü (Sol)", value: "\(photo.sol)")
                    InfoRow(icon: "calendar.badge.clock", label: "Dünya Tarihi", value: formatDate(photo.earthDate))
                    InfoRow(icon: "checkmark.circle", label: "Rover Durumu", value: photo.rover.status.capitalized)
                    InfoRow(icon: "arrow.down.circle", label: "İniş Tarihi", value: formatDate(photo.rover.landingDate))
                    InfoRow(icon: "rocket", label: "Fırlatma Tarihi", value: formatDate(photo.rover.launchDate))
                }
                .padding()
            }
        }
        .background(Theme.spaceBlack)
        .navigationBarTitleDisplayMode(.inline)
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
}

struct InfoBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(Theme.captionFont(size: 12))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}

class MarsRoverPhotosViewModel: ObservableObject {
    @Published var photos: [MarsRoverPhoto] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetchPhotos(rover: String, sol: Int) async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            print("🔄 Mars Rover photos çekiliyor: \(rover), Sol: \(sol)")
            let response = try await NASAAPIService.shared.fetchMarsRoverPhotos(rover: rover, sol: sol)
            await MainActor.run {
                self.photos = response.photos
                self.isLoading = false
                print("✅ \(response.photos.count) fotoğraf yüklendi")
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
                print("❌ Mars Rover photos error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    MarsRoverPhotosView()
}

