//
//  RemoteImage.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI

struct RemoteImage: View {
    let url: URL?
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var error: Error?
    
    var body: some View {
        ZStack {
            Theme.spaceBlack
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.nasaBlue))
                    .scaleEffect(1.5)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.nasaBlue)
                    Text("Görsel yüklenemedi")
                        .font(Theme.bodyFont())
                        .foregroundColor(Theme.stellarWhite.opacity(0.7))
                    if let error = error {
                        Text(error.localizedDescription)
                            .font(Theme.captionFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.5))
                            .padding(.horizontal)
                    }
                }
            }
        }
        .task {
            await loadImage()
        }
        .onChange(of: url) {
            Task {
                await loadImage()
            }
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            print("❌ RemoteImage: Geçersiz URL")
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        print("🖼️ Görsel yükleniyor: \(url.absoluteString)")
        
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Görsel HTTP Status: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NSError(domain: "RemoteImage", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
                }
            }
            
            guard let uiImage = UIImage(data: data) else {
                print("❌ Görsel verisi UIImage'e dönüştürülemedi. Data size: \(data.count) bytes")
                throw NSError(domain: "RemoteImage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
            }
            
            print("✅ Görsel başarıyla yüklendi: \(url.lastPathComponent)")
            await MainActor.run {
                self.image = uiImage
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
                print("❌ Görsel yükleme hatası: \(error.localizedDescription)")
            }
        }
    }
}

