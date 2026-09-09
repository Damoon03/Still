# Still

**A minimalist location-based memory app built with SwiftUI.**

Still turns the places you visit into quiet collections of personal moments and stories.  
Leave a thought where you are, revisit it later, or discover what others left nearby — all in a calm, intentional interface.

<p align="center">
  <img src="https://img.shields.io/badge/iOS-18%2B-black?style=flat-square&logo=apple&logoColor=white" alt="iOS 18+"/>
  &nbsp;
  <img src="https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift"/>
  &nbsp;
  <img src="https://img.shields.io/badge/SwiftUI-000000?style=flat-square&logo=swift&logoColor=white" alt="SwiftUI"/>
  &nbsp;
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=flat-square&logo=supabase&logoColor=white" alt="Supabase"/>
  &nbsp;
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="License"/>
</p>

---

## Overview

Still is a personal memory companion that treats **place** as the primary context.  
Instead of a timeline of posts, you build a quiet map of moments — private by default, discoverable when you choose.

| Concept              | Description                                                    |
|----------------------|----------------------------------------------------------------|
| **Memories**         | Short reflections tied to a location and optional coordinates  |
| **Places**           | Collections of moments that live at the same spot              |
| **Discover**         | Nearby public memories left by others                          |
| **Privacy**          | Every memory can be private or discoverable                    |

---

## Features

- **Location-tied memories** — Capture thoughts exactly where you are
- **Map & list views** — Explore your history as pins or a clean chronological list
- **Discover nearby** — Radar-style discovery of public memories around you
- **Privacy controls** — Keep memories private or make them discoverable
- **Friends** — Simple friend list and sharing intent
- **Bookmarks** — Save moments you want to revisit
- **Authentication** — Supabase-backed auth with local/mock fallback
- **Offline-first** — SwiftData for reliable local persistence

---

## Screens

| Screen         | Purpose                                                    |
|----------------|------------------------------------------------------------|
| **Home**       | Greeting, today’s card, compose prompt, weekly activity    |
| **Map**        | Interactive map + list toggle with memory pins             |
| **New Memory** | Place, text, privacy toggle, friends & future visitors     |
| **Discover**   | Radar pulse → nearby public memories                       |
| **Bookmarks**  | Saved memories                                            |
| **Profile**    | Avatar, stats, friends list                                |

---

## Tech Stack

| Layer               | Technology                        |
|---------------------|-----------------------------------|
| UI                  | SwiftUI                           |
| Architecture        | MVVM + Repository pattern         |
| Local Persistence   | SwiftData                         |
| Backend             | Supabase (Auth + Database)        |
| Location            | Core Location                     |
| Minimum Target      | iOS 18                            |

---

## Project Structure

```text
Still/
├── Components/          # Reusable UI pieces
├── Config/              # Supabase configuration
├── DesignSystem/        # Colors, typography, shared controls
├── Models/              # Memory, Friend, UserProfile…
├── Repositories/        # Local + Supabase memory repositories
├── Services/            # Auth & Location services
├── ViewModels/
├── Views/               # Home, Map, Discover, Profile, Auth…
└── StillApp.swift       # App entry point
```

---

## Getting Started

### Requirements

- Xcode 16 or later
- iOS 18 SDK
- A Supabase project *(optional — the app can run fully local)*

### 1. Clone the repository

```bash
git clone https://github.com/Damoon03/Still.git
cd Still
```

### 2. Open in Xcode

Open `Still.xcodeproj`.

### 3. Configure Supabase (optional)

1. Create a project at [supabase.com](https://supabase.com)
2. Add the **Supabase Swift** package to the Xcode project
3. Update `Still/Config/SupabaseConfig.swift` with your project URL and anon key

To run fully offline / with dummy data, fall back to:

```swift
authService = MockAuthService()
memoryRepository = LocalMemoryRepository(modelContainer: modelContainer)
```

### 4. Run

Select an iOS 18 simulator (or a physical device) and press **⌘R**.

---

## Architecture Notes

- **Repository pattern** cleanly separates local SwiftData storage from the Supabase backend
- **AuthCoordinator** manages the signed-in / signed-out experience
- Design system uses a dark + amber palette with monospaced type for a calm, focused feel
- Memories store optional coordinates so they only appear on the map when location is available

---

## Roadmap

Current focus areas:

- [ ] Full Supabase schema + real-time sync
- [ ] Proper friend invites & sharing
- [ ] Media attachments (photos / voice notes)
- [ ] Refined Discover experience
- [ ] App Store preparation

---

## License

This project is licensed under the **MIT License**.

```
MIT License

Copyright (c) 2026 Damoon Saber

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<p align="center">
  Made with care by <a href="https://github.com/Damoon03">Damoon Saber</a>
</p>
```