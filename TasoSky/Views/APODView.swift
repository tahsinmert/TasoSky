//
//  APODView.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI
import Combine

struct APODView: View {
    @StateObject private var viewModel = APODViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Günün Görseli")
                            .font(Theme.titleFont(size: 28))
                            .foregroundColor(Theme.stellarWhite)
                        Text("Astronomy Picture of the Day")
                            .font(Theme.captionFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.6))
                    }
                    Spacer()
                }
                .padding()
                .padding(.top, 8)
                .background(Theme.spaceBlack)
                
                if let apod = viewModel.apod {
                    // Görsel veya Video
                    if apod.mediaType == "image" {
                        let imageURLString = apod.hdurl ?? apod.url
                        let imageURL = URL(string: imageURLString)
                        
                        RemoteImage(url: imageURL)
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 400)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [Color.clear, Theme.spaceBlack.opacity(0.8)],
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                            )
                    } else {
                        // Video için placeholder
                        VStack(spacing: 16) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.nasaBlue)
                            Text("Video içeriği")
                                .font(Theme.bodyFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.7))
                            Link("YouTube'da İzle", destination: URL(string: apod.url)!)
                                .font(Theme.bodyFont(size: 14))
                                .foregroundColor(Theme.nasaBlue)
                        }
                        .frame(height: 400)
                        .frame(maxWidth: .infinity)
                        .background(Theme.spaceBlack)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Başlık
                        Text(apod.title)
                            .font(Theme.titleFont(size: 24))
                            .foregroundColor(Theme.stellarWhite)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Tarih
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Theme.nasaBlue)
                            Text(formatDate(apod.date))
                                .font(Theme.captionFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.7))
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .background(Theme.nasaBlue.opacity(0.3))
                            .padding(.horizontal)
                        
                        // Açıklama
                        Text(apod.explanation)
                            .font(Theme.bodyFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.9))
                            .lineSpacing(6)
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                    }
                    .background(Theme.spaceBlack)
                } else {
                    // Loading veya Error durumu
                    VStack(spacing: 20) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Theme.nasaBlue))
                                .scaleEffect(1.5)
                            Text("Yükleniyor...")
                                .font(Theme.bodyFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.7))
                        } else if let error = viewModel.error {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(Theme.nasaRed)
                            Text("Hata")
                                .font(Theme.titleFont(size: 20))
                                .foregroundColor(Theme.stellarWhite)
                            Text(error.localizedDescription)
                                .font(Theme.bodyFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Yeniden Dene") {
                                Task {
                                    await viewModel.fetchAPOD()
                                }
                            }
                            .buttonStyle(NASAPrimaryButtonStyle())
                        } else {
                            // İlk yükleme
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Theme.nasaBlue))
                                .scaleEffect(1.5)
                            Text("Yükleniyor...")
                                .font(Theme.bodyFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                }
            }
        }
        .background(Theme.spaceBlack)
        .task {
            await viewModel.fetchAPOD()
        }
        .refreshable {
            await viewModel.fetchAPOD()
        }
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

class APODViewModel: ObservableObject {
    @Published var apod: APOD?
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetchAPOD() async {
        await MainActor.run {
            isLoading = true
            error = nil
            apod = nil
        }
        
        do {
            print("🔄 APOD verisi çekiliyor...")
            let apod = try await NASAAPIService.shared.fetchAPOD()
            print("✅ APOD verisi alındı: \(apod.title)")
            print("📸 Görsel URL: \(apod.hdurl ?? apod.url)")
            print("🎬 Media Type: \(apod.mediaType)")
            
            await MainActor.run {
                self.apod = apod
                self.isLoading = false
                self.error = nil
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
                print("❌ APOD fetch error: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    print("📋 Decoding error details: \(decodingError)")
                }
            }
        }
    }
}

struct NASAPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Theme.nasaBlue)
            .foregroundColor(Theme.stellarWhite)
            .font(Theme.bodyFont(size: 16))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    APODView()
}

