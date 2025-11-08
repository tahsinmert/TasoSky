//
//  EPICView.swift
//  TasoSky
//
//  Created by Tahsin Mert Mutlu on 08.11.2025.
//

import SwiftUI
import Combine

struct EPICView: View {
    @StateObject private var viewModel = EPICViewModel()
    @State private var selectedDate: Date = Date()
    @State private var showingDatePicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dünya'dan Uzay")
                            .font(Theme.titleFont(size: 28))
                            .foregroundColor(Theme.stellarWhite)
                            Text("EPIC - Earth Polychromatic Imaging Camera")
                                .font(Theme.captionFont())
                                .foregroundColor(Theme.stellarWhite.opacity(0.6))
                        }
                        Spacer()
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.nasaBlue)
                    }
                    
                    // Tarih Seçici
                    Button(action: {
                        showingDatePicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Theme.nasaBlue)
                            Text(formatDate(selectedDate))
                                .font(Theme.bodyFont(size: 16))
                                .foregroundColor(Theme.stellarWhite)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(Theme.stellarWhite.opacity(0.5))
                                .font(.system(size: 12))
                        }
                        .padding()
                        .background(Theme.deepSpace)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.nasaBlue.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .sheet(isPresented: $showingDatePicker) {
                        DatePickerSheet(
                            selectedDate: $selectedDate,
                            availableDates: viewModel.availableDates,
                            onDateSelected: { date in
                                selectedDate = date
                                showingDatePicker = false
                                Task {
                                    await viewModel.fetchImages(for: dateString(from: date))
                                }
                            }
                        )
                    }
                }
                .padding()
                .padding(.top, 8)
                .background(Theme.spaceBlack)
                
                // İçerik
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.nasaBlue))
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
                        Text(error.localizedDescription)
                            .font(Theme.bodyFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Yeniden Dene") {
                            Task {
                                await viewModel.fetchImages(for: dateString(from: selectedDate))
                            }
                        }
                        .buttonStyle(NASAPrimaryButtonStyle())
                    }
                    .padding(.top, 100)
                } else if viewModel.images.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "globe")
                            .font(.system(size: 50))
                            .foregroundColor(Theme.nasaBlue)
                        Text("Bu tarih için görüntü bulunamadı")
                            .font(Theme.bodyFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.7))
                        Text("Farklı bir tarih seçin")
                            .font(Theme.captionFont())
                            .foregroundColor(Theme.stellarWhite.opacity(0.5))
                    }
                    .padding(.top, 100)
                } else {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.images) { epicImage in
                            NavigationLink(destination: EPICDetailView(image: epicImage)) {
                                EPICImageCard(image: epicImage)
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
            await viewModel.fetchAvailableDates()
            await viewModel.fetchImages(for: dateString(from: selectedDate))
        }
        .refreshable {
            await viewModel.fetchImages(for: dateString(from: selectedDate))
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
}

struct EPICImageCard: View {
    let image: EPICImage
    
    var body: some View {
        VStack(spacing: 0) {
            RemoteImage(url: URL(string: image.imageURL))
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(image.caption)
                    .font(Theme.titleFont(size: 18))
                    .foregroundColor(Theme.stellarWhite)
                    .lineLimit(2)
                
                HStack {
                    Label(formatTime(image.date), systemImage: "clock")
                        .font(Theme.captionFont())
                        .foregroundColor(Theme.stellarWhite.opacity(0.6))
                    
                    Spacer()
                    
                    if let centroid = image.centroid {
                        Label("\(String(format: "%.1f", centroid.lat))°, \(String(format: "%.1f", centroid.lon))°", systemImage: "location")
                            .font(Theme.captionFont(size: 10))
                            .foregroundColor(Theme.nasaBlue.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Theme.deepSpace)
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.nasaBlue.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatTime(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"
        outputFormatter.locale = Locale(identifier: "tr_TR")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

struct EPICDetailView: View {
    let image: EPICImage
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                RemoteImage(url: URL(string: image.imageURL))
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(image.caption)
                        .font(Theme.titleFont(size: 24))
                        .foregroundColor(Theme.stellarWhite)
                    
                    Divider()
                        .background(Theme.nasaBlue.opacity(0.3))
                    
                    InfoRow(icon: "calendar", label: "Tarih", value: formatDate(image.date))
                    InfoRow(icon: "clock", label: "Saat", value: formatTime(image.date))
                    
                    if let centroid = image.centroid {
                        InfoRow(icon: "location", label: "Koordinatlar", value: "\(String(format: "%.2f", centroid.lat))° N, \(String(format: "%.2f", centroid.lon))° E")
                    }
                    
                    if let sunPosition = image.sunJ2000Position {
                        InfoRow(icon: "sun.max", label: "Güneş Konumu", value: "X: \(String(format: "%.2f", sunPosition.x)), Y: \(String(format: "%.2f", sunPosition.y)), Z: \(String(format: "%.2f", sunPosition.z))")
                    }
                }
                .padding()
            }
        }
        .background(Theme.spaceBlack)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "d MMMM yyyy"
        outputFormatter.locale = Locale(identifier: "tr_TR")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    private func formatTime(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm:ss"
        outputFormatter.locale = Locale(identifier: "tr_TR")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let availableDates: [String]
    let onDateSelected: (Date) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Tarih Seç")
                    .font(Theme.titleFont(size: 24))
                    .foregroundColor(Theme.stellarWhite)
                    .padding(.top)
                
                if availableDates.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.nasaBlue))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(availableDates.prefix(30), id: \.self) { availableDateString in
                                Button(action: {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd"
                                    if let date = formatter.date(from: availableDateString) {
                                        onDateSelected(date)
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(formatDate(availableDateString))
                                                .font(Theme.bodyFont())
                                                .foregroundColor(Theme.stellarWhite)
                                            Text(availableDateString)
                                                .font(Theme.captionFont())
                                                .foregroundColor(Theme.stellarWhite.opacity(0.5))
                                        }
                                        Spacer()
                                        if availableDateString == dateString(from: selectedDate) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Theme.nasaBlue)
                                        }
                                    }
                                    .padding()
                                    .background(Theme.deepSpace)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .background(Theme.spaceBlack)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(Theme.nasaBlue)
                }
            }
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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


class EPICViewModel: ObservableObject {
    @Published var images: [EPICImage] = []
    @Published var availableDates: [String] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetchAvailableDates() async {
        do {
            let dates = try await NASAAPIService.shared.fetchEPICAvailableDates()
            await MainActor.run {
                self.availableDates = dates
            }
        } catch {
            print("⚠️ Available dates fetch error: \(error.localizedDescription)")
        }
    }
    
    func fetchImages(for date: String) async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            print("🔄 EPIC images çekiliyor: \(date)")
            let images = try await NASAAPIService.shared.fetchEPICImages(date: date)
            await MainActor.run {
                self.images = images
                self.isLoading = false
                print("✅ \(images.count) görüntü yüklendi")
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
                print("❌ EPIC images error: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    EPICView()
}

