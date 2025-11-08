# Katkıda Bulunma Rehberi

TasoSky projesine katkıda bulunmak istediğiniz için teşekkürler! 🎉

Bu dosya, projeye nasıl katkıda bulunabileceğiniz hakkında bilgi içerir.

## 📋 İçindekiler

- [Davranış Kuralları](#davranış-kuralları)
- [Nasıl Katkıda Bulunabilirim?](#nasıl-katkıda-bulunabilirim)
- [Geliştirme Süreci](#geliştirme-süreci)
- [Kod Stili](#kod-stili)
- [Commit Mesajları](#commit-mesajları)
- [Pull Request Süreci](#pull-request-süreci)

## 🤝 Davranış Kuralları

Bu proje [Davranış Kuralları](CODE_OF_CONDUCT.md) ile yönetilmektedir. Katılımınızla, bu kurallara uymayı kabul etmiş olursunuz.

## 💡 Nasıl Katkıda Bulunabilirim?

### Hata Bildirimi

1. **Mevcut issue'ları kontrol edin** - Sorununuz zaten bildirilmiş olabilir
2. **Yeni bir issue oluşturun** - Açıklayıcı bir başlık ve detaylı açıklama ekleyin
3. **Ekran görüntüleri ekleyin** - Mümkünse sorunu gösteren görseller ekleyin
4. **Adımları listeleyin** - Sorunu yeniden üretme adımlarını ekleyin

### Özellik Önerisi

1. **Yeni bir issue oluşturun** - "Feature Request" etiketi ile
2. **Özelliği açıklayın** - Ne yapmak istediğinizi detaylıca anlatın
3. **Kullanım senaryosunu ekleyin** - Özelliğin nasıl kullanılacağını açıklayın
4. **Tasarım önerileri** - Varsa tasarım fikirlerinizi paylaşın

### Kod Katkısı

1. **Issue'ya yorum yapın** - Çalışmak istediğiniz issue'ya yorum ekleyin
2. **Fork yapın** - Repository'yi fork edin
3. **Branch oluşturun** - Yeni bir feature branch oluşturun
4. **Kod yazın** - Değişikliklerinizi yapın
5. **Test edin** - Değişikliklerinizi test edin
6. **Pull Request gönderin** - PR açın ve değişikliklerinizi açıklayın

## 🔧 Geliştirme Süreci

### 1. Repository'yi Fork Edin

GitHub'da repository'yi fork edin.

### 2. Repository'yi Klonlayın

```bash
git clone https://github.com/yourusername/TasoSky.git
cd TasoSky
```

### 3. Remote Ekleme

```bash
git remote add upstream https://github.com/originalowner/TasoSky.git
```

### 4. Branch Oluşturma

```bash
git checkout -b feature/your-feature-name
# veya
git checkout -b fix/your-bug-fix
```

### 5. Değişikliklerinizi Yapın

- Kod yazın
- Test edin
- Dokümantasyon güncelleyin (gerekirse)

### 6. Commit Yapın

```bash
git add .
git commit -m "feat: yeni özellik eklendi"
```

### 7. Push Yapın

```bash
git push origin feature/your-feature-name
```

### 8. Pull Request Oluşturun

GitHub'da Pull Request oluşturun ve değişikliklerinizi açıklayın.

## 📝 Kod Stili

### Swift Style Guide

- **Naming**: camelCase kullanın
- **Indentation**: 4 spaces (tab değil)
- **Line Length**: Mümkünse 100 karakteri aşmayın
- **Comments**: Karmaşık mantık için açıklayıcı yorumlar ekleyin

### Örnek

```swift
// ✅ İyi
struct PlanetDetailView: View {
    let planet: Planet
    @State private var selectedTab: Int = 0
    
    var body: some View {
        // ...
    }
}

// ❌ Kötü
struct planetDetailView:View{
let planet:Planet
@State private var selectedTab:Int=0
var body:some View{//...}
}
```

### Dosya Organizasyonu

- Her dosya tek bir sorumluluğa sahip olmalı
- İlgili dosyalar aynı klasörde olmalı
- Dosya isimleri açıklayıcı olmalı

## 💬 Commit Mesajları

### Format

```
<type>: <subject>

<body>

<footer>
```

### Type'lar

- `feat`: Yeni özellik
- `fix`: Hata düzeltmesi
- `docs`: Dokümantasyon değişikliği
- `style`: Kod formatı (işlevsellik değişmez)
- `refactor`: Kod yeniden yapılandırma
- `test`: Test ekleme/düzeltme
- `chore`: Build süreci veya yardımcı araçlar

### Örnekler

```bash
feat: gezegen detay sayfasına parallax scrolling eklendi

fix: asteroit filtreleme hatası düzeltildi

docs: README'ye kurulum adımları eklendi

style: kod formatı düzenlendi
```

## 🔍 Pull Request Süreci

### PR Checklist

- [ ] Kod çalışıyor ve test edildi
- [ ] Yeni özellikler için testler eklendi
- [ ] Dokümantasyon güncellendi
- [ ] Kod stili kurallarına uyuldu
- [ ] Commit mesajları açıklayıcı
- [ ] Breaking changes varsa belirtildi

### PR Açıklaması

PR açıklamanızda şunları belirtin:

1. **Ne yapıldı?** - Yapılan değişikliklerin özeti
2. **Neden yapıldı?** - Değişikliğin gerekçesi
3. **Nasıl test edildi?** - Test adımları
4. **Ekran görüntüleri** - UI değişiklikleri varsa

### Review Süreci

1. **Otomatik kontroller** - CI/CD kontrolleri geçmeli
2. **Code review** - En az bir maintainer review yapmalı
3. **Değişiklikler** - Gerekirse değişiklik istenebilir
4. **Onay** - Review onaylandıktan sonra merge edilir

## 🐛 Hata Bildirimi

### Hata Bildirirken

1. **Başlık**: Kısa ve açıklayıcı
2. **Açıklama**: Sorunu detaylıca anlatın
3. **Adımlar**: Sorunu yeniden üretme adımları
4. **Beklenen**: Ne olması gerektiği
5. **Gerçek**: Ne olduğu
6. **Ekran görüntüleri**: Varsa ekleyin
7. **Cihaz/Bilgi**: iOS versiyonu, cihaz modeli

### Örnek

```markdown
**Başlık**: Gezegen detay sayfasında parallax scroll çalışmıyor

**Açıklama**: 
Gezegen detay sayfasında scroll yaparken parallax efekti görünmüyor.

**Adımlar**:
1. Gezegenler sekmesine git
2. Bir gezegene dokun
3. Detay sayfasında scroll yap

**Beklenen**: Parallax efekti görünmeli
**Gerçek**: Hiçbir efekt yok

**Cihaz**: iPhone 15 Pro, iOS 26.0
```

## 📚 Dokümantasyon

- Yeni özellikler için dokümantasyon ekleyin
- README'yi güncelleyin
- Kod yorumları ekleyin (gerekirse)

## ❓ Sorular?

Herhangi bir sorunuz varsa:

- Issue açın
- Discussion'da sorun
- Email gönderin

## 🙏 Teşekkürler

Katkılarınız için teşekkürler! Her katkı, projeyi daha iyi hale getiriyor. 🚀

---

**Not**: Bu rehber sürekli güncellenmektedir. Önerileriniz varsa lütfen paylaşın!

