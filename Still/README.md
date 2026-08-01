# Still — Vibe-Check Build (dark theme)

Bare-bones, dummy-data-only SwiftUI build matching the dark/amber mockup.
No Supabase, no auth — just the UI, so you can feel it out on a simulator.

## What's included
- Design tokens: dark palette, monospaced type, `Card`, `PrimaryButton`, `IconAvatar`, `BottomTabBar`
- `Memory` + `Friend` dummy models (6 memories / 4 places / 5 friends)
- **Home** — greeting, today card, compose card, weekly stats, activity chart
- **Map** — map/list toggle, pins, recent memories list
- **New memory** sheet — place row, text editor w/ char count, private/discoverable
  toggle, combinable friends/future-visitors checkboxes, "leave here" button
- **Memory detail** — full text, private/edit/delete rows
- **Discover** — radar pulse -> **Nearby memory** (a memory left by someone else)
- **Profile** — avatar, stats, -> **Friends** list
- **Bookmarks** tab — saved memories (not in the original mockup screens, added
  since the bottom bar shows a bookmark icon)

## Navigation, since the mockup doesn't show every link
- Bottom bar: home / map / **+** (always opens the new-memory sheet) / bookmarks / profile
- Map -> radar icon (top-left) -> Discover -> tap the pulsing dot -> Nearby memory
- Profile -> person.2 icon (top-left) -> Friends
- Everything else (Save, Edit, Delete, checkboxes) is visual only — nothing persists

## Setup (2 minutes)
1. Xcode -> File -> New -> Project -> iOS -> App
2. Product Name: Still, Interface: SwiftUI, Language: Swift
   (uncheck Core Data and Include Tests)
3. Delete the auto-generated ContentView.swift
4. Drag DesignSystem, Models, Views, and StillApp.swift into the project
   navigator — check "Copy items if needed" and the Still target
5. If Xcode made its own StillApp.swift, delete the duplicate (keep one @main)
6. Deployment target: iOS 18
7. Cmd+R on any iOS 18 simulator

## Notes
- Colors/type are a first read of the mockup — easy to nudge once you see it live.
- The activity chart uses hardcoded dummy values, not real "memories over time" data.
- This is a disposable UI shell, separate from the real M1 auth codebase.
