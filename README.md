<div align="center">

![TasoSky Logo](tasosky-logo.png)

# 🌌 TasoSky

**Uzayın Derinliklerini Keşfedin**

Modern, şık ve bilgilendirici bir NASA uzay keşif uygulaması

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-26.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![NASA API](https://img.shields.io/badge/NASA-API-red.svg)](https://api.nasa.gov)

[Özellikler](#-özellikler) • [Kurulum](#-kurulum) • [Kullanım](#-kullanım) • [Ekran Görüntüleri](#-ekran-görüntüleri) • [Katkıda Bulunma](#-katkıda-bulunma) • [Lisans](#-lisans)

</div>

---

## 📖 Hakkında

**TasoSky**, NASA API'sini kullanarak uzay hakkında bilgi sunan modern bir iOS uygulamasıdır. Güneş sistemindeki gezegenleri keşfedin, yakın Dünya asteroitlerini takip edin ve Mars'ın hava durumunu öğrenin.

### 🎯 Misyon

Uzayın büyüleyici dünyasını herkesin erişebileceği, anlaşılır ve görsel olarak etkileyici bir şekilde sunmak.

---

## ✨ Özellikler

### 🪐 Gezegenler
- **İnteraktif Güneş Sistemi**: Animasyonlu gezegen yörüngeleri ve 3D görünümler
- **Detaylı Gezegen Bilgileri**: 
  - 3D animasyonlu gezegen görünümleri
  - Parallax scrolling efektleri
  - 4 sekme: Genel, Karşılaştırma, Yörünge, Detaylar
  - Dünya ile karşılaştırma grafikleri
  - Sıcaklık grafikleri ve boyut karşılaştırmaları
  - Yörünge animasyonları ve hız hesaplamaları
- **8 Gezegen**: Merkür, Venüs, Dünya, Mars, Jüpiter, Satürn, Uranüs, Neptün

### ☄️ Asteroitler
- **Yakın Dünya Asteroitleri**: 7 günlük asteroit takibi
- **Gelişmiş Filtreleme ve Sıralama**:
  - Filtreleme: Tümü, Tehlikeli, Güvenli
  - Sıralama: Tarih, Mesafe, Boyut, Hız
  - Arama özelliği
- **İstatistikler ve Grafikler**:
  - Toplam, tehlikeli ve güvenli asteroit sayıları
  - Ortalama hız ve boyut grafikleri
  - Parallax header efektleri
- **Detaylı Asteroit Bilgileri**:
  - Yaklaşma tarihi ve mesafesi
  - Hız ve boyut bilgileri
  - Dünya ile boyut karşılaştırması

### 🔴 Mars Hava Durumu
- **InSight Lander Verileri**: Gerçek zamanlı Mars hava durumu
- **4 Sekme**:
  - **Güncel**: En son sol verisi ve son veriler
  - **Basınç**: Basınç grafiği
  - **Rüzgar**: Rüzgar hızı grafiği
  - **Tümü**: Tüm sol verileri
- **İstatistikler**:
  - Ortalama basınç
  - Ortalama ve maksimum rüzgar hızı
- **Detaylı Sol Bilgileri**:
  - Atmosfer basıncı (Min, Ort, Max)
  - Rüzgar hızı (Min, Ort, Max)
  - Rüzgar yönü
  - Tarih bilgileri

### 🎨 Tasarım Özellikleri
- **Modern UI/UX**: Minimalist ve şık tasarım
- **Parallax Scrolling**: Dinamik scroll efektleri
- **3D Animasyonlar**: Dönen gezegenler ve asteroitler
- **Gradient Efektleri**: Uzay temalı renk geçişleri
- **Dark Theme**: Göz dostu karanlık tema
- **Smooth Animations**: Akıcı geçişler ve animasyonlar

---

## 🛠 Teknolojiler

- **SwiftUI**: Modern iOS UI framework
- **Combine**: Reactive programming
- **Async/Await**: Asenkron işlemler
- **NASA API**: Uzay verileri
- **Codable**: JSON parsing
- **Custom Components**: Yeniden kullanılabilir UI bileşenleri

---

## 📋 Gereksinimler

- iOS 26.0+
- Xcode 15.0+
- Swift 5.0+
- NASA API Key ([Ücretsiz alın](https://api.nasa.gov))

---

## 🚀 Kurulum

### 1. Repository'yi Klonlayın

```bash
git clone https://github.com/yourusername/TasoSky.git
cd TasoSky
```

### 2. NASA API Key Ekleyin

1. [NASA API](https://api.nasa.gov) sitesinden ücretsiz API key alın
2. `TasoSky/Services/NASAAPIService.swift` dosyasını açın
3. `apiKey` değişkenine API key'inizi ekleyin:

```swift
private let apiKey = "YOUR_API_KEY_HERE"
```

### 3. Xcode'da Açın

```bash
open TasoSky.xcodeproj
```

### 4. Team ID Ayarlayın

1. Xcode'da projeyi açın
2. **TasoSky** projesini seçin
3. **TARGETS** altında **TasoSky**'ı seçin
4. **Signing & Capabilities** sekmesine gidin
5. **Team** dropdown'ından kendi Apple Developer hesabınızı seçin

### 5. Çalıştırın

- Simulator'da test edin veya
- iPhone'unuzda çalıştırın (Developer hesabı gerekli)

---

## 📱 Kullanım

### Gezegenler
1. **Gezegenler** sekmesine gidin
2. Bir gezegene dokunarak detayları görün
3. Sekmeler arasında geçiş yapın:
   - **Genel**: İstatistikler ve ilginç bilgiler
   - **Karşılaştırma**: Dünya ile karşılaştırma grafikleri
   - **Yörünge**: Yörünge animasyonu ve detaylar
   - **Detaylar**: Detaylı gezegen özellikleri

### Asteroitler
1. **Asteroitler** sekmesine gidin
2. Filtreleme ve sıralama seçeneklerini kullanın
3. Bir asteroite dokunarak detayları görün
4. Arama çubuğunu kullanarak asteroit arayın

### Mars Hava Durumu
1. **Mars** sekmesine gidin
2. Sekmeler arasında geçiş yapın:
   - **Güncel**: En son veriler
   - **Basınç**: Basınç grafiği
   - **Rüzgar**: Rüzgar hızı grafiği
   - **Tümü**: Tüm sol verileri
3. Bir sol kartına dokunarak detayları görün

---

## 📸 Ekran Görüntüleri

<div align="center">

### Gezegenler
![Gezegenler](screenshots/planets.png)

### Asteroitler
![Asteroitler](screenshots/asteroids.png)

### Mars Hava Durumu
![Mars](screenshots/mars.png)

</div>

> **Not**: Ekran görüntüleri yakında eklenecektir.

---

## 🏗 Proje Yapısı

```
TasoSky/
├── TasoSky/
│   ├── Models/          # Veri modelleri
│   │   ├── APOD.swift
│   │   ├── NEO.swift
│   │   ├── MarsWeather.swift
│   │   └── Planet.swift
│   ├── Views/           # UI görünümleri
│   │   ├── PlanetsView.swift
│   │   ├── NEOView.swift
│   │   └── MarsWeatherView.swift
│   ├── Services/        # API servisleri
│   │   └── NASAAPIService.swift
│   ├── Components/      # Yeniden kullanılabilir bileşenler
│   │   └── InfoRow.swift
│   ├── Utilities/       # Yardımcı sınıflar
│   │   └── Theme.swift
│   └── Assets.xcassets/ # Görseller ve renkler
├── TasoSkyTests/        # Unit testler
└── TasoSkyUITests/      # UI testler
```

---

## 🔧 Geliştirme

### Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen [CONTRIBUTING.md](CONTRIBUTING.md) dosyasını okuyun.

### Kod Stili

- Swift Style Guide'ı takip edin
- Meaningful variable names kullanın
- Comments ekleyin (özellikle karmaşık mantık için)
- SwiftLint kurallarına uyun

### Test Etme

```bash
# Unit testler
xcodebuild test -scheme TasoSky -destination 'platform=iOS Simulator,name=iPhone 15'

# UI testler
xcodebuild test -scheme TasoSkyUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## 🐛 Bilinen Sorunlar

- [ ] Bazı cihazlarda parallax efektleri yavaş olabilir
- [ ] API rate limit'i aşıldığında hata mesajları iyileştirilebilir

---

## 🗺 Yol Haritası

- [ ] Daha fazla gezegen detayı (uydular, atmosfer bileşimi)
- [ ] APOD (Astronomy Picture of the Day) özelliği
- [ ] Favoriler sistemi
- [ ] Bildirimler (yaklaşan asteroitler)
- [ ] iPad desteği
- [ ] Widget desteği
- [ ] Dark/Light mode toggle
- [ ] Çoklu dil desteği

---

## 🤝 Katkıda Bulunanlar

Bu projeye katkıda bulunan herkese teşekkürler! 🙏

<!-- Katkıda bulunanlar listesi buraya eklenecek -->

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 🙏 Teşekkürler

- [NASA API](https://api.nasa.gov) - Ücretsiz uzay verileri
- [NASA](https://www.nasa.gov) - İlham veren keşifler
- Tüm açık kaynak topluluğu

---

## 📞 İletişim

**Tahsin Mert Mutlu**

- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com
- Twitter: [@yourusername](https://twitter.com/yourusername)

---

## ⭐ Yıldız Verin

Bu projeyi beğendiyseniz, bir yıldız vermeyi unutmayın! ⭐

---

<div align="center">

**Made with ❤️ and ☕ by Tahsin Mert Mutlu**

[⬆ Yukarı Çık](#-tassky)

</div>

