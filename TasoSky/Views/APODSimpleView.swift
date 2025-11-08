//
//  APODSimpleView.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI
import Combine

struct APODSimpleView: View {
    @StateObject private var viewModel = APODSimpleViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Günün Uzay Görseli")
                                .font(Theme.titleFont(size: 28))
                                .foregroundColor(Theme.stellarWhite)
                            Text("Astronomy Picture of the Day")
                                .font(Theme.captionFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.6))
                        }
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.nasaBlue)
                    }
                }
                .padding()
                .padding(.top, 8)
                .background(Theme.spaceBlack)
                
                // İçerik
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.nasaBlue))
                            .scaleEffect(1.5)
                        Text("Yükleniyor...")
                            .font(Theme.bodyFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if let error = viewModel.error {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(Theme.nasaRed)
                        Text("Hata")
                            .font(Theme.titleFont(size: 20))
                            .foregroundColor(Theme.stellarWhite)
                        Text(error)
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if let apod = viewModel.apod {
                    // Görsel
                    if apod.mediaType == "image" {
                        VStack(spacing: 0) {
                            RemoteImage(url: URL(string: apod.url))
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 400)
                                .clipped()
                            
                            VStack(alignment: .leading, spacing: 20) {
                                // Başlık
                                Text(apod.title)
                                    .font(Theme.titleFont(size: 24))
                                    .foregroundColor(Theme.stellarWhite)
                                
                                // Tarih
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(Theme.nasaBlue)
                                    Text(formatDate(apod.date))
                                        .font(Theme.captionFont())
                                        .foregroundColor(Theme.stellarWhite.opacity(0.7))
                                }
                                
                                Divider()
                                    .background(Theme.nasaBlue.opacity(0.3))
                                
                                // Açıklama
                                Text(apod.explanation)
                                    .font(Theme.bodyFont())
                                    .foregroundColor(Theme.stellarWhite.opacity(0.9))
                                    .lineSpacing(6)
                            }
                            .padding()
                            .background(Theme.spaceBlack)
                        }
                    } else {
                        // Video için
                        VStack(spacing: 20) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.nasaBlue)
                            Text("Video İçeriği")
                                .font(Theme.titleFont(size: 20))
                                .foregroundColor(Theme.stellarWhite)
                            Text(apod.title)
                                .font(Theme.bodyFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            if let url = URL(string: apod.url) {
                                Link(destination: url) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("Videoyu İzle")
                                    }
                                    .font(Theme.bodyFont(size: 16))
                                    .foregroundColor(Theme.stellarWhite)
                                    .padding()
                                    .background(Theme.nasaBlue)
                                    .cornerRadius(12)
                                }
                            }
                            
                            Text(apod.explanation)
                                .font(Theme.bodyFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.9))
                                .lineSpacing(6)
                                .padding()
                        }
                        .padding()
                        .background(Theme.spaceBlack)
                    }
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

class APODSimpleViewModel: ObservableObject {
    @Published var apod: APOD?
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchAPOD() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let apod = try await NASAAPIService.shared.fetchAPOD()
            await MainActor.run {
                self.apod = apod
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Veri yüklenirken bir hata oluştu. Lütfen tekrar deneyin."
                self.isLoading = false
            }
        }
    }
}

#Preview {
    APODSimpleView()
}

