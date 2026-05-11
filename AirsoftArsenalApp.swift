import Foundation

// MARK: - Enums

enum GunType: String, CaseIterable, Codable, Identifiable {
    case aeg = "AEG"
    case gbb = "GBB"
    case hpa = "HPA"
    case sniper = "Sniper"
    case pistol = "Pistol"
    case shotgun = "Shotgun"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .aeg:     return "bolt.fill"
        case .gbb:     return "wind"
        case .hpa:     return "arrow.up.circle.fill"
        case .sniper:  return "scope"
        case .pistol:  return "hand.raised.fill"
        case .shotgun: return "flame.fill"
        case .other:   return "questionmark.circle"
        }
    }
}

enum GunStatus: String, CaseIterable, Codable, Identifiable {
    case operational = "Operational"
    case maintenance = "Needs Maintenance"
    case retired = "Retired"

    var id: String { rawValue }

    var color: String {
        switch self {
        case .operational: return "green"
        case .maintenance: return "orange"
        case .retired:     return "red"
        }
    }
}

enum BatteryType: String, CaseIterable, Codable, Identifiable {
    case lipo74 = "LiPo 7.4V"
    case lipo111 = "LiPo 11.1V"
    case nimh = "NiMH"
    case greenGas = "Green Gas"
    case co2 = "CO2"
    case hpa = "HPA Tank"
    case spring = "Spring (No Battery)"
    case none = "N/A"

    var id: String { rawValue }
}

enum BatteryStatus: String, CaseIterable, Codable, Identifiable {
    case charged = "Charged"
    case needsCharging = "Needs Charging"
    case na = "N/A"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .charged:       return "battery.100"
        case .needsCharging: return "battery.25"
        case .na:            return "minus.circle"
        }
    }
}

// MARK: - Maintenance Log Entry

struct MaintenanceEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var note: String
}

// MARK: - Main Gun Model

struct AirsoftGun: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var brand: String = ""
    var type: GunType = .aeg
    var status: GunStatus = .operational

    // FPS & Hop-Up
    var fps: Int? = nil
    var joules: Double? = nil
    var hopUpSetting: String = ""
    var bbWeight: Double? = nil           // grams
    var innerBarrelLength: Int? = nil     // mm

    // Magazine
    var magazineCount: Int? = nil
    var magazineCapacity: Int? = nil      // rounds per mag

    // Battery / Power
    var batteryType: BatteryType = .none
    var batteryStatus: BatteryStatus = .na
    var batteryNotes: String = ""

    // Purchase
    var purchasePrice: Double? = nil
    var purchaseDate: Date? = nil
    var purchasedFrom: String = ""

    // Extras
    var upgrades: String = ""
    var notes: String = ""
    var maintenanceLog: [MaintenanceEntry] = []

    // Computed
    var totalRounds: Int? {
        guard let mags = magazineCount, let cap = magazineCapacity else { return nil }
        return mags * cap
    }
}

// MARK: - Store

class GunStore: ObservableObject {
    @Published var guns: [AirsoftGun] = []

    private let saveURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("AirsoftArsenal", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent("guns.json")
    }()

    init() { load() }

    func save() {
        guard let data = try? JSONEncoder().encode(guns) else { return }
        try? data.write(to: saveURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let decoded = try? JSONDecoder().decode([AirsoftGun].self, from: data)
        else { return }
        guns = decoded
    }

    func add(_ gun: AirsoftGun) {
        guns.append(gun)
        save()
    }

    func update(_ gun: AirsoftGun) {
        if let idx = guns.firstIndex(where: { $0.id == gun.id }) {
            guns[idx] = gun
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        guns.remove(atOffsets: offsets)
        save()
    }

    func delete(_ gun: AirsoftGun) {
        guns.removeAll { $0.id == gun.id }
        save()
    }

    // Stats
    var totalValue: Double { guns.compactMap(\.purchasePrice).reduce(0, +) }
    var totalMagazines: Int { guns.compactMap(\.magazineCount).reduce(0, +) }
    var operationalCount: Int { guns.filter { $0.status == .operational }.count }
}
