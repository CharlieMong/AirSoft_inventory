# Airsoft Arsenal — macOS rif Tracker

A native macOS SwiftUI app to track your airsoft collection.

## Requirements
- macOS 14 (Sonoma) or later
- Xcode 15 or later

## Setup

1. Unzip / open the `AirsoftArsenal` folder
2. Double-click `AirsoftArsenal.xcodeproj` to open in Xcode
3. In the toolbar, select **My Mac** as the run destination
4. Press **⌘R** (or click ▶) to build and run

> **Bundle ID:** Change `com.yourname.AirsoftArsenal` in Build Settings → Product Bundle Identifier to something unique to you if you plan to distribute the app.

## Features

### Per-gun tracking
- **Name & brand** — model name, manufacturer, type (AEG / GBB / HPA / Sniper / Pistol / Shotgun)
- **FPS & ballistics** — muzzle velocity (fps), energy (joules), hop-up setting, BB weight, inner barrel length
- **Magazines** — count and capacity per mag; total rounds auto-calculated
- **Battery / power** — type (LiPo 7.4V, 11.1V, NiMH, Green Gas, CO2, HPA, Spring), charge status with indicator, notes
- **Purchase info** — price (£), date, retailer
- **Upgrades** — free-text field for mods and aftermarket parts
- **Notes** — general freeform notes
- **Maintenance log** — timestamped entries, newest first

### App-wide
- Sidebar with live search and type filter chips
- Header bar showing total guns, total magazines, and total fleet value
- Status dot per gun (Operational / Needs Maintenance / Retired)
- Quick-stats row in detail view (FPS, Joules, Mags, Total Rounds)
- Data persisted to `~/Library/Application Support/AirsoftArsenal/guns.json`
- ⌘N shortcut to add a new gun from anywhere

## File Structure
```
AirsoftArsenal/
├── AirsoftArsenal.xcodeproj/
│   └── project.pbxproj
└── AirsoftArsenal/
    ├── AirsoftArsenalApp.swift   — App entry point & menu commands
    ├── Models.swift              — Data models & GunStore (persistence)
    ├── ContentView.swift         — NavigationSplitView, sidebar, filters
    ├── GunDetailView.swift       — Detail panel & maintenance log
    └── GunFormView.swift         — Add / Edit sheet
```
