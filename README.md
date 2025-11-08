<div align="center">

![TasoSky Logo](tasosky-logo.png)

# 🌌 TasoSky

**Explore the Depths of Space**

A modern, elegant, and informative NASA space exploration app

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-26.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![NASA API](https://img.shields.io/badge/NASA-API-red.svg)](https://api.nasa.gov)

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Screenshots](#-screenshots) • [Contributing](#-contributing) • [License](#-license)

</div>

---

## 📖 About

**TasoSky** is a modern iOS app that provides information about space using NASA API. Explore planets in our solar system, track near-Earth asteroids, and learn about Mars weather.

### 🎯 Mission

To make the fascinating world of space accessible to everyone in an understandable and visually impressive way.

---

## ✨ Features

### 🪐 Planets
- **Interactive Solar System**: Animated planet orbits and 3D views
- **Detailed Planet Information**: 
  - 3D animated planet views
  - Parallax scrolling effects
  - 4 tabs: Overview, Comparison, Orbit, Details
  - Comparison charts with Earth
  - Temperature charts and size comparisons
  - Orbit animations and speed calculations
- **8 Planets**: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune

### ☄️ Asteroids
- **Near-Earth Asteroids**: 7-day asteroid tracking
- **Advanced Filtering and Sorting**:
  - Filtering: All, Hazardous, Safe
  - Sorting: Date, Distance, Size, Speed
  - Search functionality
- **Statistics and Charts**:
  - Total, hazardous, and safe asteroid counts
  - Average speed and size charts
  - Parallax header effects
- **Detailed Asteroid Information**:
  - Approach date and distance
  - Speed and size information
  - Size comparison with Earth

### 🔴 Mars Weather
- **InSight Lander Data**: Real-time Mars weather
- **4 Tabs**:
  - **Current**: Latest sol data and recent data
  - **Pressure**: Pressure chart
  - **Wind**: Wind speed chart
  - **All**: All sol data
- **Statistics**:
  - Average pressure
  - Average and maximum wind speed
- **Detailed Sol Information**:
  - Atmospheric pressure (Min, Avg, Max)
  - Wind speed (Min, Avg, Max)
  - Wind direction
  - Date information

### 🎨 Design Features
- **Modern UI/UX**: Minimalist and elegant design
- **Parallax Scrolling**: Dynamic scroll effects
- **3D Animations**: Rotating planets and asteroids
- **Gradient Effects**: Space-themed color transitions
- **Dark Theme**: Eye-friendly dark theme
- **Smooth Animations**: Fluid transitions and animations

---

## 🛠 Technologies

- **SwiftUI**: Modern iOS UI framework
- **Combine**: Reactive programming
- **Async/Await**: Asynchronous operations
- **NASA API**: Space data
- **Codable**: JSON parsing
- **Custom Components**: Reusable UI components

---

## 📋 Requirements

- iOS 26.0+
- Xcode 15.0+
- Swift 5.0+
- NASA API Key ([Get it free](https://api.nasa.gov))

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/tahsinmert/TasoSky.git
cd TasoSky
```

### 2. Add NASA API Key

1. Get a free API key from [NASA API](https://api.nasa.gov)
2. Open `TasoSky/Services/NASAAPIService.swift`
3. Add your API key to the `apiKey` variable:

```swift
private let apiKey = "YOUR_API_KEY_HERE"
```

### 3. Open in Xcode

```bash
open TasoSky.xcodeproj
```

### 4. Set Team ID

1. Open the project in Xcode
2. Select the **TasoSky** project
3. Select **TasoSky** under **TARGETS**
4. Go to **Signing & Capabilities** tab
5. Select your Apple Developer account from the **Team** dropdown

### 5. Run

- Test in Simulator or
- Run on your iPhone (Developer account required)

---

## 📱 Usage

### Planets
1. Go to the **Planets** tab
2. Tap on a planet to view details
3. Switch between tabs:
   - **Overview**: Statistics and interesting facts
   - **Comparison**: Comparison charts with Earth
   - **Orbit**: Orbit animation and details
   - **Details**: Detailed planet properties

### Asteroids
1. Go to the **Asteroids** tab
2. Use filtering and sorting options
3. Tap on an asteroid to view details
4. Use the search bar to search for asteroids

### Mars Weather
1. Go to the **Mars** tab
2. Switch between tabs:
   - **Current**: Latest data
   - **Pressure**: Pressure chart
   - **Wind**: Wind speed chart
   - **All**: All sol data
3. Tap on a sol card to view details

---

## 📸 Screenshots

<div align="center">

### Planets
![Planets](screenshots/planets.png)

### Asteroids
![Asteroids](screenshots/asteroids.png)

### Mars Weather
![Mars](screenshots/mars.png)

</div>

> **Note**: Screenshots will be added soon.

---

## 🏗 Project Structure

```
TasoSky/
├── TasoSky/
│   ├── Models/          # Data models
│   │   ├── APOD.swift
│   │   ├── NEO.swift
│   │   ├── MarsWeather.swift
│   │   └── Planet.swift
│   ├── Views/           # UI views
│   │   ├── PlanetsView.swift
│   │   ├── NEOView.swift
│   │   └── MarsWeatherView.swift
│   ├── Services/        # API services
│   │   └── NASAAPIService.swift
│   ├── Components/      # Reusable components
│   │   └── InfoRow.swift
│   ├── Utilities/       # Helper classes
│   │   └── Theme.swift
│   └── Assets.xcassets/ # Images and colors
├── TasoSkyTests/        # Unit tests
└── TasoSkyUITests/      # UI tests
```

---

## 🔧 Development

### Contributing

We welcome your contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md).

### Code Style

- Follow Swift Style Guide
- Use meaningful variable names
- Add comments (especially for complex logic)
- Follow SwiftLint rules

### Testing

```bash
# Unit tests
xcodebuild test -scheme TasoSky -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -scheme TasoSkyUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## 🐛 Known Issues

- [ ] Parallax effects may be slow on some devices
- [ ] Error messages can be improved when API rate limit is exceeded

---

## 🗺 Roadmap

- [ ] More planet details (moons, atmosphere composition)
- [ ] APOD (Astronomy Picture of the Day) feature
- [ ] Favorites system
- [ ] Notifications (approaching asteroids)
- [ ] iPad support
- [ ] Widget support
- [ ] Dark/Light mode toggle
- [ ] Multi-language support

---

## 🤝 Contributors

Thank you to everyone who contributed to this project! 🙏

<!-- Contributors list will be added here -->

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [NASA API](https://api.nasa.gov) - Free space data
- [NASA](https://www.nasa.gov) - Inspiring discoveries
- All open source community

---

## 📞 Contact

**Tahsin Mert Mutlu**

- GitHub: [@tahsinmert](https://github.com/tahsinmert)
- Email: your.email@example.com
- Twitter: [@yourusername](https://twitter.com/yourusername)

---

## ⭐ Star This Project

If you liked this project, don't forget to give it a star! ⭐

---

<div align="center">

**Made with ❤️ and ☕ by Tahsin Mert Mutlu**

[⬆ Back to Top](#-tassky)

</div>
